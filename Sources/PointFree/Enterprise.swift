import Css
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import UrlFormEncoding
import Views

let enterpriseResponse: Middleware<StatusLineOpen, ResponseEnded, EnterpriseAccount.Domain, Data>
  = fetchEnterpriseAccount
    <| hole()

func fetchEnterpriseAccount(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, EnterpriseAccount?, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, EnterpriseAccount.Domain, Data> {

    return { conn in
      return Current.database.fetchEnterpriseAccount(conn.data)
        .mapExcept(requireSome)
        .run
        .map(^\.right >>> const >>> conn.map)
        .flatMap(middleware)
    }
}
