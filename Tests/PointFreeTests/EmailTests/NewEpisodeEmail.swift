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

class NewEpisodeEmailTests: TestCase {
  func testNewEpisodeEmail_Subscriber() {
    let doc = newEpisodeEmail.view((episodes.first!, .mock, true))

    assertSnapshot(matching: render(doc, config: pretty), pathExtension: "html")
    assertSnapshot(matching: plainText(for: doc))

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 1200))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView)

        webView.frame.size = .init(width: 400, height: 1100)
        assertSnapshot(matching: webView)
      }
    #endif
  }

  func testNewEpisodeEmail_NonSubscriber() {
    let doc = newEpisodeEmail.view((episodes.first!, .mock, false))

    assertSnapshot(matching: render(doc, config: pretty), pathExtension: "html")
    assertSnapshot(matching: plainText(for: doc))

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 1200))
        webView.loadHTMLString(render(doc), baseURL: nil)
        assertSnapshot(matching: webView)

        webView.frame.size = .init(width: 400, height: 1100)
        assertSnapshot(matching: webView)
      }
    #endif
  }
}
