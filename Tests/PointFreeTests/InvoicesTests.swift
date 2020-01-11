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
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testInvoices() {
    let conn = connection(from: request(to: .account(.invoices), session: .loggedIn))

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
