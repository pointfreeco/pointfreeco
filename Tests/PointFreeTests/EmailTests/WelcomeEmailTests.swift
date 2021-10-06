import Either
@testable import GitHub
import Html
import HttpPipeline
import Models
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

final class WelcomeEmailIntegrationTests: LiveDatabaseTestCase {
  func testIncrementEpisodeCredits() throws {
    let users: [User] = [1, 2, 3].map {
      var env = GitHubUserEnvelope.mock
      env.gitHubUser.id = .init(rawValue: $0)
      return Current.database.registerUser(withGitHubEnvelope: env, email: .init(rawValue: "\($0)@pointfree.co"), now: { .mock })
        .run.perform().right!!
    }
    
    _ = try Current.database.incrementEpisodeCredits(users.map(^\.id)).run.perform().unwrap()
    
    let updatedUsers = users.map { Current.database.fetchUserById($0.id).run.perform().right!! }
    
    zip(users, updatedUsers).forEach { XCTAssertEqual($0.episodeCreditCount + 1, $1.episodeCreditCount) }
  }
}

final class WelcomeEmailTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording=true
  }
  
  func testWelcomeEmail1() {
    if self.isScreenshotTestingAvailable {
      let emailNodes = welcomeEmailView("", welcomeEmail1Content)(.newUser)
      
      assertSnapshot(matching: emailNodes, as: .html)
      
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)
      
      assertSnapshot(matching: webView, as: .image)
    }
  }
  
  func testWelcomeEmail2() {
    if self.isScreenshotTestingAvailable {
      let emailNodes = welcomeEmailView("", welcomeEmail2Content)(.newUser)
      
      assertSnapshot(matching: emailNodes, as: .html)
      
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)
      
      assertSnapshot(matching: webView, as: .image)
    }
  }
  
  func testWelcomeEmail3() {
    if self.isScreenshotTestingAvailable {
      let emailNodes = welcomeEmailView("", welcomeEmail3Content)(.newUser)
      
      assertSnapshot(matching: emailNodes, as: .html)
      
      let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
      webView.loadHTMLString(render(emailNodes), baseURL: nil)
      
      assertSnapshot(matching: webView, as: .image)
    }
  }
  
  func testEpisodeEmails() {
    _ = sendWelcomeEmails()
      .run
      .perform()
      .right!
  }
}
