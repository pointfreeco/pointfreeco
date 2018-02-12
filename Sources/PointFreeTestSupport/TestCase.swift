import Optics
@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

open class TestCase: XCTestCase {
  override open func setUp() {
    super.setUp()
    record = true
    AppEnvironment.push(
      const(
        .mock
          |> \.database .~ .live
          |> \.envVars %~ { $0.assigningValuesFrom(ProcessInfo.processInfo.environment) }
      )
    )

    _ = try! execute("DROP SCHEMA IF EXISTS public CASCADE")
      .flatMap(const(execute("CREATE SCHEMA public")))
      .flatMap(const(execute("GRANT ALL ON SCHEMA public TO pointfreeco")))
      .flatMap(const(execute("GRANT ALL ON SCHEMA public TO public")))
      .flatMap(const(AppEnvironment.current.database.migrate()))
      .flatMap(const(execute("CREATE SEQUENCE test_uuids")))
      .flatMap(const(execute(
        """
        CREATE OR REPLACE FUNCTION uuid_generate_v1mc() RETURNS uuid AS $$
        BEGIN
          RETURN ('00000000-0000-0000-0000-'||LPAD(nextval('test_uuids')::text, 12, '0'))::uuid;
        END; $$
        LANGUAGE PLPGSQL;
        """
      )))
      .run
      .perform()
      .unwrap()
  }

  override open func tearDown() {
    super.tearDown()
    record = false
    AppEnvironment.pop()
  }
}
