import Either
@testable import GitHub
import Html
import HttpPipeline
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

final class WelcomeEmailTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testWelcomeEmail1() {
    update(&Current, \.database .~ .mock)

    let emailNodes = welcomeEmailView("", welcomeEmail1Content)(.newUser)

    assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testWelcomeEmail2() {
    update(&Current, \.database .~ .mock)

    let emailNodes = welcomeEmailView("", welcomeEmail2Content)(.newUser)

    assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testWelcomeEmail3() {
    update(&Current, \.database .~ .mock)

    let emailNodes = welcomeEmailView("", welcomeEmail3Content)(.newUser)

    assertSnapshot(matching: emailNodes, as: .html)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)

      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }

  func testIncrementEpisodeCredits() {
    let users = [1, 2, 3].map {
      Current.database.registerUser(
        .mock |> \.gitHubUser.id .~ .init(rawValue: $0),
        .init(rawValue: "\($0)@pointfree.co")
        ).run.perform().right!!
    }

    _ = Current.database.incrementEpisodeCredits(users.map(^\.id)).run.perform().right!

    let updatedUsers = users.map { Current.database.fetchUserById($0.id).run.perform().right!! }

    zip(users, updatedUsers).forEach { XCTAssertEqual($0.episodeCreditCount + 1, $1.episodeCreditCount) }
  }

  func testEpisodeEmails() {
    update(&Current, \.database .~ .mock)

    _ = sendWelcomeEmails()
      .run
      .perform()
      .right!
  }
}
