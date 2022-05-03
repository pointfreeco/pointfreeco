import Html
import HtmlPlainTextPrint
import HttpPipeline
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class EmailInviteTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.record=true
  }

  func testEmailInvite() {
    let doc = teamInviteEmailView((.mock, .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView, as: .image)

        webView.frame.size = .init(width: 400, height: 700)
        assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testInviteAcceptance() {
    let doc = inviteeAcceptedEmailView((.mock, .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView, as: .image)

        webView.frame.size = .init(width: 400, height: 700)
        assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }
}
