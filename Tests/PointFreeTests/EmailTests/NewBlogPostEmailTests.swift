import Dependencies
import Html
import HtmlPlainTextPrint
import HttpPipeline
import Models
import ModelsTestSupport
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import UrlFormEncoding
import XCTest

@testable import PointFree

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
#if !os(Linux)
  import WebKit
#endif

@MainActor
class NewBlogPostEmailTests: TestCase {
  @Dependency(\.blogPosts) var blogPosts
  @Dependency(\.siteRouter) var siteRouter

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  func testNewBlogPostEmail_NoAnnouncements_Subscriber() async throws {
    let doc = newBlogPostEmail((post, "", "", .mock))

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

  func testNewBlogPostEmail_NoAnnouncements_NonSubscriber() async throws {
    let doc = newBlogPostEmail((post, "", "", .nonSubscriber))

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

  func testNewBlogPostEmail_Announcements_Subscriber() async throws {
    let doc = newBlogPostEmail(
      (post, "Hey, thanks for being a subscriber! You're the best!", "", .mock))

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

  func testNewBlogPostEmail_Announcements_NonSubscriber() async throws {
    let doc = newBlogPostEmail(
      (
        post, "",
        "Hey! You're not a subscriber, but that's ok. At least you're interested in functional programming!",
        .nonSubscriber
      ))

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

  func testNewBlogPostRoute() async throws {
    let blogPost = self.blogPosts().first!

    var req = URLRequest(
      url: URL(string: "http://localhost:8080/admin/new-blog-post-email/\(blogPost.id)/send")!
    )
    req.httpMethod = "POST"
    let formData = urlFormEncode(
      value: [
        "nonsubscriber_announcement": "",
        "nonsubscriber_deliver": "true",
        "subscriber_announcement": "Hello!",
        "test": "Test email!",
      ]
    )
    req.httpBody = Data(formData.utf8)
    let formDataData = NewBlogPostFormData(
      nonsubscriberAnnouncement: "",
      nonsubscriberDeliver: true,
      subscriberAnnouncement: "Hello!",
      subscriberDeliver: false
    )

    XCTAssertEqual(
      .admin(.newBlogPostEmail(.send(blogPost.id, formData: formDataData, isTest: true))),
      try siteRouter.match(request: req)
    )
  }

  func testNewBlogPostEmail_NoCoverImage() async throws {
    var p = post
    p.coverImage = nil
    let doc = newBlogPostEmail((p, "", "", .mock))

    await assertSnapshot(matching: doc, as: .html)
    await assertSnapshot(matching: plainText(for: doc), as: .lines)
  }
}

private let post: BlogPost = {
  var post = post0001_welcome
  post.coverImage = ""
  return post
}()
