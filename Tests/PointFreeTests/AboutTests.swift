import ApplicativeRouter
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
#if !os(Linux)
import WebKit
#endif

class AboutTests: TestCase {
  func testAbout() {
    let conn = connection(from: request(to: .about))

    assertSnapshot(matching: conn |> siteMiddleware, with: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshot(
        matching: conn |> siteMiddleware,
        with: .ioConnWebView(size: .init(width: 1080, height: 2300)),
        named: "desktop"
      )

      assertSnapshot(
        matching: conn |> siteMiddleware,
        with: .ioConnWebView(size: .init(width: 400, height: 2300)),
        named: "mobile"
      )
    }
    #endif
  }
}
