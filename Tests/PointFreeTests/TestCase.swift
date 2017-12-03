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
        database: .mock,
        envVars: EnvVars(),
        gitHub: .mock,
        sendEmail: const(pure(.init(id: "deadbeef", message: "success!")))
      )
    )
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}

extension Database {
  static let mock = Database(
    createSubscription: { _, _ in pure(unit) },
    createUser: const(pure(unit)),
    fetchUser: const(pure(.mock)),
    migrate: { pure(unit) }
  )
}

extension Database.User {
  static let mock = Database.User(
    email: "hello@pointfree.co",
    gitHubUserId: 1,
    gitHubAccessToken: "deadbeef",
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
    name: "Blob",
    subscriptionId: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
  )
}

extension GitHub {
  static let mock = GitHub(
    fetchAuthToken: const(pure(.mock)),
    fetchUser: const(pure(.mock))
  )
}

extension GitHub.AccessToken {
  static let mock = GitHub.AccessToken(
    accessToken: "deadbeef"
  )
}

extension GitHub.User {
  static let mock = GitHub.User(
    email: "hello@pointfree.co",
    id: 1,
    name: "Blob"
  )
}
