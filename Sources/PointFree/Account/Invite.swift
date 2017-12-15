import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import UrlFormEncoding

let showInviteResponse: (Conn<StatusLineOpen, UUID>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> respond(text: "show invite")
