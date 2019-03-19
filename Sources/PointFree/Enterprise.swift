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

let enterpriseAcceptInviteMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, EnterpriseAccount.Domain, Encrypted<String>>,
  Data
  >
  = filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(validateSignature >>> pure, or: redirect(to: .home))
    <<< filterMap(verifyDomain >>> pure, or: redirect(to: .home))
    <| redirect(to: .account(.index))

private func verifyDomain<A, Z>(
  _ data: T4<A, EnterpriseAccount.Domain, EnterpriseRequest, Z>
  ) -> T4<A, EnterpriseAccount.Domain, EnterpriseRequest, Z>? {

  let (domain, request) = (get2(data), get3(data))

  return request.email.rawValue.lowercased().hasSuffix(domain.rawValue.lowercased())
    ? data
    : nil
}

private func validateSignature<A, Z>(
  data: T4<A, EnterpriseAccount.Domain, Encrypted<String>, Z>
  ) -> T4<A, EnterpriseAccount.Domain, EnterpriseRequest, Z>? {

  func sequence3<A, B, C, Z>(_ tuple: T4<A, B, C?, Z>) -> T4<A, B, C, Z>? {
    return get3(tuple).map { get1(tuple) .*. get2(tuple) .*. $0 .*. rest(tuple) }
  }

  return sequence3(
    data
      |> over3({
        $0.decrypt(with: Current.envVars.appSecret)
          .map(EmailAddress.init(rawValue:))
          .map(EnterpriseRequest.init(email:))
      })
  )
}

func fetchEnterpriseAccount(_ domain: EnterpriseAccount.Domain) -> IO<EnterpriseAccount?> {
  return Current.database.fetchEnterpriseAccountForDomain(domain)
    .mapExcept(requireSome)
    .run
    .map(^\.right)
}

func enterpriseView(_ account: EnterpriseAccount) -> [Node] {
  return []
}
