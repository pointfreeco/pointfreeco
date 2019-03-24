import Database
import GitHub
import Prelude
import ModelsTestSupport
import GitHubTestSupport
import Logger
import SnapshotTesting
import XCTest

class DatabaseTestCase: XCTestCase {
  var database: Database.Client!

  override func setUp() {
    super.setUp()

    self.database = .init(databaseUrl: "postgres://pointfreeco:@localhost:5432/pointfreeco_test", logger: Logger())

    _ = try! self.database.execute("DROP SCHEMA IF EXISTS public CASCADE", [])
      .flatMap(const(self.database.execute("CREATE SCHEMA public", [])))
      .flatMap(const(self.database.execute("GRANT ALL ON SCHEMA public TO pointfreeco", [])))
      .flatMap(const(self.database.execute("GRANT ALL ON SCHEMA public TO public", [])))
      .flatMap(const(self.database.migrate()))
      .flatMap(const(self.database.execute("CREATE SEQUENCE test_uuids", [])))
      .flatMap(const(self.database.execute(
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
}
