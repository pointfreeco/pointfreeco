@testable import PointFree
import Optics
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

final class DatabaseTests: TestCase {
  let uuid = UUID()

  override func setUp() {
    super.setUp()

    AppEnvironment.push(((\.database) .~ .live)
        >>> ((\.envVars.postgres.databaseUrl) .~ "postgres://pointfreeco:@0.0.0.0:5432/pointfreeco_test"))
    _ = try! AppEnvironment.current.database.migrate().run.perform().unwrap()
  }

  override func tearDown() {
    super.tearDown()
    ["subscriptions", "users"].forEach {
      _ = try! execute("DROP TABLE \"\($0)\"").run.perform().unwrap()
    }
    AppEnvironment.pop()
  }

  func testCreate() throws {
    let userA = try! AppEnvironment.current.database.upsertUser(.mock).run.perform().unwrap()!
    let userB = try! AppEnvironment.current.database.fetchUserById(userA.id).run.perform().unwrap()!
    XCTAssertEqual(userA.id.unwrap, userB.id.unwrap)
  }
}
