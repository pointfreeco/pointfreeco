import HttpPipeline
@testable import PointFree
import Prelude
import Optics
import Foundation
import PointFreeMocks
import Either

// Bootstrap

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()

// Server

let user = Database.User.mock
  |> \.episodeCreditCount .~ 0
  |> \.id .~ .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

Current = .mock
  |> \.database.fetchUserById .~ const(pure(.some(user)))
  |> \.stripe.fetchSubscription .~ const(pure(.individualMonthly))

run(siteMiddleware, on: Current.envVars.port, gzip: true)
