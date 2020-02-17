import Database
import DatabaseTestSupport
import GitHub
import PointFreeTestSupport
import Prelude
import Models
import ModelsTestSupport
import GitHubTestSupport
import Logging
import SnapshotTesting
import XCTest
@testable import PointFree


final class DatabaseTests: LiveDatabaseTestCase {
  func testUpsertUser_FetchUserById() throws {
    let userA = try Current.database.upsertUser(.mock, "hello@pointfree.co").run.perform().unwrap()
    let userB = try Current.database.fetchUserById(userA!.id).run.perform().unwrap()
    XCTAssertEqual(userA?.id, userB?.id)
    XCTAssertEqual("hello@pointfree.co", userB?.email.rawValue)
  }

  func testFetchEnterpriseAccount() {
    let user = Current.database.registerUser(.mock, "blob@pointfree.co").run.perform().right!!
    let subscription = Current.database.createSubscription(.mock, user.id, true).run.perform().right!!

    let createdAccount = Current.database.createEnterpriseAccount(
      "Blob, Inc.",
      "blob.biz",
      subscription.id
      )
      .run
      .perform()
      .right!!

    let fetchedAccount = Current.database.fetchEnterpriseAccountForDomain(createdAccount.domain)
      .run
      .perform()
      .right!!

    XCTAssertEqual(createdAccount, fetchedAccount)
    XCTAssertEqual("Blob, Inc.", createdAccount.companyName)
    XCTAssertEqual("blob.biz", createdAccount.domain)
    XCTAssertEqual(subscription.id, createdAccount.subscriptionId)
  }

  func testCreateSubscription_OwnerIsNotTakingSeat() {
    let user = Current.database.registerUser(.mock, "blob@pointfree.co")
      .run
      .perform()
      .right!!

    _ = Current.database.createSubscription(.mock, user.id, false)
      .run
      .perform()
      .right!!

    let freshUser = Current.database.fetchUserById(user.id)
      .run
      .perform()
      .right!!

    XCTAssertEqual(nil, freshUser.subscriptionId)
  }

  func testCreateSubscription_OwnerIsTakingSeat() {
    let user = Current.database.registerUser(.mock, "blob@pointfree.co")
      .run
      .perform()
      .right!!

    let subscription = Current.database.createSubscription(.mock, user.id, true)
      .run
      .perform()
      .right!!

    let freshUser = Current.database.fetchUserById(user.id)
      .run
      .perform()
      .right!!

    XCTAssertEqual(subscription.id, freshUser.subscriptionId)
  }
}
