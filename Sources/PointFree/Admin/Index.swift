import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

let adminEmails = [
  "mbw234@gmail.com",
  "stephen.celis@gmail.com"
]

func requireAdmin<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User?, A>, Data> {

    return filterMap(require1 >>> pure, or: loginAndRedirect)
      <<< filter(get1 >>> ^\.isAdmin, or: redirect(to: .home))
      <| middleware
}

let adminIndex =
  requireAdmin
    <| writeStatus(.ok)
    >-> respond(adminIndexView.contramap(lower))

private let adminIndexView = View<Database.User> { currentUser in
  ul([
    li([
      a([href(path(to: .admin(.newEpisodeEmail(.show))))], ["Send new episode email"])
      ])
    ])
}

let showNewEpisodeEmailMiddleware =
  requireAdmin
    <| writeStatus(.ok)
    >-> respond(showNewEpisodeView.contramap(lower))

private let showNewEpisodeView = View<Database.User> { currentUser in
  ul(
    AppEnvironment.current.episodes()
      .sorted(by: their(^\.sequence))
      .map(li <<< newEpisodeEmailRowView.view)
  )
}

private let newEpisodeEmailRowView = View<Episode> { ep in
  p([
    .text(encode(ep.title)),
    form([action(path(to: .admin(.newEpisodeEmail(.send(ep.id))))), method(.post)], [
      input([type(.submit), value("Send email!")])
      ])
    ])
}

let sendNewEpisodeEmailMiddleware:
  Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User?, Episode.Id>, Data> =
  requireAdmin
    <<< filterMap(get2 >>> fetchEpisode >>> pure, or: redirect(to: .admin(.newEpisodeEmail(.show))))
    <| sendNewEpisodeEmails
    >-> redirect(to: .admin(.index))

func fetchEpisode(_ id: Episode.Id) -> Episode? {
  return AppEnvironment.current.episodes().first(where: { $0.id.unwrap == id.unwrap })
}

private func sendNewEpisodeEmails<I>(_ conn: Conn<I, Episode>) -> IO<Conn<I, Prelude.Unit>> {

  return AppEnvironment.current.database.fetchUsersSubscribedToNewsletter(.newEpisode)
    .mapExcept(bimap(const(unit), id))
    .flatMap { users in sendEmail(forNewEpisode: conn.data, toUsers: users) }
    .run
    .map { _ in conn.map(const(unit)) }
}

private func sendEmail(forNewEpisode episode: Episode, toUsers users: [Database.User]) -> EitherIO<Prelude.Unit, Prelude.Unit> {

  // A personalized email to send to each user.
  let newEpisodeEmails = users.map { user in
    lift(IO { inj2(newEpisodeEmail.view((episode, user))) })
      .flatMap { nodes in
        sendEmail(
          to: [user.email],
          subject: "New Point-Free Episode: \(episode.title)",
          unsubscribeData: (user.id, .newEpisode),
          content: nodes
          )
          .delay(.milliseconds(200))
          .retry(maxRetries: 3, backoff: { .seconds(10 * $0) })
    }
  }

  // An email to send to admins once all user emails are sent
  let newEpisodeEmailReport = sequence(newEpisodeEmails.map(^\.run))
    .flatMap { results in
      sendEmail(
        to: adminEmails.map(EmailAddress.init(unwrap:)),
        subject: "New episode email finished sending!",
        content: inj2(
          newEpisodeEmailAdminReportEmail.view(
            (
              zip(users, results)
                .filter(second >>> ^\.isLeft)
                .map(first),

              results.count
            )
          )
        )
        )
        .run
  }

  let fireAndForget = IO { () -> Prelude.Unit in
    newEpisodeEmailReport
      .map(const(unit))
      .parallel
      .run({ _ in })
    return unit
  }

  return lift(fireAndForget)
}
