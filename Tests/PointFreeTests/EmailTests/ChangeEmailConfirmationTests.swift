import SnapshotTesting
import Html
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
#if !os(Linux)
import WebKit
#endif

class ChangeEmailConfirmationTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record=true
  }

  func testChangeEmailConfirmationEmail() {
    let emailNodes = confirmEmailChangeEmailView((.mock, "blobby@blob.co", "f9c46e50cb32c3f12369e92c8bb9d9db09edf2cce5a0307b4e8516ac36340b4738d82b4e060d069541557960935392ce3ec8d228338d7766255cb8905c5f06a3164194e9b63e064523f3493b8f957ab4"))

    assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testChangedEmail() {
    let emailNodes = emailChangedEmailView((.mock, "blobby@blob.co"))

    assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }
}
