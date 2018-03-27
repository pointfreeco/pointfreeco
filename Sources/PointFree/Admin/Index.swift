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
      a([href(path(to: .admin(.newEpisodeEmail(.show))))], ["Send new episode email"]),
      ]),

    li([
      a([href(path(to: .admin(.episodeCredits(.show))))], ["Send episode credits"])
      ]),

    li([
      a([href(path(to: .admin(.freeEpisodeEmail(.index))))], ["Send free episode email"]),
      ])
    ])
}

let showNewEpisodeEmailMiddleware =
  requireAdmin
    <| writeStatus(.ok)
    >-> respond(showNewEpisodeView.contramap(lower))

private let showNewEpisodeView = View<Database.User> { _ in
  ul(
    AppEnvironment.current.episodes()
      .sorted(by: their(^\.sequence))
      .map(li <<< newEpisodeEmailRowView.view)
  )
}

private let newEpisodeEmailRowView = View<Episode> { ep in
  p([
    .text(encode(ep.title)),
    form([action(path(to: .admin(.newEpisodeEmail(.send(ep.id, test: nil))))), method(.post)], [
      button([], ["Send email!"]),
      button([name("test"), value("true")], ["Send test email!"]),
      ])
    ])
}

let sendNewEpisodeEmailMiddleware:
  Middleware<StatusLineOpen, ResponseEnded, Tuple3<Database.User?, Episode.Id, Bool?>, Data> =
  requireAdmin
    <<< filterMap(over2(fetchEpisode) >>> sequence2 >>> pure, or: redirect(to: .admin(.newEpisodeEmail(.show))))
    <| sendNewEpisodeEmails
    >-> redirect(to: .admin(.index))

private func sendNewEpisodeEmails<I>(_ conn: Conn<I, Tuple3<Database.User, Episode, Bool?>>) -> IO<Conn<I, Prelude.Unit>> {

  let (_, episode, test) = lower(conn.data)

  return AppEnvironment.current.database.fetchUsersSubscribedToNewsletter(.newEpisode)
    .mapExcept(bimap(const(unit), id))
    .flatMap { users in sendEmail(forNewEpisode: episode, toUsers: users) }
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
