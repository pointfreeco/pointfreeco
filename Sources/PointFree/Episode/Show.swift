import Css
import Either
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import Views

let episodeResponse: M<Tuple5<Either<String, Episode.Id>, User?, SubscriberState, Route?, Episode.Collection.Slug?>> =
  fetchEpisodeForParam
    <| writeStatus(.ok)
    >=> userEpisodePermission
    >=> map(lower)
    >>> respond(
      view: newEpisodePageView(episodePageData:),
      layoutData: { permission, episode, currentUser, subscriberState, currentRoute, collectionSlug in

        return SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: episodePageData(
            currentUser: currentUser,
            collectionSlug: collectionSlug,
            episode: episode,
            permission: permission,
            subscriberState: subscriberState
          ),
          description: episode.blurb,
          extraStyles: markdownBlockStyles,
          image: episode.image,
          style: .base(.minimal(.black)),
          title: "Episode #\(episode.sequence): \(episode.fullTitle)",
          usePrismJs: true
        )
    }
)

private func episodePageData(
  currentUser: User?,
  collectionSlug: Episode.Collection.Slug?,
  episode: Episode,
  permission: EpisodePermission,
  subscriberState: SubscriberState
) -> NewEpisodePageData {
  let context: NewEpisodePageData.Context
  if let collection = Current.collections.first(where: { $0.slug == collectionSlug }) {
    context = .collection(collection)
  } else {
    context = .direct(
      previousEpisode: Current.episodes().first(where: { $0.sequence == episode.sequence - 1 }),
      nextEpisode: Current.episodes().first(where: { $0.sequence == episode.sequence + 1 })
    )
  }

  return NewEpisodePageData(
    context: context,
    date: Current.date,
    episode: episode,
    permission: permission,
    subscriberState: subscriberState,
    user: currentUser
  )
}

func useCreditResponse<Z>(
  conn: Conn<StatusLineOpen, T5<Either<String, Episode.Id>, User?, SubscriberState, Route?, Z>>
) -> IO<Conn<ResponseEnded, Data>> {
  conn
    |> (fetchEpisodeForParam
    <<< validateUserEpisodePermission
    <| applyCreditMiddleware)
}

private func fetchEpisodeForParam<Z>(
  middleware: @escaping M<T5<Episode, User?, SubscriberState, Route?, Z>>
) -> M<T5<Either<String, Episode.Id>, User?, SubscriberState, Route?, Z>> {
  middleware
    |> filterMap(
      over1(episode(forParam:)) >>> require1 >>> pure,
      or: episodeNotFoundResponse
  )
}

private func episodeNotFoundResponse<Z>(
  conn: Conn<StatusLineOpen, T5<Either<String, Episode.Id>, User?, SubscriberState, Route?, Z>>
) -> IO<Conn<ResponseEnded, Data>> {
  conn
    |> writeStatus(.notFound)
    >=> respond { episodeNotFoundView(user: get2($0), subscriberState: get3($0), route: get4($0)) }
}

private func validateUserEpisodePermission<Z>(
  middleware: @escaping M<T5<EpisodePermission, Episode, User, SubscriberState, Z>>
) -> M<T4<Episode, User?, SubscriberState, Z>> {
  middleware
    |> { userEpisodePermission >=> $0 }
    <<< filterMap(require3 >>> pure, or: loginAndRedirect)
    <<< validateCreditRequest
}

let progressResponse: M<
  Tuple4<
  Either<String, Episode.Id>,
  Models.User?,
  SubscriberState,
  Int>
  > =
  filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >=> end
    )
    <| userEpisodePermission
    >=> updateProgress

private let updateProgress: M<Tuple5<EpisodePermission, Episode, Models.User?, SubscriberState, Int>> = { conn in
  guard case let (permission, episode, .some(user), subscriberState, percent) = lower(conn.data)
    else {
      return conn
        |> writeStatus(.ok)
        >=> end
  }

  if isEpisodeViewable(for: permission) {
    return Current.database.updateEpisodeProgress(episode.sequence, percent, user.id)
      .run
      .flatMap { _ in
        conn
          |> writeStatus(.ok)
          >=> end
    }
  } else {
    return  conn
      |> writeStatus(.ok)
      >=> end
  }
}

private func applyCreditMiddleware<Z>(
  _ conn: Conn<StatusLineOpen, T4<EpisodePermission, Episode, User, Z>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let (episode, user) = (get2(conn.data), get3(conn.data))

  guard user.episodeCreditCount > 0 else {
    return conn
      |> redirect(
        to: .episode(.show(.left(episode.slug))),
        headersMiddleware: flash(.error, "You do not have any credits to use.")
    )
  }

  return Current.database.redeemEpisodeCredit(episode.sequence, user.id)
    .flatMap { _ in
      Current.database.updateUser(user.id, nil, nil, nil, user.episodeCreditCount - 1, nil)
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
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T4<EpisodePermission, Episode, User, Z>, Data>
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

func userEpisodePermission<I, Z>(
  _ conn: Conn<I, T4<Episode, User?, SubscriberState, Z>>
)
  -> IO<Conn<I, T5<EpisodePermission, Episode, User?, SubscriberState, Z>>> {

    let (episode, currentUser, subscriberState) = (get1(conn.data), get2(conn.data), get3(conn.data))

    guard let user = currentUser else {
      let permission: EpisodePermission = .loggedOut(isEpisodeSubscriberOnly: episode.subscriberOnly)
      return pure(conn.map(const(permission .*. conn.data)))
    }

    let hasCredit = Current.database.fetchEpisodeCredits(user.id)
      .map { credits in credits.contains { $0.episodeSequence == episode.sequence } }
      .run
      .map { $0.right ?? false }

    let permission = hasCredit
      .map { hasCredit -> EpisodePermission in
        switch (hasCredit, subscriberState.isActiveSubscriber) {
        case (_, true):
          return .loggedIn(user: user, subscriptionPermission: .isSubscriber)
        case (true, false):
          return .loggedIn(user: user, subscriptionPermission: .isNotSubscriber(creditPermission: .hasUsedCredit))
        case (false, false):
          return .loggedIn(
            user: user,
            subscriptionPermission: .isNotSubscriber(
              creditPermission: .hasNotUsedCredit(isEpisodeSubscriberOnly: episode.subscriberOnly)
            )
          )
        }
    }

    return permission
      .map { conn.map(const($0 .*. conn.data)) }
}

private func episodeNotFoundView(
  user: User?,
  subscriberState: SubscriberState,
  route: Route?
) -> Node {
  SimplePageLayoutData(
    currentSubscriberState: subscriberState,
    currentUser: user,
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

private func episode(forParam param: Either<String, Episode.Id>) -> Episode? {
  return Current.episodes()
    .first(where: {
      param.left == .some($0.slug) || param.right == .some($0.id)
    })
}
