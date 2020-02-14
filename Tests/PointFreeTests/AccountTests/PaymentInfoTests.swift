import Either
import HttpPipeline
import Models
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
#if !os(Linux)
import WebKit
#endif
import XCTest

class PaymentInfoTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record=true
  }

  func testRender() {
    let conn = connection(from: request(to: .account(.paymentInfo(.show)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testInvoiceBilling() {
    let customer = Stripe.Customer.mock
      |> (\Stripe.Customer.sources) .~ .mock([.right(.mock)])
    let subscription = Stripe.Subscription.teamYearly
      |> (\Stripe.Subscription.customer) .~ .right(customer)
    Current = .teamYearly
      |> (\Environment.stripe.fetchSubscription) .~ const(pure(subscription))

    let conn = connection(from: request(to: .account(.paymentInfo(.show)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
