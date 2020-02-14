@testable import GitHub
import GitHubTestSupport
import SnapshotTesting
import XCTest

final class GitHubTests: XCTestCase {
  func testRequests() {
    let fetchAuthToken = fetchGitHubAuthToken(clientId: "deadbeef-client-id", clientSecret: "deadbeef-client-secret")
    assertSnapshot(
      matching: fetchAuthToken("deadbeef").rawValue,
      as: .raw,
      named: "fetch-auth-token"
    )
    assertSnapshot(
      matching: fetchGitHubEmails(token: .mock).rawValue,
      as: .raw,
      named: "fetch-emails"
    )
    assertSnapshot(
      matching: fetchGitHubUser(with: .mock).rawValue,
      as: .raw,
      named: "fetch-user"
    )
  }
}
