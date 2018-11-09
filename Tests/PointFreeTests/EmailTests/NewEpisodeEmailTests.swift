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
    let doc = newEpisodeEmail.view((Current.episodes().first!, "", "", .mock))

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

  func testNewEpisodeEmail_FreeEpisode_NonSubscriber() {
    let episode = Current.episodes().first!
      |> \.permission .~ .free

    let doc = newEpisodeEmail.view((episode, "", "", .nonSubscriber))

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

  func testNewEpisodeEmail_Announcement_NonSubscriber() {
    let episode = Current.episodes().first!

    let doc = newEpisodeEmail.view((
      episode,
      "This is an announcement for subscribers.",
      "This is an announcement for NON-subscribers.",
      .nonSubscriber
    ))

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

  func testNewEpisodeEmail_Announcement_Subscriber() {
    let episode = Current.episodes().first!

    let doc = newEpisodeEmail.view((
      episode,
      "This is an announcement for subscribers.",
      "This is an announcement for NON-subscribers.",
      .mock
    ))

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
