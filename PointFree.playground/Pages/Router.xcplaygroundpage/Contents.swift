import Foundation
@testable import PointFree
import Either

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

let urlString = "http://localhost:8080/account/subscription/change"

router.match(string: urlString)!

router.request(
  for: .account(.subscription(.change(.show))),
  base: URL(string: "https://www.pointfree.co")
)

let userId = Database.User.Id.init(rawValue: UUID())
let rssSalt = Database.User.RssSalt.init(rawValue: UUID())

router.request(for: Route.account(Route.Account.rss(userId: userId, rssSalt: rssSalt)))?.url?.path


print(
sendEmail(
  to: adminEmails,
  subject: "[Private Rss Feed Error] TEST",
  content: inj1("test")
  ).run.perform()
)
