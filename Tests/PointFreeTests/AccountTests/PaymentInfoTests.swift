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

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: await siteMiddleware(conn),
          as: [
            "desktop": .connWebView(size: .init(width: 1080, height: 2000)),
            "mobile": .connWebView(size: .init(width: 400, height: 2000)),
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
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  func testUpdate() async throws {
    await withDependencies {
      $0.failing()
      $0.database.fetchEnterpriseAccountForSubscription = { _ in throw unit }
      $0.database.fetchEpisodeProgresses = { _ in [] }
      $0.database.fetchLivestreams = { [] }
      $0.database.sawUser = { _ in }
      $0.database.fetchSubscriptionByOwnerId = { _ in .mock }
      $0.database.fetchSubscriptionById = { _ in .mock }
      $0.database.fetchUserById = { _ in .mock }
      $0.stripe.attachPaymentMethod = { _, _ in .mock }
      $0.stripe.fetchInvoices = { _, _ in .mock([]) }
      $0.stripe.fetchSubscription = { _ in .individualMonthly }
      $0.stripe.updateCustomer = { _, _ in .mock }
    } operation: {
      let conn = connection(
        from: request(to: .account(.paymentInfo(.update("pm_test"))), session: .loggedIn)
      )
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  func testUpdate_pastDue() async throws {
    await withDependencies {
      $0.failing()
      $0.database.fetchEnterpriseAccountForSubscription = { _ in throw unit }
      $0.database.fetchEpisodeProgresses = { _ in [] }
      $0.database.fetchLivestreams = { [] }
      $0.database.sawUser = { _ in }
      $0.database.fetchSubscriptionByOwnerId = { _ in .pastDue }
      $0.database.fetchSubscriptionById = { _ in .pastDue }
      $0.database.fetchUserById = { _ in .mock }
      $0.database.updateStripeSubscription = { _ in .mock }
      $0.stripe.attachPaymentMethod = { _, _ in .mock }
      $0.stripe.fetchInvoices = { _, _ in .mock([.pastDue]) }
      $0.stripe.payInvoice = { _ in .mock(charge: .right(.mock)) }
      $0.stripe.fetchSubscription = { _ in
        update(.individualMonthly) { $0.status = .pastDue }
      }
      $0.stripe.updateCustomer = { _, _ in .mock }
    } operation: {
      let conn = connection(
        from: request(to: .account(.paymentInfo(.update("pm_test"))), session: .loggedIn)
      )
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }
}
