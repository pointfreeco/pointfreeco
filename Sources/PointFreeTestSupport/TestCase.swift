import Optics
@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

#if !os(Linux)
public typealias SnapshotTestCase = XCTestCase
#endif

open class TestCase: SnapshotTestCase {
  override open func setUp() {
    super.setUp()
    diffTool = "ksdiff"
//    record = true
    Current = .mock
      |> \.database .~ .live
      |> \.envVars %~ { $0.assigningValuesFrom(ProcessInfo.processInfo.environment) }

    _ = try! execute("DROP SCHEMA IF EXISTS public CASCADE")
      .flatMap(const(execute("CREATE SCHEMA public")))
      .flatMap(const(execute("GRANT ALL ON SCHEMA public TO pointfreeco")))
      .flatMap(const(execute("GRANT ALL ON SCHEMA public TO public")))
      .flatMap(const(Current.database.migrate()))
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
  }
}
