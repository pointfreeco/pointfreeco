import Dependencies
import Either
import Html
import HttpPipeline
import Mailgun
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

final class WelcomeEmailIntegrationTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  func testIncrementEpisodeCredits() async throws {
    for id in [1, 2, 3] {
      var env = GitHubUserEnvelope.mock
      env.gitHubUser.id = .init(rawValue: id)
      let ids = try await self.database.execute(
        """
        INSERT INTO "users" (
          "email",
          "github_user_id",
          "github_access_token",
          "name",
          "episode_credit_count",
          "created_at"
        ) VALUES (
          \(bind: "\(id)@pointfree.co"),
          \(bind: env.gitHubUser.id),
          \(bind: env.accessToken.accessToken),
          \(bind: env.gitHubUser.name),
          1,
          CURRENT_DATE - INTERVAL '\(raw: "\(id * 7)") DAY' + INTERVAL '12 HOUR'
        ) RETURNING "id"
        """
      )
      for id in ids {
        try await self.database.updateEmailSettings(
          EmailSetting.Newsletter.allNewsletters, id.decode(column: "id")
        )
      }
    }

    let sentEmails = LockIsolated<[Email]>([])
    try await withDependencies {
      $0.continuousClock = ImmediateClock()
      $0.mailgun.sendEmail = { email in
        sentEmails.withValue { $0.append(email) }
        return SendEmailResponse(id: "", message: "")
      }
    } operation: {
      _ = try await sendWelcomeEmails()

      XCTAssertEqual(4, sentEmails.count)

      let user1 = try await database.fetchUserByGitHub(1)
      XCTAssertEqual(1, user1.episodeCreditCount)
      let user2 = try await database.fetchUserByGitHub(2)
      XCTAssertEqual(1, user2.episodeCreditCount)
      let user3 = try await database.fetchUserByGitHub(3)
      XCTAssertEqual(2, user3.episodeCreditCount)
    }
  }
}

final class WelcomeEmailTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  @MainActor
  func testWelcomeEmail1() async throws {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail1Content)(.newUser)

        await assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  @MainActor
  func testWelcomeEmail2() async throws {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail2Content)(.newUser)

        await assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  @MainActor
  func testWelcomeEmail3() async throws {
    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let emailNodes = welcomeEmailView("", welcomeEmail3Content)(.newUser)

        await assertSnapshot(matching: emailNodes, as: .html)

        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testEpisodeEmails() async throws {
    try await withDependencies {
      $0.continuousClock = ImmediateClock()
    } operation: {
      _ = try await sendWelcomeEmails()
    }
  }
}
