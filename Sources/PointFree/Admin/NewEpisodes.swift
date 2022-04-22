import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import PointFreePrelude
import Prelude
import Styleguide
import Tuple

let showNewEpisodeEmailMiddleware: M<Prelude.Unit> =
  writeStatus(.ok)
    >=> respond({ _ in showNewEpisodeView })

private let showNewEpisodeView = Node.ul(
  .fragment(
    Current.episodes()
      .sorted(by: their(^\.sequence, >))
      .prefix(upTo: 1)
      .map { .li(newEpisodeEmailRowView(ep: $0)) }
  )
)

private func newEpisodeEmailRowView(ep: Episode) -> Node {
  return .p(
    .text("Episode #\(ep.sequence): \(ep.fullTitle)"),
    .form(
      attributes: [
        .action(siteRouter.path(for: .admin(.newEpisodeEmail(.send(ep.id))))),
        .method(.post)
      ],
      .textarea(attributes: [.name("subscriber_announcement"), .placeholder("Subscriber announcement")]),
      .textarea(attributes: [.name("nonsubscriber_announcement"), .placeholder("Non-subscribers announcements")]),
      .input(attributes: [.type(.submit), .name("test"), .value("Test email!")]),
      .input(attributes: [.type(.submit), .name("live"), .value("Send email!")])
    )
  )
}

let sendNewEpisodeEmailMiddleware: M<Tuple5<User, Episode.Id, String?, String?, Bool?>>
  = requireEpisode
    <<< requireIsTest
    <| sendNewEpisodeEmails
    >=> redirect(to: .admin(.index))

private let requireEpisode
  : MT<
  Tuple5<User, Episode.Id, String?, String?, Bool?>,
  Tuple5<User, Episode, String?, String?, Bool?>
  >
  = filterMap(
    over2(fetchEpisode) >>> require2 >>> pure,
    or: redirect(to: .admin(.newEpisodeEmail(.show)))
)

private let requireIsTest
  : MT<
  Tuple5<User, Episode, String?, String?, Bool?>,
  Tuple5<User, Episode, String?, String?, Bool>
  >
  = filterMap(
    require5 >>> pure,
    or: redirect(to: .admin(.newEpisodeEmail(.show)))
)

private func sendNewEpisodeEmails<I>(
  _ conn: Conn<I, Tuple5<User, Episode, String?, String? , Bool>>
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
  toUsers users: [User],
  subscriberAnnouncement: String?,
  nonSubscriberAnnouncement: String?,
  isTest: Bool
  ) -> EitherIO<Prelude.Unit, Prelude.Unit> {

  let subjectPrefix = isTest ? "[TEST] " : ""

  // A personalized email to send to each user.
  let newEpisodeEmails = users.map { user in
    lift(IO { newEpisodeEmail((episode, subscriberAnnouncement, nonSubscriberAnnouncement, user)) })
      .flatMap { nodes in
        sendEmail(
          to: [user.email],
          subject: "\(subjectPrefix)New Point-Free Episode: \(episode.fullTitle)",
          unsubscribeData: (user.id, .newEpisode),
          content: inj2(nodes)
          )
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
          adminEmailReport("New episode")(
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
