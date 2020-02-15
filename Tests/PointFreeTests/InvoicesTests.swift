import Either
import HttpPipeline
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
@testable import Stripe
import XCTest
#if !os(Linux)
import WebKit
#endif

final class InvoicesTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
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
    let charge = Charge.mock
      |> (\Charge.source) .~ .right(.mock)
    let invoice = Invoice.mock(charge: .right(charge))

    Current = .teamYearly
      |> (\Environment.stripe.fetchInvoice) .~ const(pure(invoice))

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
    let invoice = Stripe.Invoice.mock(charge: .right(.mock))
      |> \.discount .~ .mock
      |> \.total .~ 1455
      |> \.subtotal .~ 1700
    update(&Current, \.stripe.fetchInvoice .~ const(pure(invoice)))

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
