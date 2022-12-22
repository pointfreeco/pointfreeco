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

@MainActor
class FreeEpisodeEmailTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testFreeEpisodeEmail() async throws {
    let doc = freeEpisodeEmail((Current.episodes().first!, .mock))

    await assertSnapshot(matching: doc, as: .html)
    await assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1200))
        webView.loadHTMLString(render(doc), baseURL: nil)
        await assertSnapshot(matching: webView, as: .image)

        webView.frame.size = .init(width: 400, height: 1100)
        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }
}
