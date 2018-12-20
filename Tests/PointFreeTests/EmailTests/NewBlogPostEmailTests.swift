import Html
import HtmlPlainTextPrint
import HttpPipeline
import Optics
@testable import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import UrlFormEncoding
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

  func testNewBlogPostEmail_NoAnnouncements_NonSubscriber() {
    let doc = newBlogPostEmail.view((post, "", "", .nonSubscriber))

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

  func testNewBlogPostEmail_Announcements_Subscriber() {
    let doc = newBlogPostEmail.view((post, "Hey, thanks for being a subscriber! You're the best!", "", .mock))

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

  func testNewBlogPostEmail_Announcements_NonSubscriber() {
    let doc = newBlogPostEmail.view((post, "", "Hey! You're not a subscriber, but that's ok. At least you're interested in functional programming!", .nonSubscriber))

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

  func testNewBlogPostRoute() {
    let blogPost = Current.blogPosts().first!

    var req = URLRequest(
      url: URL(string: "http://localhost:8080/admin/new-blog-post-email/\(blogPost.id)/send")!
    )
    req.httpMethod = "POST"
    req.httpBody = Data("nonsubscriber_announcement=Hello!".utf8)
    XCTAssertNil(router.match(request: req))

    let formData = urlFormEncode(
      value: [
        "nonsubscriber_announcement": "",
        "nonsubscriber_deliver": "true",
        "subscriber_announcement": "Hello!",
        "test": "Test email!"
      ]
    )
    req.httpBody = Data(formData.utf8)
    let formDataData = NewBlogPostFormData(
      nonsubscriberAnnouncement: "",
      nonsubscriberDeliver: true,
      subscriberAnnouncement: "Hello!",
      subscriberDeliver: nil
    )

    XCTAssertEqual(
      .admin(.newBlogPostEmail(.send(blogPost, formData: formDataData, isTest: true))),
      router.match(request: req)
    )
  }

  func testNewBlogPostEmail_NoCoverImage() {
    let doc = newBlogPostEmail.view((post |> \.coverImage .~ nil, "", "", .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)
  }

}

private let post = post0001_welcome
  |> \.coverImage .~ ""
