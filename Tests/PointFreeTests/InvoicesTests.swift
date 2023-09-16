import Dependencies
import Either
import HttpPipeline
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree
@testable import Stripe

#if !os(Linux)
  import WebKit
#endif

final class InvoicesTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testInvoices() async throws {
    let conn = connection(from: request(to: .account(.invoices()), session: .loggedIn))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: await siteMiddleware(conn),
          as: [
            "desktop": .connWebView(size: .init(width: 1080, height: 800)),
            "mobile": .connWebView(size: .init(width: 400, height: 800)),
          ]
        )
      }
    #endif
  }

  func testInvoice() async throws {
    var customer = Stripe.Customer.mock
    customer.metadata = [
      "extraInvoiceInfo": """
      123 Street
      Brooklyn, NY

      VAT: 1234567890
      """
    ]
    var subscription = Stripe.Subscription.mock
    subscription.customer = .right(customer)

    await withDependencies {
      $0.stripe.fetchSubscription = { _ in subscription }
    } operation: {
      let conn = connection(
        from: request(to: .account(.invoices(.show("in_test"))), session: .loggedIn))

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(conn),
            as: [
              "desktop": .connWebView(size: .init(width: 1080, height: 800)),
              "mobile": .connWebView(size: .init(width: 400, height: 800)),
            ]
          )
        }
      #endif
    }
  }

  func testInvoice_InvoiceBilling() async throws {
    var charge = Charge.mock
    charge.paymentMethodDetails = .init()
    let invoice = Invoice.mock(charge: .right(charge))

    await withDependencies {
      $0.teamYearly()
      $0.stripe.fetchInvoice = { _ in invoice }
    } operation: {
      let conn = connection(
        from: request(to: .account(.invoices(.show("in_test"))), session: .loggedIn))

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(conn),
            as: [
              "desktop": .connWebView(size: .init(width: 1080, height: 800)),
              "mobile": .connWebView(size: .init(width: 400, height: 800)),
            ]
          )
        }
      #endif
    }
  }

  func testInvoiceWithDiscount() async throws {
    var invoice = Stripe.Invoice.mock(charge: .right(.mock))
    invoice.discount = .mock
    invoice.total = 1455
    invoice.subtotal = 1700

    await withDependencies {
      $0.stripe.fetchInvoice = { _ in invoice }
    } operation: {
      let conn = connection(
        from: request(to: .account(.invoices(.show("in_test"))), session: .loggedIn))

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(conn),
            as: [
              "desktop": .connWebView(size: .init(width: 1080, height: 800)),
              "mobile": .connWebView(size: .init(width: 400, height: 800)),
            ]
          )
        }
      #endif
    }
  }
}
