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

let accountResponse: (Conn<StatusLineOpen, Prelude.Unit>) -> IO<Conn<ResponseEnded, Data>> =
  requireUser
    <| writeStatus(.ok)
    >-> respond(accountView)

private let accountView = View<Tuple2<Database.User, Prelude.Unit>> { data in
  [
    h1([.text(encode("Welcome \(data.first.name)"))]),
    a([href(path(to: .team))], ["Your team"])
  ]
}
