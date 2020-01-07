import SnapshotTesting
import Html
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
import Optics
#if !os(Linux)
import WebKit
#endif

class TeamEmailsTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testYouHaveBeenRemovedEmailView() {
    let emailNodes = youHaveBeenRemovedEmailView(.teamOwner(.mock))

    assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testTeammateRemovedEmailView() {
    let emailNodes = teammateRemovedEmailView((.mock, .mock))

    assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }
}
