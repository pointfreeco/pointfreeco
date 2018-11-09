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

class NewBlogPostEmailTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testNewBlogPostEmail_NoAnnouncements_Subscriber() {
    let doc = newBlogPostEmail.view((post, "", "", .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc))

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView()
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image(size: .init(width: 900, height: 1200)))

      webView.frame.size = .init(width: 400, height: 1100)
      assertSnapshot(matching: webView, as: .image(size: .init(width: 400, height: 1100)))
    }
    #endif
  }

  func testNewBlogPostEmail_NoAnnouncements_NonSubscriber() {
    let doc = newBlogPostEmail.view((post, "", "", .nonSubscriber))

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

  func testNewBlogPostEmail_Announcements_Subscriber() {
    let doc = newBlogPostEmail.view((post, "Hey, thanks for being a subscriber! You're the best!", "", .mock))

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

  func testNewBlogPostEmail_Announcements_NonSubscriber() {
    let doc = newBlogPostEmail.view((post, "", "Hey! You're not a subscriber, but that's ok. At least you're interested in functional programming!", .nonSubscriber))

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

private let post = post0001_welcome
  |> \.coverImage .~ ""
