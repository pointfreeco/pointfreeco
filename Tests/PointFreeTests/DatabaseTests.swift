@testable import PointFree
import Optics
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

final class DatabaseTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.push(((\.database) .~ .live)
        >>> ((\.envVars.postgres.databaseUrl) .~ "postgres://pointfreeco:@localhost:5432/pointfreeco_test"))
    _ = try! AppEnvironment.current.database.migrate().run.perform().unwrap()
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testMigrate() throws {

  }
}
