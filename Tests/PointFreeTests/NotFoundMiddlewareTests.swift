import Either
import HttpPipeline
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
#if !os(Linux)
  import WebKit
#endif

final class NotFoundMiddlewareTests: TestCase {
  override func setUp() {
    super.setUp()
    //    record=true
  }

  func testNotFound() {
    let conn = connection(from: URLRequest(url: URL(string: "http://localhost:8080/404")!))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1000)),
          ]
        )
      }
    #endif
  }

  func testNotFound_LoggedIn() {
    var req = request(to: .home, session: .loggedIn)
    req.url?.appendPathComponent("404")
    let conn = connection(from: req)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1000)),
          ]
        )
      }
    #endif
  }
}
