import GitHubTestSupport
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import GitHub

final class GitHubTests: TestCase {
  func testRequests() {
    let fetchAuthToken = fetchGitHubAuthToken(
      clientId: "deadbeef-client-id", clientSecret: "deadbeef-client-secret")
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
