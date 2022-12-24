import Css
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

let indexFreeEpisodeEmailMiddleware: M<Tuple1<User>> =
  writeStatus(.ok)
  >=> respond({ _ in
    freeEpisodeView(
      episodes: Current.episodes(),
      today: Current.date(),
      emergencyMode: Current.envVars.emergencyMode
    )
  })

let sendFreeEpisodeEmailMiddleware:
  Middleware<
    StatusLineOpen,
    ResponseEnded,
    Tuple2<User, Episode.ID>,
    Data
  > =
    filterMap(get2 >>> fetchEpisode >>> pure, or: redirect(to: .admin(.freeEpisodeEmail())))
    <| sendFreeEpisodeEmails
    >=> redirect(to: .admin())

func fetchEpisode(_ id: Episode.ID) -> Episode? {
  return Current.episodes().first(where: { $0.id == id })
}

private func sendFreeEpisodeEmails<I>(_ conn: Conn<I, Episode>) -> IO<Conn<I, Prelude.Unit>> {

  return EitherIO { try await Current.database.fetchFreeEpisodeUsers() }
    .flatMap { users in sendEmail(forFreeEpisode: conn.data, toUsers: users) }
    .run
    .map { _ in conn.map(const(unit)) }
}

private func sendEmail(forFreeEpisode episode: Episode, toUsers users: [User]) -> EitherIO<
  Error, Prelude.Unit
> {

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

  let fireAndForget = IO { () -> Prelude.Unit in
    freeEpisodeEmailReport
      .map(const(unit))
      .parallel
      .run({ _ in })
    return unit
  }

  return lift(fireAndForget)
}
