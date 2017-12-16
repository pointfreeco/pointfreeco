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
import UrlFormEncoding

let teamResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  requireUser
    <| writeStatus(.ok)
    >-> respond(teamView)

private let teamView = View<Tuple2<Database.User, Prelude.Unit>> { data in
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
    ul([
      li([
        "Brandon Williams",
        a([href("#")], [" Resend "]),
        a([href("#")], [" Revoke "])
        ]),
      ]),

    h1(["Invite more"]),
    p(["You have 10 open slots. Invite a team member below:"]),
    form([action(path(to: .invite(.send(nil)))), method(.post)], [
      input([type(.email), name("email")]),
      input([type(.submit), value("Add team member")])
      ])
  ]
}
