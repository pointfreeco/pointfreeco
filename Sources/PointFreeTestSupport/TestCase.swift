import Database
import Models
import NIO
import PointFreeRouter
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

open class LiveDatabaseTestCase: TestCase {
  override open func setUp() {
    super.setUp()

    Current.database = .liveTest

    _ = try! Current.database.execute("DROP SCHEMA IF EXISTS public CASCADE", [])
      .flatMap(const(Current.database.execute("CREATE SCHEMA public", [])))
      .flatMap(const(Current.database.execute("GRANT ALL ON SCHEMA public TO pointfreeco", [])))
      .flatMap(const(Current.database.execute("GRANT ALL ON SCHEMA public TO public", [])))
      .flatMap(const(Current.database.migrate()))
      .flatMap(const(Current.database.execute("CREATE SEQUENCE test_uuids", [])))
      .flatMap(const(Current.database.execute("CREATE SEQUENCE test_shortids", [])))
      .flatMap(
        const(
          Current.database.execute(
            """
            CREATE OR REPLACE FUNCTION uuid_generate_v1mc() RETURNS uuid AS $$
            BEGIN
              RETURN ('00000000-0000-0000-0000-'||LPAD(nextval('test_uuids')::text, 12, '0'))::uuid;
            END; $$
            LANGUAGE PLPGSQL;
            """,
            []
          ))
      )
      .flatMap(
        const(
          Current.database.execute(
            """
            CREATE OR REPLACE FUNCTION gen_shortid(table_name text, column_name text)
            RETURNS text AS $$
            BEGIN
              RETURN table_name||'-'||column_name||nextval('test_shortids')::text;
            END; $$
            LANGUAGE PLPGSQL;
            """,
            []
          ))
      )
      .run
      .perform()
      .unwrap()
  }
}

open class TestCase: XCTestCase {
  override open func setUp() {
    super.setUp()
    diffTool = "ksdiff"
    //    record = true
    Current = .mock
    Current.envVars = Current.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
    pointFreeRouter = PointFreeRouter(baseUrl: Current.envVars.baseUrl)
  }

  override open func tearDown() {
    super.tearDown()
    record = false
  }

  public var isScreenshotTestingAvailable: Bool {
    ProcessInfo.processInfo.environment["CI"] == nil
  }
}
