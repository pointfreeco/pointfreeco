import Css
import Dependencies
import Either
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

func showNewEpisodeEmailMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  conn.writeStatus(.ok)
    .respond(showNewEpisodeView)
}

private func showNewEpisodeView() -> Node {
  @Dependency(\.episodes) var episodes

  return .ul(
    .fragment(
      episodes()
        .sorted(by: their(\.sequence, >))
        .prefix(upTo: 1)
        .map { .li(newEpisodeEmailRowView(ep: $0)) }
    )
  )
}

private func newEpisodeEmailRowView(ep: Episode) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .p(
    .text("Episode #\(ep.sequence): \(ep.fullTitle)"),
    .form(
      attributes: [
        .action(siteRouter.path(for: .admin(.newEpisodeEmail(.send(ep.id))))),
        .method(.post),
      ],
      .textarea(attributes: [
        .name("subscriber_announcement"), .placeholder("Subscriber announcement"),
      ]),
      .textarea(attributes: [
        .name("nonsubscriber_announcement"), .placeholder("Non-subscribers announcements"),
      ]),
      .input(attributes: [.type(.submit), .name("test"), .value("Test email!")]),
      .input(attributes: [.type(.submit), .name("live"), .value("Send email!")])
    )
  )
}

func sendNewEpisodeEmailMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  episodeID: Episode.ID,
  subscriberAnnouncement: String,
  nonSubscriberAnnouncement: String,
  isTest: Bool
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.episodes) var episodes
  guard let episode = episodes().first(where: { $0.id == episodeID })
  else { return conn.redirect(to: .admin(.newEpisodeEmail(.show))) }

  Task {
    try? await sendNewEpisodeEmails(
      episode: episode,
      subscriberAnnouncement: subscriberAnnouncement,
      nonSubscriberAnnouncement: nonSubscriberAnnouncement,
      isTest: isTest
    )
  }
  return conn.redirect(to: .admin())
}

private func sendNewEpisodeEmails(
  episode: Episode,
  subscriberAnnouncement: String,
  nonSubscriberAnnouncement: String,
  isTest: Bool
) async throws {
  @Dependency(\.database) var database

  let users = try await isTest
    ? database.fetchAdmins()
    : database.fetchUsers(subscribedToNewsletter: .newEpisode, subscriberState: nil)

  let subjectPrefix = isTest ? "[TEST] " : ""
  var failedUsers: [User] = []

  for user in users {
    do {
      let nodes = newEpisodeEmail((episode, subscriberAnnouncement, nonSubscriberAnnouncement, user))
      try await retry(maxRetries: 3, backoff: { .seconds(10 * $0) }) {
        _ = try await sendEmail(
          to: [user.email],
          subject: "\(subjectPrefix)New Point-Free Episode: \(episode.fullTitle)",
          unsubscribeData: (user.id, .newEpisode),
          content: inj2(nodes)
        )
      }
    } catch {
      failedUsers.append(user)
    }
  }

  _ = try? await sendEmail(
    to: adminEmails,
    subject: "New episode email finished sending!",
    content: inj2(
      adminEmailReport("New episode")(
        (
          failedUsers,
          users.count
        )
      )
    )
  )
}
