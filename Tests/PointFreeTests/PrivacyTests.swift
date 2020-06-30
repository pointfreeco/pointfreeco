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
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record=true
  }

  func testPrivacy() {
    let conn = connection(from: request(to: .privacy))

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
