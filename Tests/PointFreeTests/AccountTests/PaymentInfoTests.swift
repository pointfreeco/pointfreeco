import Either
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class PaymentInfoTests: TestCase {
  override func setUp() {
    super.setUp()
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
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testInvoiceBilling() {
    var customer = Stripe.Customer.mock
    customer.sources = .mock([.right(.mock)])
    var subscription = Stripe.Subscription.teamYearly
    subscription.customer = .right(customer)
    Current = .teamYearly
    Current.stripe.fetchSubscription = const(pure(subscription))

    let conn = connection(from: request(to: .account(.paymentInfo(.show)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
