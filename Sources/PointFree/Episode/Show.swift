import Css
import Dependencies
import Either
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import Views

func showEpisode(
  _ conn: Conn<StatusLineOpen, Void>,
  episode: Episode,
  collectionSlug: Episode.Collection.Slug?
) async -> Conn<ResponseEnded, Data> {
  guard episode.transcript != nil else {
    // TODO: reportIssue("Episode #\(episode.sequence) transcript not found")
    return
      conn
      .writeStatus(.notFound)
      .respond { episodeNotFoundView() }
  }

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.subscriberState) var subscriberState

  let permission = await EpisodePermission(episode: episode)
  let progress: Int? = switch permission {
  case .loggedIn(let currentUser, .isSubscriber),
    .loggedIn(let currentUser, .isNotSubscriber(creditPermission: .hasUsedCredit)),
    .loggedIn(let currentUser, .isNotSubscriber(creditPermission: .hasNotUsedCredit(false))):
    try? await database
    .fetchEpisodeProgress(userID: currentUser.id, sequence: episode.sequence)
    .percent
  default: nil
  }

  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: String(stripping: episode.blurb),
        image: episode.image,
        title: "Episode #\(episode.sequence): \(episode.fullTitle)",
        usePrismJs: true
      )
    ) {
      EpisodeDetail(
        episodePageData: episodePageData(
          collectionSlug: collectionSlug,
          episode: episode,
          episodeProgress: progress,
          permission: permission
        )
      )
    }
}

private func episodePageData(
  collectionSlug: Episode.Collection.Slug?,
  episode: Episode,
  episodeProgress: Int?,
  permission: EpisodePermission
) -> EpisodePageData {
  @Dependency(\.collections) var collections
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.episodes) var episodes
  @Dependency(\.date.now) var now

  let context: EpisodePageData.Context
  if let collection = collections.first(where: { $0.slug == collectionSlug }),
    let section = collection.sections.first(where: {
      $0.coreLessons.contains(where: { $0.episode?.id == episode.id })
    })
  {
    context = .collection(collection, section: section)
  } else {
    context = .direct(
      previousEpisode: episodes().first(where: { $0.sequence == episode.sequence - 1 }),
      nextEpisode: episodes().first(where: { $0.sequence == episode.sequence + 1 })
    )
  }

  return EpisodePageData(
    context: context,
    emergencyMode: emergencyMode,
    episode: episode,
    episodeProgress: episodeProgress,
    permission: permission
  )
}

private func fetchEpisodeForParam<Z>(
  middleware: @escaping M<T2<Episode, Z>>
) -> M<T2<Either<String, Episode.ID>, Z>> {
  middleware
    |> filterMap(
      over1(episode(forParam:)) >>> require1 >>> pure,
      or: episodeNotFoundResponse
    )
}

private func episodeNotFoundResponse<Z>(
  conn: Conn<StatusLineOpen, T2<Either<String, Episode.ID>, Z>>
) -> IO<Conn<ResponseEnded, Data>> {
  conn
    |> writeStatus(.notFound)
    >=> respond { _ in episodeNotFoundView() }
}

let progressResponse: M<Tuple2<Either<String, Episode.ID>, Int>> =
  filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >=> end
  )
  <| userEpisodePermission
  >=> updateProgress

private func isEpisodeViewable(for permission: EpisodePermission) -> Bool {
  switch permission {
  case .loggedIn(_, .isSubscriber):
    return true
  case .loggedIn(_, .isNotSubscriber(.hasUsedCredit)):
    return true
  case let .loggedIn(_, .isNotSubscriber(.hasNotUsedCredit(isSubscriberOnly))):
    return !isSubscriberOnly
  case let .loggedOut(isSubscriberOnly):
    return !isSubscriberOnly
  }
}

private let updateProgress: M<Tuple3<EpisodePermission, Episode, Int>> = { conn in
  @Dependency(\.currentUser) var currentUser
  // NB: `lower` crashes on Linux 5.2. https://bugs.swift.org/browse/SR-12437
  let (permission, episode, percent) = (get1(conn.data), get2(conn.data), get3(conn.data))
  guard let currentUser = currentUser
  else {
    return conn
      |> writeStatus(.ok)
      >=> end
  }

  if isEpisodeViewable(for: permission) {
    @Dependency(\.database) var database

    return EitherIO {
      try await database.updateEpisodeProgress(
        sequence: episode.sequence,
        progress: percent,
        isFinished: percent >= 90,
        userID: currentUser.id
      )
    }
    .run
    .flatMap { _ in
      conn
        |> writeStatus(.ok)
        >=> end
    }
  } else {
    return conn
      |> writeStatus(.ok)
      >=> end
  }
}

func fetchEpisodeProgress<I, Z>(conn: Conn<I, T3<EpisodePermission, Episode, Z>>)
  -> IO<Conn<I, T4<EpisodePermission, Episode, Int?, Z>>>
{
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database

  let (permission, episode) = (get1(conn.data), get2(conn.data))

  return EitherIO {
    guard let currentUser else { return nil }
    return try await database.fetchEpisodeProgress(
      userID: currentUser.id,
      sequence: episode.sequence
    )
    .percent
  }
  .run
  .map {
    conn.map(
      const(permission .*. episode .*. ($0.right ?? nil) .*. rest(conn.data)))
  }
}

func userEpisodePermission<I, Z>(
  _ conn: Conn<I, T2<Episode, Z>>
)
  -> IO<Conn<I, T3<EpisodePermission, Episode, Z>>>
{
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.subscriberState) var subscriberState
  let episode = get1(conn.data)

  guard let user = currentUser else {
    let permission: EpisodePermission = .loggedOut(isEpisodeSubscriberOnly: episode.subscriberOnly)
    return pure(conn.map(const(permission .*. conn.data)))
  }

  let hasCredit = IO {
    guard let credits = try? await database.fetchEpisodeCredits(userID: user.id)
    else { return false }
    return credits.contains { $0.episodeSequence == episode.sequence }
  }

  let permission =
    hasCredit
    .map { hasCredit -> EpisodePermission in
      switch (hasCredit, subscriberState.isActiveSubscriber) {
      case (_, true):
        return .loggedIn(user: user, subscriptionPermission: .isSubscriber)
      case (true, false):
        return .loggedIn(
          user: user, subscriptionPermission: .isNotSubscriber(creditPermission: .hasUsedCredit))
      case (false, false):
        return .loggedIn(
          user: user,
          subscriptionPermission: .isNotSubscriber(
            creditPermission: .hasNotUsedCredit(isEpisodeSubscriberOnly: episode.subscriberOnly)
          )
        )
      }
    }

  return
    permission
    .map { conn.map(const($0 .*. conn.data)) }
}

private func episodeNotFoundView() -> Node {
  SimplePageLayoutData(
    data: (),
    title: "Episode not found :("
  )
    |> simplePageLayout({
      .gridRow(
        attributes: [.class([Class.grid.center(.mobile)])],
        .gridColumn(
          sizes: [.mobile: 6],
          .div(
            attributes: [.style(padding(topBottom: .rem(12)))],
            .h5(
              attributes: [.class([Class.h5])],
              "Episode not found :("
            ),
            .pre(
              .code(
                attributes: [.class([Class.pf.components.code(lang: "swift")])],
                "f: (Episode) -> Never"
              )
            )
          )
        )
      )
    })
}

private func episode(forParam param: Either<String, Episode.ID>) -> Episode? {
  @Dependency(\.episodes) var episodes: () -> [Episode]

  return episodes()
    .first(where: {
      param.left == .some($0.slug) || param.right == .some($0.id)
    })
}
