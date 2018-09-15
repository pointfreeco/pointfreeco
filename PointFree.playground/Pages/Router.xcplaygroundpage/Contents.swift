import ApplicativeRouter
import Foundation
import Prelude
@testable import PointFree

//let urlString = "http://localhost:8080/account/subscription/change"
//
//router.match(string: urlString)!
//
//router.request(
//  for: .account(.subscription(.change(.show))),
//  base: URL(string: "https://www.pointfree.co")
//)


private let accountRouters: [Router<Route.Account>] = [
  .confirmEmailChange
    <¢> get %> lit("account") %> lit("confirm-email-change")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, .tagged))
    <% end
]
let accountRouter = accountRouters.reduce(.empty, <|>)

private let routers: [Router<Route>] = [
  .account
    <¢> lit("account") %> accountRouter
]
let _router = routers.reduce(.empty, <|>)

_router.absoluteString(for: Route.account(Route.Account.invoices(Route.Account.Invoices.index)))

//_router.absoluteString(for: Route.account(Route.Account.confirmEmailChange(userId: Database.User.Id.init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!), emailAddress: "mbw234@gmail.com")))
