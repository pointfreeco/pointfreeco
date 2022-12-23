import Database
import DatabaseTestSupport
import GitHub
import GitHubTestSupport
import Logging
import Models
import ModelsTestSupport
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

@MainActor
final class DatabaseTests: LiveDatabaseTestCase {
  func testUpsertUser_FetchUserById() async throws {
    let userA = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .performAsync()!
    let userB = try await Current.database.fetchUserById(userA.id)
    XCTAssertEqual(userA.id, userB.id)
    XCTAssertEqual("hello@pointfree.co", userB.email.rawValue)
  }

  func testFetchEnterpriseAccount() async throws {
    let user = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )
    .performAsync()!
    let subscription = try await Current.database.createSubscription(.mock, user.id, true, nil)

    let createdAccount = try await Current.database.createEnterpriseAccount(
      "Blob, Inc.",
      "blob.biz",
      subscription.id
    )

    let fetchedAccount = try await Current.database
      .fetchEnterpriseAccountForDomain(createdAccount.domain)

    XCTAssertEqual(createdAccount, fetchedAccount)
    XCTAssertEqual("Blob, Inc.", createdAccount.companyName)
    XCTAssertEqual("blob.biz", createdAccount.domain)
    XCTAssertEqual(subscription.id, createdAccount.subscriptionId)
  }

  func testCreateSubscription_OwnerIsNotTakingSeat() async throws {
    let user = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )
    .performAsync()!

    _ = try await Current.database.createSubscription(.mock, user.id, false, nil)

    let freshUser = try await Current.database.fetchUserById(user.id)

    XCTAssertEqual(nil, freshUser.subscriptionId)
  }

  func testCreateSubscription_OwnerIsTakingSeat() async throws {
    let user = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let subscription = try await Current.database.createSubscription(.mock, user.id, true, nil)

    let freshUser = try await Current.database.fetchUserById(user.id)

    XCTAssertEqual(subscription.id, freshUser.subscriptionId)
  }

  func testUpdateEpisodeProgress() async throws {
    let user = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )
    .performAsync()!

    _ = try await Current.database.updateEpisodeProgress(1, 20, user.id)

    var count = try await Current.database.execute(
      """
      SELECT *
      FROM "episode_progresses"
      WHERE "user_id" = \(bind: user.id)
      AND "percent" = 20
      """
    )
    .count
    XCTAssertEqual(count, 1)

    _ = try await Current.database.updateEpisodeProgress(1, 10, user.id)

    count = try await Current.database.execute(
      """
      SELECT *
      FROM "episode_progresses"
      WHERE "user_id" = \(bind: user.id)
      AND "percent" = 10
      """
    )
    .count
    XCTAssertEqual(count, 1)

    _ = try await Current.database.updateEpisodeProgress(1, 30, user.id)

    count = try await Current.database.execute(
      """
      SELECT *
      FROM "episode_progresses"
      WHERE "user_id" = \(bind: user.id)
      AND "percent" = 30
      """
    )
    .count
    XCTAssertEqual(count, 1)
  }

  func testFetchEpisodeProgress() async throws {
    let progress = 20
    let episodeSequence: Episode.Sequence = 1

    let user = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )
    .performAsync()!

    _ = try await Current.database.updateEpisodeProgress(episodeSequence, progress, user.id)

    let fetchedProgress = try await Current.database.fetchEpisodeProgress(user.id, episodeSequence)

    XCTAssertEqual(fetchedProgress, .some(20))
  }

  func testFetchEpisodeProgress_NoProgress() async throws {
    let episodeSequence: Episode.Sequence = 1

    let user = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let fetchedProgress = try await Current.database.fetchEpisodeProgress(user.id, episodeSequence)

    XCTAssertEqual(fetchedProgress, .none)
  }
}
