import Either
@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

// sourcery: disableTests
class TestCase: XCTestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.push(
      .init(
        airtableStuff: const(const(pure(unit))),
        createUser: const(pure(unit)),
        envVars: EnvVars(),
        fetchAuthToken: const(pure(.init(accessToken: "deadbeef"))),
        fetchGitHubUser: const(pure(.init(email: "hello@pointfree.co", id: 1, name: "Blob"))),
        sendEmail: const(pure(.init(id: "deadbeef", message: "success!")))
      )
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}
