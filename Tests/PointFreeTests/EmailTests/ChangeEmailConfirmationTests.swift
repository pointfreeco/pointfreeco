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
    let emailNodes = confirmEmailChangeEmailView.view((.mock, .init(unwrap: "blobby@blob.co")))

    assertSnapshot(matching: render(emailNodes, config: pretty), pathExtension: "html")

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        assertSnapshot(matching: webView)
      }
    #endif
  }
}

