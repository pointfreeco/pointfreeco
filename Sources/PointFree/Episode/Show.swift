import Css
import Either
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import Views

let episodeResponse =
  fetchEpisodeForParam
    <| writeStatus(.ok)
    >=> userEpisodePermission
    >=> map(lower)
    >>> respond(
      view: Views.episodeView(episodePageData:),
      layoutData: { permission, episode, currentUser, subscriberState, currentRoute in
        let navStyle: NavStyle = currentUser == nil ? .mountains(.main) : .minimal(.light)

        return SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: EpisodePageData(
            permission: permission,
            user: currentUser,
            subscriberState: subscriberState,
            episode: episode,
            previousEpisodes: episode.previousEpisodes,
            date: Current.date
          ),
          description: episode.blurb,
          extraStyles: markdownBlockStyles,
          image: episode.image,
          style: .base(navStyle),
          title: "Episode #\(episode.sequence): \(episode.title)",
          usePrismJs: true
        )
    }
)

let useCreditResponse =
  fetchEpisodeForParam
    <<< validateUserEpisodePermission
    <| applyCreditMiddleware

private let fetchEpisodeForParam
  : MT<
  Tuple4<Either<String, Episode.Id>, User?, SubscriberState, Route?>,
  Tuple4<Episode, User?, SubscriberState, Route?>
  >
  = filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >=> respond(lower >>> episodeNotFoundView)
)

private let validateUserEpisodePermission
  : MT<
  Tuple4<Episode, User?, SubscriberState, Route?>,
  Tuple5<EpisodePermission, Episode, User, SubscriberState, Route?>
  >
  = { userEpisodePermission >=> $0 }
    <<< filterMap(require3 >>> pure, or: loginAndRedirect)
    <<< validateCreditRequest

let progressResponse: M<
  Tuple5<
  Either<String, Episode.Id>,
  Int,
  Models.User?,
  SubscriberState,
  Route?>
  > =
  filterMap(
    over1(episode(forParam:)) >>> require1 >>> pure,
    or: writeStatus(.notFound) >=> end
    )
    <<< filterMap(require3 >>> pure, or: loginAndRedirect)
    <| writeStatus(.ok)
    >=> end

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

private func userEpisodePermission<I, Z>(
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


private let episodeNotFoundView = { param, user, subscriberState, route in
  SimplePageLayoutData(
    currentSubscriberState: subscriberState,
    currentUser: user,
    data: (param, user, subscriberState, route),
    title: "Episode not found :("
  )
  } >>> simplePageLayout(_episodeNotFoundView)

private func _episodeNotFoundView(_: Either<String, Episode.Id>, _: User?, _: SubscriberState, _: Route?) -> Node {
  return .gridRow(
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
}

private func episode(forParam param: Either<String, Episode.Id>) -> Episode? {
  return Current.episodes()
    .first(where: {
      param.left == .some($0.slug) || param.right == .some($0.id)
    })
}
