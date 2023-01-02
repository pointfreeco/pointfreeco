import Dependencies
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

@MainActor
class PaymentInfoTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testRender() async throws {
    let conn = connection(from: request(to: .account(.paymentInfo()), session: .loggedIn))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testNoBillingInfo() async throws {
    var customer = Stripe.Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: nil)
    var subscription = Stripe.Subscription.teamYearly
    subscription.customer = .right(customer)

    await withDependencies {
      $0.teamYearly()
      $0.stripe.fetchSubscription = { _ in subscription }
    } operation: {
      let conn = connection(from: request(to: .account(.paymentInfo()), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }
}
