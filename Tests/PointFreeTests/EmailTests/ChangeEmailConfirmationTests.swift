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
class ChangeEmailConfirmationTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.record=true
  }

  func testChangeEmailConfirmationEmail() async throws {
    let emailNodes = confirmEmailChangeEmailView(
      (
        .mock, "blobby@blob.co",
        "f9c46e50cb32c3f12369e92c8bb9d9db09edf2cce5a0307b4e8516ac36340b4738d82b4e060d069541557960935392ce3ec8d228338d7766255cb8905c5f06a3164194e9b63e064523f3493b8f957ab4"
      ))

    await assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testChangedEmail() async throws {
    let emailNodes = emailChangedEmailView((.mock, "blobby@blob.co"))

    await assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }
}
