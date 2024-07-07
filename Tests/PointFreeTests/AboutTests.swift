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
  override func setUp() {
    super.setUp()
    //SnapshotTesting.isRecording=true
  }

  @MainActor
  func testAbout() async throws {
    let conn = connection(from: request(to: .about))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: await siteMiddleware(conn),
          as: [
            "desktop": .connWebView(size: .init(width: 1080, height: 2300)),
            "mobile": .connWebView(size: .init(width: 400, height: 2300)),
          ]
        )
      }
    #endif
  }
}
