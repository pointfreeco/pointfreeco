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
import UrlFormEncoding

let showInviteMiddleware =
  requireTeamInvite
    <| currentUserMiddleware
    >-> writeStatus(.ok)
    >-> respond(showInviteView)

let revokeInviteMiddleware =
  requireTeamInvite
    <<< requireUser
    <| { conn in
      AppEnvironment.current.database.deleteTeamInvite(get2(conn.data).id)
        .run
        .flatMap(const(conn |> redirect(to: path(to: .team))))
}

let resendInviteMiddleware =
  requireTeamInvite
    <<< requireUser
    <| { conn in
      parallel(sendInviteEmail(invite: get2(conn.data), inviter: get1(conn.data)).run)
        .run({ _ in })
      return conn |> redirect(to: path(to: .team))
}

let acceptInviteMiddleware =
  requireTeamInvite <| { conn in
    // todo: dont need to do this fetch anymore since `requireTeamInvite` takes care of it
    AppEnvironment.current.database.fetchTeamInvite(conn.data.id)
      .run
      .map(requireSome)
      .flatMap { errorOrTeamInvite -> IO<Conn<ResponseEnded, Data>> in
        switch errorOrTeamInvite {
        case .left:
          // couldn't fetch invite
          return conn
            |> redirect(to: path(to: .invite(.show(conn.data.id))))

        case .right:
          // TODO: subscribe user
          // TOOD: send email to inviter
          return conn
            |> redirect(to: path(to: .account))
        }
    }
}

let sendInviteMiddleware =
  requireUser
    <| { (conn: Conn<StatusLineOpen, Tuple2<Database.User, EmailAddress?>>) in

      guard let email = get2 <| conn.data else { return conn |> redirect(to: path(to: .team)) }
      let inviter = get1 <| conn.data

      return AppEnvironment.current.database.insertTeamInvite(email, inviter.id)
        .run
        .flatMap { errorOrTeamInvite -> IO<Conn<ResponseEnded, Data>> in
          switch errorOrTeamInvite {
          case .left:
            return conn |> redirect(to: .team)

          case let .right(invite):
            parallel(sendInviteEmail(invite: invite, inviter: inviter).run)
              .run({ _ in })

            return conn |> redirect(to: .team)
          }
      }
}

private let showInviteView = View<Tuple2<Database.User?, Database.TeamInvite>> { data in

  get1(data)
    .map { showInviteLoggedInView.view($0 .*. get2(data)) }
    ?? showInviteLoggedOutView.view(get2(data))
}

private let showInviteLoggedOutView = View<Database.TeamInvite> { invite in
  [
    p(["You must be logged in to accept this invitation. Would you like to log in with GitHub?"]),

    a([href(url(to: .login(redirect: url(to: .invite(.show(invite.id))))))], ["Sign up with GitHub"]),
    ]
}

private let showInviteLoggedInView = View<Tuple2<Database.User, Database.TeamInvite>> { data in
  [
    p(["Do you accept this invite?"]),

    form([action(path(to: .invite(.accept(get2(data).id)))), method(.post)], [
      input([type(.submit), value("Accept")])
      ])
  ]
}

private let inviteNotFound = View<Prelude.Unit> { _ in
  [
    p([
      "We couldn’t find that invite. Perhaps it was already taken, or it may have been revoked by the sender."
      ]),
    a([href(path(to: .secretHome))], ["Go home"])
  ]
}

private func requireTeamInvite(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Database.TeamInvite, Data>
  ) -> Middleware<StatusLineOpen, ResponseEnded, Database.TeamInvite.Id, Data> {

  return { conn in
    AppEnvironment.current.database.fetchTeamInvite(conn.data)
      .run
      .map(requireSome)
      .flatMap { errorOrTeamInvite in
        switch errorOrTeamInvite {
        case .left:
          return conn.map(const(unit))
            |> writeStatus(.notFound)
            >-> respond(inviteNotFound)

        case let .right(teamInvite):
          return conn.map(const(teamInvite))
            |> middleware
        }
    }
  }
}

private func sendInviteEmail(
  invite: Database.TeamInvite, inviter: Database.User
  )
  ->  EitherIO<Prelude.Unit, SendEmailResponse> {

    return sendEmail(
      to: [invite.email],
      subject: "You’re invited to join \(inviter.name)’s team on Point-Free",
      content: inj2(teamInviteEmailView.view((inviter, invite)))
    )
}
