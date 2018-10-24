import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

final class InvoicesTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
  }

  func testInvoices() {
    let conn = connection(from: request(to: .account(.invoices(.index)), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        of: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ],
        matching: conn |> siteMiddleware
      )
    }
    #endif
  }

  func testInvoice() {
    let conn = connection(from: request(to: .account(.invoices(.show("in_test"))), session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        of: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ],
        matching: conn |> siteMiddleware
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

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        of: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ],
        matching: conn |> siteMiddleware
      )
    }
    #endif
  }
}
