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

func acceptInviteResponse(_ conn: Conn<StatusLineOpen, Database.TeamInvite.Id>) -> IO<Conn<ResponseEnded, Data>> {

  return AppEnvironment.current.database.fetchTeamInvite(conn.data)
    .run
    .map(requireSome)
    .flatMap { errorOrTeamInvite -> IO<Conn<ResponseEnded, Data>> in
      switch errorOrTeamInvite {
      case .left:
        // couldn't fetch invite
        return conn |> redirect(to: path(to: .invite(.show(conn.data))))
      case .right:
        // TODO: subscribe user?
        return conn |> redirect(to: path(to: .account))
      }
  }
}

let sendInviteResponse =
  requireUser
    <| _sendInviteResponse

func _sendInviteResponse(_ conn: Conn<StatusLineOpen, Tuple2<Database.User, EmailAddress?>>) -> IO<Conn<ResponseEnded, Data>> {
  guard let email = get2 <| conn.data else { return conn |> redirect(to: path(to: .team)) }
  let inviter = get1 <| conn.data

  return AppEnvironment.current.database.insertTeamInvite(email, inviter.id)
    .run
    .flatMap { errorOrTeamInvite -> IO<Conn<ResponseEnded, Data>> in
      switch errorOrTeamInvite {
      case .left:
        return conn |> redirect(to: .team)

      case let .right(invite):
        parallel(
          sendEmail(
            to: [email],
            subject: "You’re invited to join \(inviter.name)’s team on Point-Free",
            content: inj2(teamInviteEmailView.view((inviter, invite)))
            )
            .run
          ).run({ _ in })

        return conn |> redirect(to: .team)
      }
  }
}

let showInviteResponse: (Conn<StatusLineOpen, Database.TeamInvite.Id>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> respond(showInviteView)

private let showInviteView = View<Database.TeamInvite.Id> { inviteId in
  [
  p([
    "You must be logged in to accept this invitation. Would you like to log in with GitHub?"
    ]),
  a([href(url(to: .login(redirect: url(to: .invite(.show(inviteId))))))], ["Sign up with GitHub"]),

  p([
    "Or if you are logged in, do you accept?"
    ]),
  form([action(path(to: .invite(.accept(inviteId)))), method(.post)], [
    input([type(.submit), value("Accept")])
    ])
  ]
}
