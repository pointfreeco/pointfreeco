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
  func testYouHaveBeenRemovedEmailView() {
    let emailNodes = youHaveBeenRemovedEmailView.view((.mock, .mock))

    assertSnapshot(matching: render(emailNodes, config: .pretty), pathExtension: "html")

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView)
    }
    #endif
  }

  func testTeammateRemovedEmailView() {
    let emailNodes = teammateRemovedEmailView.view((.mock, .mock))

    assertSnapshot(matching: render(emailNodes, config: .pretty), pathExtension: "html")

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView)
    }
    #endif
  }
}
