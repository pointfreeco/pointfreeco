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

let teamResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  requireUser
    <| fetchTeamInvites
    >-> writeStatus(.ok)
    >-> respond(teamView)

private func fetchTeamInvites<I>(
  _ conn: Conn<I, Tuple2<Database.User, Prelude.Unit>>
  )
  -> IO<Conn<I, Tuple3<[Database.TeamInvite], Database.User, Prelude.Unit>>> {

    return AppEnvironment.current.database.fetchTeamInvites(conn.data.first.id)
      .run
      .map { conn.map(const(($0.right ?? []) .*. conn.data)) }
}

private let teamView = View<Tuple3<[Database.TeamInvite], Database.User, Prelude.Unit>> { data in
  [
    h1(["Your team"]),
    ul([
      li([
        "Stephen Celis",
        a([href("#")], [" Remove "]),
        ]),
      li([
        "Andrew Cornett",
        a([href("#")], [" Remove "]),
        ]),
      ]),

    h1(["Current invites"]),
    ul(
      get1(data).map { invite in
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
