import ApplicativeRouter
import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class AboutTests: TestCase {
  func testAbout() {
    //    record=true
    let conn = connection(from: request(to: .about))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2300)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2300)),
          ]
        )
      }
    #endif
  }
}
