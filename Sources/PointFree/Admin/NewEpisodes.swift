import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import StyleguideV2
import Views

func showNewEpisodeEmailMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  @Dependency(\.episodes) var episodes
  let latestEpisodes = episodes()
    .sorted { $0.sequence > $1.sequence }
    .prefix(upTo: 1)
  return conn.writeStatus(.ok)
    .respondV2(layoutData: SimplePageLayoutData(title: "New episode email")) {
      AdminNewEpisodeEmailView(episodes: Array(latestEpisodes))
    }
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
