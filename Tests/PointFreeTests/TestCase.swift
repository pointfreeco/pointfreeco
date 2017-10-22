import Either
@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

class TestCase: XCTestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.push(
      env: .init(
        airtableStuff: mockCreateRow(result: .right(unit)),
        fetchAuthToken: const(pure(.init(accessToken: "deadbeef"))),
        fetchGitHubUser: const(pure(.init(email: "hello@pointfree.co", id: 1, name: "Blob")))
      )
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}
