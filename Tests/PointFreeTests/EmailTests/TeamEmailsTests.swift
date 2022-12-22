import Html
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
class TeamEmailsTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.record=true
  }

  func testYouHaveBeenRemovedEmailView() async throws {
    let emailNodes = youHaveBeenRemovedEmailView(.teamOwner(.mock))

    await assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testTeammateRemovedEmailView() async throws {
    let emailNodes = teammateRemovedEmailView((.mock, .mock))

    await assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }
}
