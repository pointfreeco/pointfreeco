import Database
import Models
import NIO
import Optics
@testable import PointFree
import PointFreeRouter
import Prelude
import SnapshotTesting
import XCTest

open class TestCase: XCTestCase {
  override open func setUp() {
    super.setUp()
    diffTool = "ksdiff"
//    record = true
    Current = .mock
    Current.envVars = Current.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
    Current.database = .init(
      databaseUrl: Current.envVars.postgres.databaseUrl,
      eventLoopGroup: Current.eventLoopGroup,
      logger: Current.logger
    )
    pointFreeRouter = PointFreeRouter(baseUrl: Current.envVars.baseUrl)

    _ = try! Current.database.execute("DROP SCHEMA IF EXISTS public CASCADE", [])
      .flatMap(const(Current.database.execute("CREATE SCHEMA public", [])))
      .flatMap(const(Current.database.execute("GRANT ALL ON SCHEMA public TO pointfreeco", [])))
      .flatMap(const(Current.database.execute("GRANT ALL ON SCHEMA public TO public", [])))
      .flatMap(const(Current.database.migrate()))
      .flatMap(const(Current.database.execute("CREATE SEQUENCE test_uuids", [])))
      .flatMap(const(Current.database.execute(
        """
        CREATE OR REPLACE FUNCTION uuid_generate_v1mc() RETURNS uuid AS $$
        BEGIN
          RETURN ('00000000-0000-0000-0000-'||LPAD(nextval('test_uuids')::text, 12, '0'))::uuid;
        END; $$
        LANGUAGE PLPGSQL;
        """,
        []
      )))
      .run
      .perform()
      .unwrap()
  }

  override open func tearDown() {
    super.tearDown()
    record = false
  }
}
