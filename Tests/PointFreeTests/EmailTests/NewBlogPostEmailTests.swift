#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Html
import HtmlPlainTextPrint
import HttpPipeline
import Models
import ModelsTestSupport
@testable import PointFree
import PointFreeRouter
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
//    SnapshotTesting.isRecording=true
  }

  func testNewBlogPostEmail_NoAnnouncements_Subscriber() {
    let doc = newBlogPostEmail((post, "", "", .mock))

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

  func testNewBlogPostEmail_NoAnnouncements_NonSubscriber() {
    let doc = newBlogPostEmail((post, "", "", .nonSubscriber))

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

  func testNewBlogPostEmail_Announcements_Subscriber() {
    let doc = newBlogPostEmail((post, "Hey, thanks for being a subscriber! You're the best!", "", .mock))

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

  func testNewBlogPostEmail_Announcements_NonSubscriber() {
    let doc = newBlogPostEmail((post, "", "Hey! You're not a subscriber, but that's ok. At least you're interested in functional programming!", .nonSubscriber))

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

  func testNewBlogPostRoute() {
    let blogPost = Current.blogPosts().first!

    var req = URLRequest(
      url: URL(string: "http://localhost:8080/admin/new-blog-post-email/\(blogPost.id)/send")!
    )
    req.httpMethod = "POST"
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
      .admin(.newBlogPostEmail(.send(blogPost.id, formData: formDataData, isTest: true))),
      try siteRouter.match(request: req)
    )
  }

  func testNewBlogPostEmail_NoCoverImage() {
    var p = post
    p.coverImage = nil
    let doc = newBlogPostEmail((p, "", "", .mock))

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)
  }
}

private let post: BlogPost = {
  var post = post0001_welcome
  post.coverImage = ""
  return post
}()
