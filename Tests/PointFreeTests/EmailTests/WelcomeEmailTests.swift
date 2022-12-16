import Either
import Html
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import GitHub
@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

@MainActor
final class WelcomeEmailIntegrationTests: LiveDatabaseTestCase {
  func testIncrementEpisodeCredits() async throws {
    var users: [User] = []
    for id in [1, 2, 3] {
      var env = GitHubUserEnvelope.mock
      env.gitHubUser.id = .init(rawValue: id)
      try await users.append(
        Current.database.registerUser(
          withGitHubEnvelope: env, email: .init(rawValue: "\(id)@pointfree.co"), now: { .mock }
        )
        .performAsync()!
      )
    }

    _ = try await Current.database.incrementEpisodeCredits(users.map(\.id)).performAsync()

    var updatedUsers: [User] = []
    for user in users {
      try await updatedUsers.append(Current.database.fetchUserById(user.id).performAsync()!)
    }

    zip(users, updatedUsers).forEach {
      XCTAssertEqual($0.episodeCreditCount + 1, $1.episodeCreditCount)
    }
  }
}

final class WelcomeEmailTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording=true
  }

  func testWelcomeEmail1() {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail1Content)(.newUser)

        assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testWelcomeEmail2() {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail2Content)(.newUser)

        assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testWelcomeEmail3() {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail3Content)(.newUser)

        assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testEpisodeEmails() {
    _ = sendWelcomeEmails()
      .run
      .perform()
      .right!
  }
}
