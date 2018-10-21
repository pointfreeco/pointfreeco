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

class PaymentInfoTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
  }

  func testRender() {
    let conn = connection(from: request(to: .account(.paymentInfo(.show(expand: nil))), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, with: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshot(
        matching: conn |> siteMiddleware,
        with: .ioConnWebView(size: .init(width: 1080, height: 2000)),
        named: "desktop"
      )

      assertSnapshot(
        matching: conn |> siteMiddleware,
        with: .ioConnWebView(size: .init(width: 400, height: 2000)),
        named: "mobile"
      )
    }
    #endif
  }
}
