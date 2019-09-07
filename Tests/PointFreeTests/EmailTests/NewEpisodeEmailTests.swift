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

class NewEpisodeEmailTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testNewEpisodeEmail_Subscriber() {
    let doc = newEpisodeEmail((Current.episodes().first!, "", "", .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1200))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 1100)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testNewEpisodeEmail_FreeEpisode_NonSubscriber() {
    let episode = Current.episodes().first!
      |> \.permission .~ .free

    let doc = newEpisodeEmail((episode, "", "", .nonSubscriber))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1200))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 1100)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testNewEpisodeEmail_Announcement_NonSubscriber() {
    let episode = Current.episodes().first!

    let doc = newEpisodeEmail((
      episode,
      "This is an announcement for subscribers.",
      "This is an announcement for NON-subscribers.",
      .nonSubscriber
    ))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1200))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 1100)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testNewEpisodeEmail_Announcement_Subscriber() {
    let episode = Current.episodes().first!

    let doc = newEpisodeEmail((
      episode,
      "This is an announcement for subscribers.",
      "This is an announcement for NON-subscribers.",
      .mock
    ))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 1200))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 1100)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }
}
