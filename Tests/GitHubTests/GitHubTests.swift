import GitHubTestSupport
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import GitHub

@MainActor
final class GitHubTests: TestCase {
  func testRequests() async throws {
    let fetchAuthToken = fetchGitHubAuthToken(
      clientId: "deadbeef-client-id", clientSecret: "deadbeef-client-secret")
    await assertSnapshot(
      matching: fetchAuthToken("deadbeef").rawValue,
      as: .raw,
      named: "fetch-auth-token"
    )
    await assertSnapshot(
      matching: fetchGitHubEmails(token: .mock).rawValue,
      as: .raw,
      named: "fetch-emails"
    )
    await assertSnapshot(
      matching: fetchGitHubUser(with: .mock).rawValue,
      as: .raw,
      named: "fetch-user"
    )
  }
}
