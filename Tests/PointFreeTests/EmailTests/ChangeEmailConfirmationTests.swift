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

class ChangeEmailConfirmationTests: TestCase {
  func testChangeEmailConfirmationEmail() {
    let emailNodes = confirmEmailChangeEmailView.view((.mock, "blobby@blob.co"))

    assertSnapshot(matching: render(emailNodes, config: .pretty), pathExtension: "html")

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView)
    }
    #endif
  }

  func testChangedEmail() {
    let emailNodes = emailChangedEmailView.view((.mock, "blobby@blob.co"))

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
