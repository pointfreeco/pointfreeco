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

let indexFreeEpisodeEmailMiddleware =
  requireAdmin
    <| writeStatus(.ok)
    >=> respond(freeEpisodeView.contramap(lower))

private let freeEpisodeView = View<Database.User> { _ in
  [
    h2(["Send free episode email"]),

    ul(
      Current.episodes()
        .filter((!) <<< ^\.subscriberOnly)
        .sorted(by: their(^\.sequence))
        .map(li <<< freeEpisodeEmailRowView.view)
    )
  ]
}

private let freeEpisodeEmailRowView = View<Episode> { ep in
  [
    p([
      .text(ep.title),
      form([action(path(to: .admin(.freeEpisodeEmail(.send(ep.id))))), method(.post)], [
        input([type(.submit), value("Send email!")])
        ])
      ])
  ]
}

let sendFreeEpisodeEmailMiddleware:
  Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User?, Episode.Id>, Data> =
  requireAdmin
    <<< filterMap(get2 >>> fetchEpisode >>> pure, or: redirect(to: .admin(.freeEpisodeEmail(.index))))
    <| sendFreeEpisodeEmails
    >=> redirect(to: .admin(.index))

func fetchEpisode(_ id: Episode.Id) -> Episode? {
  return Current.episodes().first(where: { $0.id == id })
}

private func sendFreeEpisodeEmails<I>(_ conn: Conn<I, Episode>) -> IO<Conn<I, Prelude.Unit>> {

  return Current.database.fetchFreeEpisodeUsers()
    .mapExcept(bimap(const(unit), id))
    .flatMap { users in
      sendEmail(forFreeEpisode: conn.data, toUsers: users)
    }
    .run
    .map { _ in conn.map(const(unit)) }
}

private func sendEmail(forFreeEpisode episode: Episode, toUsers users: [Database.User]) -> EitherIO<Prelude.Unit, Prelude.Unit> {

  // A personalized email to send to each user.
  let freeEpisodeEmails = users.map { user in
    lift(IO { inj2(freeEpisodeEmail.view((episode, user))) })
      .flatMap { nodes in
        sendEmail(
          to: [user.email],
          subject: "Free Point-Free Episode: \(episode.title)",
          unsubscribeData: (user.id, .newEpisode),
          content: nodes
          )
          .delay(.milliseconds(200))
          .retry(maxRetries: 3, backoff: { .seconds(10 * $0) })
    }
  }

  // An email to send to admins once all user emails are sent
  let freeEpisodeEmailReport = sequence(freeEpisodeEmails.map(^\.run))
    .flatMap { results in
      sendEmail(
        to: adminEmails,
        subject: "New free episode email finished sending!",
        content: inj2(
          adminEmailReport("New free episode").view(
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
    freeEpisodeEmailReport
      .map(const(unit))
      .parallel
      .run({ _ in })
    return unit
  }

  return lift(fireAndForget)
}
