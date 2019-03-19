import Database
import GitHub
import Prelude
import ModelsTestSupport
import GitHubTestSupport
import Logger
import SnapshotTesting
import XCTest

final class DatabaseTests: XCTestCase {
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

  func testUpsertUser_FetchUserById() throws {
    let userA = try self.database.upsertUser(.mock, "hello@pointfree.co").run.perform().unwrap()
    let userB = try self.database.fetchUserById(userA!.id).run.perform().unwrap()
    XCTAssertEqual(userA?.id, userB?.id)
    XCTAssertEqual("hello@pointfree.co", userB?.email.rawValue)
  }

  func testFetchEnterpriseAccount() {
    let user = self.database.registerUser(.mock, "blob@pointfree.co").run.perform().right!!
    let subscription = self.database.createSubscription(.mock, user.id).run.perform().right!!

    let createdAccount = self.database.createEnterpriseAccount(
      "Blob, Inc.",
      "blob.biz",
      subscription.id
      )
      .run
      .perform()
      .right!!

    let fetchedAccount = self.database.fetchEnterpriseAccount(createdAccount.domain)
      .run
      .perform()
      .right!!

    XCTAssertEqual(createdAccount, fetchedAccount)
    XCTAssertEqual("Blob, Inc.", createdAccount.companyName)
    XCTAssertEqual("blob.biz", createdAccount.domain)
    XCTAssertEqual(subscription.id, createdAccount.subscriptionId)
  }
}
