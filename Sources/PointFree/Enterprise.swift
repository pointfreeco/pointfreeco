import Css
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import UrlFormEncoding
import Views

let enterpriseResponse: Middleware<StatusLineOpen, ResponseEnded, EnterpriseAccount.Domain, Data>
  = hole()
