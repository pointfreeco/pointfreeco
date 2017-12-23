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

private let adminEmails = [
  "mbw234@gmail.com",
  "stephen.celis@gmail.com"
]

func requireAdmin<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.User, A>, Data> {

  return { conn in
    conn
      |> (adminEmails.contains(get1(conn.data).email.unwrap) ? middleware : redirect(to: .secretHome))
  }
}

let adminIndex =
  requireUser
    <<< requireAdmin
    <| writeStatus(.ok)
    >-> respond(adminIndexView.contramap(lower))

private let adminIndexView = View<(Database.User, Prelude.Unit)> { currentUser, _ in
  ul([
    li([
      a([href(path(to: .admin(.newEpisodeEmail(.show))))], ["Send new episode email"])
      ])
    ])
}

let showNewEpisodeEmailMiddleware =
  requireUser
    <<< requireAdmin
    <| writeStatus(.ok)
    >-> respond(showNewEpisodeView.contramap(lower))

private let showNewEpisodeView = View<(Database.User, Prelude.Unit)> { currentUser, _ in
  ul(
    episodes
      .sorted(by: ^\.sequence)
      .map { ep in
        li(newEpisodeEmailRowView.view(ep))
    }
    )
}

private let newEpisodeEmailRowView = View<Episode> { ep in
  p([
    .text(encode(ep.title)),
    form([action(path(to: .admin(.newEpisodeEmail(.send(ep.id))))), method(.post)], [
      input([type(.submit), value("Send email!")])
      ])
    ])
}

let sendNewEpisodeEmailMiddleware: Middleware<StatusLineOpen, ResponseEnded, T2<Episode.Id, Prelude.Unit>, Data> =
  requireEpisode(notFoundMiddleware: redirect(to: .admin(.newEpisodeEmail(.show))))
    <<< requireUser
    <<< requireAdmin
    <| { conn in pure(conn.map(const((conn.data.second.first.first)))) }
    >-> sendNewEpisodeEmails
    >-> redirect(to: .admin(.index))

func sendNewEpisodeEmails<I>(_ conn: Conn<I, Episode>) -> IO<Conn<I, Prelude.Unit>> {

  let episode = conn.data

  return AppEnvironment.current.database.fetchUsersSubscribedToNewEpisodeEmail()
    .mapExcept(convertToUnitError)
    .flatMap { users -> EitherIO<Prelude.Unit, SendEmailResponse> in

      // TODO: look into mailgun rate limits
      let newEpisodeEmails = users.map { user in
        sendEmail(
          to: [user.email],
          subject: "New Point-Free Episode: \(episode.title)",
          content: inj2(newEpisodeEmail.view((episode, true)))
          )
          .retry(count: 3)
      }

      zip(
        newEpisodeEmails
          .map(^\.run >>> parallel)
        )
        .map { results in
          zip(users, results)
            .filter { _, result in result.isRight }
            .map { user, _ in user }
        }
        .sequential
        .flatMap { erroredUsers in
          sendEmail(
            to: adminEmails.map(EmailAddress.init(unwrap:)),
            subject: "New episode email finished sending!",
            content: inj2(newEpisodeEmailAdminReportEmail.view((erroredUsers, users.count)))
            )
            .run
        }
        .parallel
        .run({ _ in })
      
      return throwE(unit)
    }
    .run
    .map { _ in conn.map(const(unit)) }
}

func requireEpisode<A>(
  notFoundMiddleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<Episode.Id, A>, Data>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, T2<Episode, A>, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Episode.Id, A>, Data> {

    return { middleware in
      return { conn in
        guard let episode = episodes.first(where: { $0.id.unwrap == get1(conn.data).unwrap })
          else { return conn |> notFoundMiddleware }

        return conn.map(over1(const(episode)))
          |> middleware
      }
    }
}
