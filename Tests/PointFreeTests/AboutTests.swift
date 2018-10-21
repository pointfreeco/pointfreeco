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
      assertSnapshots(
        of: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2300)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2300))
        ],
        matching: conn |> siteMiddleware
      )
    }
    #endif
  }
}
