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
import View
import Views

let enterpriseResponse: Middleware<StatusLineOpen, ResponseEnded, EnterpriseAccount.Domain, Data>
  = fetchEnterpriseAccount
    <<< filterMap(pure, or: redirect(to: .home))
    <| writeStatus(.ok)
    >=> respond(
      view: View(enterpriseView),
      layoutData: { enterpriseAccount in
        SimplePageLayoutData(
          currentUser: nil,
          data: enterpriseAccount,
          title: "Point-Free 🤝 \(enterpriseAccount.companyName)"
        )
    }
)

func fetchEnterpriseAccount(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, EnterpriseAccount?, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, EnterpriseAccount.Domain, Data> {

    return { conn in
      Current.database.fetchEnterpriseAccount(conn.data)
        .mapExcept(requireSome)
        .run
        .map(^\.right >>> const >>> conn.map)
        .flatMap(middleware)
    }
}

func enterpriseView(_ account: EnterpriseAccount) -> [Node] {
  return []
}
