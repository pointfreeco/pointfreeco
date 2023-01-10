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
class PrivacyTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testPrivacy() async throws {
    let conn = connection(from: request(to: .privacy))

    await assertSnapshot(matching: await _siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1000)),
          ]
        )
      }
    #endif
  }
}
