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

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshot(
        of: .ioConnWebView(size: .init(width: 1080, height: 2300)),
        matching: conn |> siteMiddleware,
        named: "desktop"
      )

      assertSnapshot(
        of: .ioConnWebView(size: .init(width: 400, height: 2300)),
        matching: conn |> siteMiddleware,
        named: "mobile"
      )
    }
    #endif
  }
}
