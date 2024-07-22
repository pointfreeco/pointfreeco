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
  param: Either<String, Episode.ID>,
  collectionSlug: Episode.Collection.Slug?
) async -> Conn<ResponseEnded, Data> {

  @Dependency(\.episodes) var episodes

  guard let episode = episode(forParam: param)
  else {
    return
      conn
      .writeStatus(.notFound)
      .respond { episodeNotFoundView() }
  }

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.subscriberState) var subscriberState

  let permission: EpisodePermission
  let progress: Int?

  if let currentUser {
    var fetchProgress = false
    if subscriberState.isActiveSubscriber {
      permission = .loggedIn(user: currentUser, subscriptionPermission: .isSubscriber)
      fetchProgress = true
    } else {
      let credits = try? await database.fetchEpisodeCredits(userID: currentUser.id)
      if credits?.contains(where: { $0.episodeSequence == episode.sequence }) == true {
        permission = .loggedIn(
          user: currentUser,
          subscriptionPermission: .isNotSubscriber(creditPermission: .hasUsedCredit)
        )
        fetchProgress = true
      } else {
        permission = .loggedIn(
          user: currentUser,
          subscriptionPermission: .isNotSubscriber(
            creditPermission: .hasNotUsedCredit(isEpisodeSubscriberOnly: episode.subscriberOnly)
          )
        )
        fetchProgress = !episode.subscriberOnly
      }
    }
    if fetchProgress {
      progress =
        try? await database
        .fetchEpisodeProgress(userID: currentUser.id, sequence: episode.sequence)
        .percent
    } else {
      progress = nil
    }
  } else {
    permission = .loggedOut(isEpisodeSubscriberOnly: episode.subscriberOnly)
    progress = nil
  }

  guard episode.transcript != nil else {
    // TODO: reportIssue("Episode #\(episode.sequence) transcript not found")
    return
      conn
      .writeStatus(.notFound)
      .respond { episodeNotFoundView() }
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

func useCreditResponse<Z>(
  conn: Conn<StatusLineOpen, T5<Either<String, Episode.ID>, User?, SubscriberState, SiteRoute?, Z>>
) -> IO<Conn<ResponseEnded, Data>> {
  conn
    |> (fetchEpisodeForParam
      <<< validateUserEpisodePermission
      <| applyCreditMiddleware)
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

private func validateUserEpisodePermission<Z>(
  middleware: @escaping M<T5<EpisodePermission, Episode, User, SubscriberState, Z>>
) -> M<T4<Episode, User?, SubscriberState, Z>> {
  middleware
    |> { userEpisodePermission >=> $0 }
    <<< filterMap(require3 >>> pure, or: loginAndRedirect)
    <<< validateCreditRequest
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

private func applyCreditMiddleware<Z>(
  _ conn: Conn<StatusLineOpen, T4<EpisodePermission, Episode, User, Z>>
) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.database) var database

  let (episode, user) = (get2(conn.data), get3(conn.data))

  guard user.episodeCreditCount > 0 else {
    return conn
      |> redirect(
        to: .episodes(.show(.left(episode.slug))),
        headersMiddleware: flash(.error, "You do not have any credits to use.")
      )
  }

  return EitherIO {
    try await database.redeemEpisodeCredit(sequence: episode.sequence, userID: user.id)
    try await database
      .updateUser(id: user.id, episodeCreditCount: user.episodeCreditCount - 1)
  }
  .run
  .flatMap(
    either(
      const(
        conn
          |> redirect(
            to: .episodes(.show(.left(episode.slug))),
            headersMiddleware: flash(.warning, "Something went wrong.")
          )
      ),
      const(
        conn
          |> redirect(
            to: .episodes(.show(.left(episode.slug))),
            headersMiddleware: flash(.notice, "You now have access to this episode!")
          )
      )
    )
  )
}

private func validateCreditRequest<Z>(
  _ middleware: @escaping Middleware<
    StatusLineOpen, ResponseEnded, T4<EpisodePermission, Episode, User, Z>, Data
  >
) -> Middleware<StatusLineOpen, ResponseEnded, T4<EpisodePermission, Episode, User, Z>, Data> {

  return { conn in
    let (permission, episode, user) = (get1(conn.data), get2(conn.data), get3(conn.data))

    guard user.episodeCreditCount > 0 else {
      return conn
        |> redirect(
          to: .episodes(.show(.left(episode.slug))),
          headersMiddleware: flash(.error, "You do not have any credits to use.")
        )
    }

    guard isEpisodeViewable(for: permission) else {
      return middleware(conn)
    }

    return conn
      |> redirect(
        to: .episodes(.show(.left(episode.slug))),
        headersMiddleware: flash(.warning, "This episode is already available to you.")
      )
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
