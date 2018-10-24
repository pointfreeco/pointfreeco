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

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        of: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1000))
        ],
        matching: conn |> siteMiddleware
      )
    }
    #endif
  }
}
