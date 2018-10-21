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

class PrivacyTests: TestCase {
  func testPrivacy() {
    let conn = connection(from: request(to: .privacy))

    assertSnapshot(matching: conn |> siteMiddleware, with: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshot(
        matching: conn |> siteMiddleware,
        with: .ioConnWebView(size: .init(width: 1080, height: 1000)),
        named: "desktop"
      )

      assertSnapshot(
        matching: conn |> siteMiddleware,
        with: .ioConnWebView(size: .init(width: 400, height: 1000)),
        named: "mobile"
      )
    }
    #endif
  }
}
