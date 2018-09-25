import Foundation
@testable import PointFree

let urlString = "http://localhost:8080/account/subscription/change"

router.match(string: urlString)!

router.request(
  for: .account(.subscription(.change(.show))),
  base: URL(string: "https://www.pointfree.co")
)
