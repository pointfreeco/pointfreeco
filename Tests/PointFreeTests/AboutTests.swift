import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

@MainActor
class AboutTests: TestCase {
  func testAbout() async throws {
    //SnapshotTesting.isRecording=true
    let conn = connection(from: request(to: .about))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
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
