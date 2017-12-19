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

let accountResponse =
  requireUser
    <| writeStatus(.ok)
    >-> respond(accountView.contramap(lower))

private let accountView = View<(Database.User, Prelude.Unit)> { currentUser, _ in
  [
    h1([.text(encode("Welcome \(currentUser.name)"))]),
    a([href(path(to: .team(.show)))], ["Your team"])
  ]
}
