import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class PrivacyTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  @MainActor
  func testPrivacy() async throws {
    let conn = connection(from: request(to: .privacy))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: await siteMiddleware(conn),
          as: [
            "desktop": .connWebView(size: .init(width: 1080, height: 1000)),
            "mobile": .connWebView(size: .init(width: 400, height: 1000)),
          ]
        )
      }
    #endif
  }
}
