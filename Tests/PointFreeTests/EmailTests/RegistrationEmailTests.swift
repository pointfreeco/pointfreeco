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

class RegistrationEmailTests: TestCase {
  func testRegistrationEmail() {
    let emailNodes = registrationEmailView.view(.mock)

    assertSnapshot(matching: render(emailNodes, config: pretty), pathExtension: "html")

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        assertSnapshot(matching: webView)
      }
    #endif
  }
}
