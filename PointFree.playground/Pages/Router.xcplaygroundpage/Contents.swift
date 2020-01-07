import ApplicativeRouter
import Models
import Foundation
@testable import PointFree
import PointFreeRouter
import Either

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

let urlString = "http://localhost:8080/account/subscription/change"

pointFreeRouter.router.match(string: urlString)!

pointFreeRouter.router.request(
  for: .account(.subscription(.change(.show))),
  base: URL(string: "https://www.pointfree.co")
)

let userId = Encrypted(UUID().uuidString, with: Current.envVars.appSecret)!
let rssSalt = Encrypted(UUID().uuidString, with: Current.envVars.appSecret)!

pointFreeRouter.request(for: .account(.rss(userId: userId, rssSalt: rssSalt)))?.url?.path


print(
  sendEmail(
    to: adminEmails,
    subject: "[Private Rss Feed Error] TEST",
    content: inj1("test")
  ).run.perform()
)
