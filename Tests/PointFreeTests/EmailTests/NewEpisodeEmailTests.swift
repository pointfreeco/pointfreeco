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

class NewEpisodeEmailTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording=true
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
    var episode = Current.episodes().first!
    episode.permission = .free

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

    let doc = newEpisodeEmail(
      (
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

    let doc = newEpisodeEmail(
      (
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

  func testNewEpisodeEmail_Markdown() {
    var episode = Current.episodes().first!
    episode.blurb = """
      Crafting better test dependencies for our code bases come with additional benefits outside of testing. We show how SwiftUI previews can be strengthened from better dependencies, and we show how we employ these techniques in our newly released game, [isowords](https://www.isowords.xyz).
      """

    let doc = newEpisodeEmail(
      (
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
