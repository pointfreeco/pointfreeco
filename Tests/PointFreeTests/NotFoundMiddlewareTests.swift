import Either
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HttpPipeline
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

final class NotFoundMiddlewareTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
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
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1000))
        ]
      )
    }
    #endif
  }

  func testNotFound_LoggedIn() {
    let conn = connection(
      from: request(to: .home, session: .loggedIn)
        |> (over(\.url) <<< map) %~ { $0.appendingPathComponent("404") }
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1000))
        ]
      )
    }
    #endif
  }
}
