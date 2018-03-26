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

let showNewEpisodeEmailMiddleware =
  requireAdmin
    <| writeStatus(.ok)
    >-> respond(showNewEpisodeView.contramap(lower))

private let showNewEpisodeView = View<Database.User> { _ in
  ul(
    AppEnvironment.current.episodes()
      .sorted(by: their(^\.sequence, >))
      .map(li <<< newEpisodeEmailRowView.view)
  )
}

private let newEpisodeEmailRowView = View<Episode> { ep in
  p([
    text("Episode #\(ep.sequence): \(ep.title)"),

    form([action(path(to: .admin(.newEpisodeEmail(.send(ep.id, isTest: nil))))), method(.post)], [
      input([type(.submit), name("test"), value("Test email!")]),
      input([type(.submit), name("live"), value("Send email!")])
      ])
    ])
}

let sendNewEpisodeEmailMiddleware:
  Middleware<StatusLineOpen, ResponseEnded, Tuple3<Database.User?, Episode.Id, Bool?>, Data> =
  requireAdmin
    <<< filterMap(over2(fetchEpisode) >>> require2 >>> pure, or: redirect(to: .admin(.newEpisodeEmail(.show))))
    <<< filterMap(require3 >>> pure, or: redirect(to: .admin(.newEpisodeEmail(.show))))
    <| sendNewEpisodeEmails
    >-> redirect(to: .admin(.index))

private func sendNewEpisodeEmails<I>(
  _ conn: Conn<I, Tuple3<Database.User, Episode, Bool>>
  ) -> IO<Conn<I, Prelude.Unit>> {

  let (_, episode, isTest) = lower(conn.data)

  let users = isTest
    ? AppEnvironment.current.database.fetchAdmins()
    : AppEnvironment.current.database.fetchUsersSubscribedToNewsletter(.newEpisode)

  return users
    .mapExcept(bimap(const(unit), id))
    .flatMap { users in sendEmail(forNewEpisode: episode, toUsers: users, isTest: isTest) }
    .run
    .map { _ in conn.map(const(unit)) }
}

private func sendEmail(
  forNewEpisode episode: Episode,
  toUsers users: [Database.User],
  isTest: Bool
  ) -> EitherIO<Prelude.Unit, Prelude.Unit> {

  let subjectPrefix = isTest ? "[TEST] " : ""

  // A personalized email to send to each user.
  let newEpisodeEmails = users.map { user in
    lift(IO { inj2(newEpisodeEmail.view((episode, user))) })
      .flatMap { nodes in
        sendEmail(
          to: [user.email],
          subject: "\(subjectPrefix)New Point-Free Episode: \(episode.title)",
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

