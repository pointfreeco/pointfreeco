import SnapshotTesting
import Html
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HtmlPlainTextPrint
import HttpPipeline
import Optics
#if !os(Linux)
import WebKit
#endif

class RegistrationEmailTests: TestCase {
  func testRegistrationEmail() {
    let doc = registrationEmailView.view(.mock)

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1200))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 1100)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }
}
