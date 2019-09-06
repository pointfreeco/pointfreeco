import Database
import GitHub
import Prelude
import Models
import ModelsTestSupport
import GitHubTestSupport
import Logger
import SnapshotTesting
import XCTest

final class DatabaseTests: DatabaseTestCase {
  func testUpsertUser_FetchUserById() throws {
    let userA = try self.database.upsertUser(.mock, "hello@pointfree.co").run.perform().unwrap()
    let userB = try self.database.fetchUserById(userA!.id).run.perform().unwrap()
    XCTAssertEqual(userA?.id, userB?.id)
    XCTAssertEqual("hello@pointfree.co", userB?.email.rawValue)
  }

  func testFetchEnterpriseAccount() {
    let user = self.database.registerUser(.mock, "blob@pointfree.co").run.perform().right!!
    let subscription = self.database.createSubscription(.mock, user.id, true).run.perform().right!!

    let createdAccount = self.database.createEnterpriseAccount(
      "Blob, Inc.",
      "blob.biz",
      subscription.id
      )
      .run
      .perform()
      .right!!

    let fetchedAccount = self.database.fetchEnterpriseAccountForDomain(createdAccount.domain)
      .run
      .perform()
      .right!!

    XCTAssertEqual(createdAccount, fetchedAccount)
    XCTAssertEqual("Blob, Inc.", createdAccount.companyName)
    XCTAssertEqual("blob.biz", createdAccount.domain)
    XCTAssertEqual(subscription.id, createdAccount.subscriptionId)
  }

  func testCreateSubscription_OwnerIsNotTakingSeat() {
    let user = self.database.registerUser(.mock, "blob@pointfree.co")
      .run
      .perform()
      .right!!

    _ = self.database.createSubscription(.mock, user.id, false)
      .run
      .perform()
      .right!!

    let freshUser = self.database.fetchUserById(user.id)
      .run
      .perform()
      .right!!

    XCTAssertEqual(nil, freshUser.subscriptionId)
  }

  func testCreateSubscription_OwnerIsTakingSeat() {
    let user = self.database.registerUser(.mock, "blob@pointfree.co")
      .run
      .perform()
      .right!!

    let subscription = self.database.createSubscription(.mock, user.id, true)
      .run
      .perform()
      .right!!

    let freshUser = self.database.fetchUserById(user.id)
      .run
      .perform()
      .right!!

    XCTAssertEqual(subscription.id, freshUser.subscriptionId)
  }
}
