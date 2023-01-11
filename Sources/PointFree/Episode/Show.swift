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

let episodeResponse:
  M<
    Tuple2<Either<String, Episode.ID>, Episode.Collection.Slug?>
  > =
    fetchEpisodeForParam
    <| writeStatus(.ok)
    >=> userEpisodePermission
    >=> fetchEpisodeProgress
    >=> map(lower)
    >>> respond(
      view: episodePageView(episodePageData:),
      layoutData: { permission, episode, episodeProgress, collectionSlug in
        SimplePageLayoutData(
          data: episodePageData(
            collectionSlug: collectionSlug,
            episode: episode,
            episodeProgress: episodeProgress,
            permission: permission
          ),
          description: episode.blurb,
          extraStyles: extraEpisodePageStyles,
          image: episode.image,
          style: .base(.minimal(.black)),
          title: "Episode #\(episode.sequence): \(episode.fullTitle)",
          usePrismJs: true
        )
      }
    )

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
  if let collection = collections.first(where: { $0.slug == collectionSlug }) {
    context = .collection(collection)
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
        episode.sequence,
        percent,
        percent >= 90,
        currentUser.id
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
        to: .episode(.show(.left(episode.slug))),
        headersMiddleware: flash(.error, "You do not have any credits to use.")
      )
  }

  return EitherIO {
    try await database.redeemEpisodeCredit(episode.sequence, user.id)
    try await database
      .updateUser(id: user.id, episodeCreditCount: user.episodeCreditCount - 1)
  }
  .run
  .flatMap(
    either(
      const(
        conn
          |> redirect(
            to: .episode(.show(.left(episode.slug))),
            headersMiddleware: flash(.warning, "Something went wrong.")
          )
      ),
      const(
        conn
          |> redirect(
            to: .episode(.show(.left(episode.slug))),
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
          to: .episode(.show(.left(episode.slug))),
          headersMiddleware: flash(.error, "You do not have any credits to use.")
        )
    }

    guard isEpisodeViewable(for: permission) else {
      return middleware(conn)
    }

    return conn
      |> redirect(
        to: .episode(.show(.left(episode.slug))),
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
    return try await database.fetchEpisodeProgress(currentUser.id, episode.sequence)
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
    guard let credits = try? await database.fetchEpisodeCredits(user.id)
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
  @Dependency(\.episodes) var episodes

  return episodes()
    .first(where: {
      param.left == .some($0.slug) || param.right == .some($0.id)
    })
}

private let extraEpisodePageStyles =
  markdownBlockStyles <> .id("episode-header-blurb") % (a % color(Colors.gray850))
