import Html
import HtmlPlainTextPrint
import HttpPipeline
import Optics
@testable import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class FreeEpisodeEmailTests: TestCase {
  func testFreeEpisodeEmail() {
    let doc = freeEpisodeEmail.view((Current.episodes().first!, .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc))

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView()
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image(size: .init(width: 900, height: 1200)))

      assertSnapshot(matching: webView, as: .image(size: .init(width: 400, height: 1100)))
    }
    #endif
  }
}
