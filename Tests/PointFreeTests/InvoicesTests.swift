import Either
import HttpPipeline
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
@testable import Stripe
import XCTest
#if !os(Linux)
import WebKit
#endif

final class InvoicesTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.isRecording = true
  }

  func testInvoices() {
    let conn = connection(from: request(to: .account(.invoices(.index)), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ]
      )
    }
    #endif
  }

  func testInvoice() {
    var customer = Stripe.Customer.mock
    customer.metadata = ["extraInvoiceInfo": """
      123 Street
      Brooklyn, NY

      VAT: 1234567890
      """]
    var subscription = Stripe.Subscription.mock
    subscription.customer = .right(customer)
    Current.stripe.fetchSubscription = const(pure(subscription))

    let conn = connection(from: request(to: .account(.invoices(.show("in_test"))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ]
      )
    }
    #endif
  }

  func testInvoice_InvoiceBilling() {
    var charge = Charge.mock
    charge.source = .right(.mock)
    let invoice = Invoice.mock(charge: .right(charge))

    Current = .teamYearly
    Current.stripe.fetchInvoice = const(pure(invoice))

    let conn = connection(from: request(to: .account(.invoices(.show("in_test"))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ]
      )
    }
    #endif
  }

  func testInvoiceWithDiscount() {
    var invoice = Stripe.Invoice.mock(charge: .right(.mock))
    invoice.discount = .mock
    invoice.total = 1455
    invoice.subtotal = 1700
    Current.stripe.fetchInvoice = const(pure(invoice))

    let conn = connection(from: request(to: .account(.invoices(.show("in_test"))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ]
      )
    }
    #endif
  }
}
