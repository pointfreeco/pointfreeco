@testable import PointFree
import PointFreeTestSupport
import SnapshotTesting
import XCTest

final class GitHubTests: TestCase {
  func testRequests() {
    assertSnapshot(
      matching: PointFree.fetchAuthToken(with: "deadbeef").rawValue,
      as: .raw,
      named: "fetch-auth-token"
    )
    assertSnapshot(
      matching: PointFree.fetchEmails(token: .mock).rawValue,
      as: .raw,
      named: "fetch-emails"
    )
    assertSnapshot(
      matching: PointFree.fetchUser(with: .mock).rawValue,
      as: .raw,
      named: "fetch-user"
    )
  }
}
