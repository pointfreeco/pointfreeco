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
import Tuple
import UrlFormEncoding
import View
import Views

let enterpriseLandingResponse: Middleware<StatusLineOpen, ResponseEnded, EnterpriseAccount.Domain, Data>
  = filterMap(fetchEnterpriseAccount, or: redirect(to: .home))
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

let enterpriseRequestMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<EnterpriseAccount.Domain, EnterpriseRequest>, Data>
  = filterMap(over1(fetchEnterpriseAccount) >>> sequence1 >>> map(require1), or: redirect(to: .home))
    <| hole()

func fetchEnterpriseAccount(_ domain: EnterpriseAccount.Domain) -> IO<EnterpriseAccount?> {
  return Current.database.fetchEnterpriseAccount(domain)
    .mapExcept(requireSome)
    .run
    .map(^\.right)
}

func enterpriseView(_ account: EnterpriseAccount) -> [Node] {
  return []
}
