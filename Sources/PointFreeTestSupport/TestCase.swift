import Optics
@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

open class TestCase: XCTestCase {
  override open func setUp() {
    super.setUp()
    AppEnvironment.push(const(.mock))

    AppEnvironment.push(
      ((\.database) .~ .live)
      >>> ((\.envVars.postgres.databaseUrl) .~ "postgres://pointfreeco:@0.0.0.0:5432/pointfreeco_test")
    )

    _ = try! execute("DROP SCHEMA public CASCADE;")
      .flatMap(const(execute("CREATE SCHEMA public;")))
      .flatMap(const(execute("GRANT ALL ON SCHEMA public TO pointfreeco;")))
      .flatMap(const(execute("GRANT ALL ON SCHEMA public TO public;")))
      .flatMap(const(AppEnvironment.current.database.migrate()))
      .run
      .perform()
      .unwrap()
  }

  override open func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
}
