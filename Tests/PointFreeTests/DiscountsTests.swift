import Either
import Html
import HttpPipeline
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import XCTest

private func secureRequest(_ urlString: String) -> URLRequest {
  return URLRequest(url: URL(string: urlString)!)
    |> \.allHTTPHeaderFields .~ ["X-Forwarded-Proto": "https"]
}

class DiscountsTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
    record=true
  }

  func testDiscounts_LoggedOut() {
    assertSnapshot(
      matching: connection(from: request(with: secureRequest("http://localhost:8080/discounts/blobfest")))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_PercentOff_Forever() {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "50% off forever",
      rate: .percentOff(50),
      valid: true
    )
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.fetchCoupon .~ const(pure(fiftyPercentOffForever))
    )

    assertSnapshot(
      matching: connection(from: request(with: secureRequest("http://localhost:8080/discounts/blobfest"), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }
}
