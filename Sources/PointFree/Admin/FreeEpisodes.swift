import Css
import Dependencies
import Either
import Foundation
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Styleguide
import Views

func indexFreeEpisodeEmailMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  conn.writeStatus(.ok)
    .respond {
      @Dependency(\.date.now) var now
      @Dependency(\.episodes) var episodes
      @Dependency(\.envVars.emergencyMode) var emergencyMode

      return freeEpisodeView(
        episodes: episodes(),
        today: now,
        emergencyMode: emergencyMode
      )
    }
}

func sendFreeEpisodeEmailMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  episodeID: Episode.ID
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.episodes) var episodes
  guard let episode = episodes().first(where: { $0.id == episodeID })
  else { return conn.redirect(to: .admin(.freeEpisodeEmail())) }

  Task {
    try? await sendFreeEpisodeEmails(episode: episode)
  }
  return conn.redirect(to: .admin())
}

private func sendFreeEpisodeEmails(episode: Episode) async throws {
  @Dependency(\.database) var database

  let users = try await database.fetchFreeEpisodeUsers()
  var failedUsers: [User] = []

  for user in users {
    do {
      try await Task.sleep(for: .milliseconds(200))
      let nodes = freeEpisodeEmail((episode, user))
      try await retry(maxRetries: 3, backoff: { .seconds(10 * $0) }) {
        _ = try await sendEmail(
          to: [user.email],
          subject: "Free Point-Free Episode: \(episode.fullTitle)",
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
    subject: "New free episode email finished sending!",
    content: inj2(
      adminEmailReport("New free episode")(
        (
          failedUsers,
          users.count
        )
      )
    )
  )
}

private func retry<R>(
  maxRetries: Int,
  backoff: (Int) -> Duration,
  operation: () async throws -> R
) async throws -> R {
  var attempt = 0
  while true {
    do {
      return try await operation()
    } catch {
      attempt += 1
      if attempt > maxRetries { throw error }
      try await Task.sleep(for: backoff(attempt))
    }
  }
}
