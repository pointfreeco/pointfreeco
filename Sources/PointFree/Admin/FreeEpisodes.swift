import Css
import Dependencies
import Either
import Foundation
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import Views

extension Conn<StatusLineOpen, Void> {
  func indexFreeEpisodeEmail() -> Conn<ResponseEnded, Data> {
    @Dependency(\.date.now) var now
    @Dependency(\.episodes) var episodes
    @Dependency(\.envVars.emergencyMode) var emergencyMode

    return self.writeStatus(.ok).respond {
      freeEpisodeView(episodes: episodes(), today: now, emergencyMode: emergencyMode)
    }
  }
}

extension Conn<StatusLineOpen, Void> {
  func sendFreeEpisodeEmail(id: Episode.ID) async -> Conn<ResponseEnded, Data> {
    @Dependency(\.database) var database

    guard let episode = fetchEpisode(id)
    else { return self.redirect(to: .admin(.freeEpisodeEmail())) }

    do {
      let users = try await database.fetchFreeEpisodeUsers()
      try await sendEmail(forFreeEpisode: episode, toUsers: users).performAsync()
      return self.redirect(to: .admin())
    } catch {
      return self.redirect(to: .admin()) {
        $0.flash(.error, "Could not send free episode email.")
      }
    }
  }
}

func fetchEpisode(_ id: Episode.ID) -> Episode? {
  @Dependency(\.episodes) var episodes
  return episodes().first(where: { $0.id == id })
}

private func sendEmail(
  forFreeEpisode episode: Episode, toUsers users: [User]
) -> EitherIO<Error, Void> {

  // A personalized email to send to each user.
  let freeEpisodeEmails = users.map { user in
    lift(IO { inj2(freeEpisodeEmail((episode, user))) })
      .flatMap { nodes in
        EitherIO {
          try await sendEmail(
            to: [user.email],
            subject: "Free Point-Free Episode: \(episode.fullTitle)",
            unsubscribeData: (user.id, .newEpisode),
            content: nodes
          )
        }
        .delay(.milliseconds(200))
        .retry(maxRetries: 3, backoff: { .seconds(10 * $0) })
      }
  }

  // An email to send to admins once all user emails are sent
  let freeEpisodeEmailReport = sequence(freeEpisodeEmails.map(\.run))
    .flatMap { results in
      EitherIO {
        try await sendEmail(
          to: adminEmails,
          subject: "New free episode email finished sending!",
          content: inj2(
            adminEmailReport("New free episode")(
              (
                zip(users, results)
                  .filter(second >>> \.isLeft)
                  .map(first),

                results.count
              )
            )
          )
        )
      }
      .run
    }

  let fireAndForget = IO {
    freeEpisodeEmailReport
      .map(const(unit))
      .parallel
      .run({ _ in })
    return
  }

  return lift(fireAndForget)
}
