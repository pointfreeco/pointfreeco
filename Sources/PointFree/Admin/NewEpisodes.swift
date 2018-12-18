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
import View

let showNewEpisodeEmailMiddleware =
  requireAdmin
    <| writeStatus(.ok)
    >=> respond(showNewEpisodeView.contramap(lower))

private let showNewEpisodeView = View<Database.User> { _ in
  ul(
    Current.episodes()
      .sorted(by: their(^\.sequence, >))
      .prefix(upTo: 1)
      .map(li <<< newEpisodeEmailRowView.view)
  )
}

private let newEpisodeEmailRowView = View<Episode> { ep in
  p([
    .text("Episode #\(ep.sequence): \(ep.title)"),

    form([action(path(to: .admin(.newEpisodeEmail(.send(ep.id, subscriberAnnouncement: nil, nonSubscriberAnnouncement: nil, isTest: nil))))), method(.post)], [

      textarea([name("subscriber_announcement"), placeholder("Subscriber announcement")]),
      textarea([name("nonsubscriber_announcement"), placeholder("Non-subscribers announcements")]),

      input([type(.submit), name("test"), value("Test email!")]),
      input([type(.submit), name("live"), value("Send email!")])
      ])
    ])
}

let sendNewEpisodeEmailMiddleware:
  Middleware<StatusLineOpen, ResponseEnded, Tuple5<Database.User?, Episode.Id, String?, String?, Bool?>, Data> =
  requireAdmin
    <<< filterMap(
      over2(fetchEpisode) >>> require2 >>> pure,
      or: redirect(to: .admin(.newEpisodeEmail(.show)))
    )
    <<< filterMap(
      require5 >>> pure,
      or: redirect(to: .admin(.newEpisodeEmail(.show)))
    )
    <| sendNewEpisodeEmails
    >=> redirect(to: .admin(.index))

private func sendNewEpisodeEmails<I>(
  _ conn: Conn<I, Tuple5<Database.User, Episode, String?, String? , Bool>>
  ) -> IO<Conn<I, Prelude.Unit>> {

  let (_, episode, subscriberAnnouncement, nonSubscriberAnnouncement, isTest) = lower(conn.data)

  let users = isTest
    ? Current.database.fetchAdmins()
    : Current.database.fetchUsersSubscribedToNewsletter(.newEpisode, nil)

  return users
    .withExcept(const(unit))
    .flatMap { users in
      sendEmail(
        forNewEpisode: episode,
        toUsers: users,
        subscriberAnnouncement: subscriberAnnouncement,
        nonSubscriberAnnouncement: nonSubscriberAnnouncement,
        isTest: isTest
      )
    }
    .run
    .map { _ in conn.map(const(unit)) }
}

private func sendEmail(
  forNewEpisode episode: Episode,
  toUsers users: [Database.User],
  subscriberAnnouncement: String?,
  nonSubscriberAnnouncement: String?,
  isTest: Bool
  ) -> EitherIO<Prelude.Unit, Prelude.Unit> {

  let subjectPrefix = isTest ? "[TEST] " : ""

  // A personalized email to send to each user.
  let newEpisodeEmails = users.map { user in
    lift(IO { newEpisodeEmail.view((episode, subscriberAnnouncement, nonSubscriberAnnouncement, user)) })
      .flatMap { nodes in
        sendEmail(
          to: [user.email],
          subject: "\(subjectPrefix)New Point-Free Episode: \(episode.title)",
          unsubscribeData: (user.id, .newEpisode),
          content: inj2(nodes)
          )
          .delay(.milliseconds(200))
          .retry(maxRetries: 3, backoff: { .seconds(10 * $0) })
    }
  }

  // An email to send to admins once all user emails are sent
  let newEpisodeEmailReport = sequence(newEpisodeEmails.map(^\.run))
    .flatMap { results in
      sendEmail(
        to: adminEmails,
        subject: "New episode email finished sending!",
        content: inj2(
          adminEmailReport("New episode").view(
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
