import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

let teamResponse =
  requireUser
    <| { conn in
      sequential(
        // Fetch invites and teammates in parallel.
        zip(
          parallel(AppEnvironment.current.database.fetchTeamInvites(conn.data.first.id).run)
            .map { $0.right ?? [] },
          parallel(AppEnvironment.current.database.fetchSubscriptionTeammatesByOwnerId(conn.data.first.id).run)
            .map { $0.right ?? [] }
          )
        )
        .map { conn.map(const(($0 .*. $1 .*. conn.data))) }
    }
    >-> writeStatus(.ok)
    >-> respond(teamView.contramap(lower))

private let teamView = View<([Database.TeamInvite], [Database.User], Database.User, Prelude.Unit)> { invites, teammates, currentUser, _ in
  [
    h1(["Your team"]),
    ul(
      teammates.map { teammate in
        li([
          .text(encode(teammate.name)),
          a([href("#")], ["Remove"]),
          ])
      }
    ),

    h1(["Current invites"]),
    ul(
      invites.map { invite in
        li([
          .text(encode(invite.email.unwrap)),
          " ",
          form([action(path(to: .invite(.resend(invite.id)))), method(.post)], [
            input([type(.submit), value("Resend")])
            ]),
          " ",
          form([action(path(to: .invite(.revoke(invite.id)))), method(.post)], [
            input([type(.submit), value("Revoke")])
            ]),
          ])
      }
    ),

    h1(["Invite more"]),
    p(["You have 10 open slots. Invite a team member below:"]),
    form([action(path(to: .invite(.send(nil)))), method(.post)], [
      input([type(.email), name("email")]),
      input([type(.submit), value("Add team member")])
      ])
  ]
}
