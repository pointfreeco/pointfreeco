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

final class NotFoundMiddlewareTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record=true
  }

  func testNotFound() {
    let conn = connection(from: URLRequest(url: URL(string: "http://localhost:8080/404")!))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshot(
        of: .ioConnWebView(size: .init(width: 1080, height: 1000)),
        matching: conn |> siteMiddleware,
        named: "desktop"
      )

      assertSnapshot(
        of: .ioConnWebView(size: .init(width: 400, height: 1000)),
        matching: conn |> siteMiddleware,
        named: "mobile"
      )
    }
    #endif
  }

  func testNotFound_LoggedIn() {
    let conn = connection(
      from: request(to: .home, session: .loggedIn)
        |> (over(\.url) <<< map) %~ { $0.appendingPathComponent("404") }
    )

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshot(
        of: .ioConnWebView(size: .init(width: 1080, height: 1000)),
        matching: conn |> siteMiddleware,
        named: "desktop"
      )

      assertSnapshot(
        of: .ioConnWebView(size: .init(width: 400, height: 1000)),
        matching: conn |> siteMiddleware,
        named: "mobile"
      )
    }
    #endif
  }
}
