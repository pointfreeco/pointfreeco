import CustomDump
import Database
import DatabaseTestSupport
import Dependencies
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
  @Dependency(\.database) var database

  func testUpsertUser_FetchUserById() async throws {
    let userA = try await self.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    let userB = try await self.database.fetchUserById(userA.id)
    XCTAssertEqual(userA.id, userB.id)
    XCTAssertEqual("hello@pointfree.co", userB.email.rawValue)
  }

  func testFetchEnterpriseAccount() async throws {
    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )
    let subscription = try await self.database.createSubscription(.mock, user.id, true, nil)

    _ = try await self.database.execute(
      """
      INSERT INTO "enterprise_accounts"
      ("company_name", "domain", "subscription_id")
      VALUES
      ('Blob, Inc.', 'blob.biz', \(bind: subscription.id))
      RETURNING *
      """
    )

    let fetchedAccount = try await self.database
      .fetchEnterpriseAccountForDomain("blob.biz")

    XCTAssertEqual("Blob, Inc.", fetchedAccount.companyName)
    XCTAssertEqual("blob.biz", fetchedAccount.domain)
    XCTAssertEqual(subscription.id, fetchedAccount.subscriptionId)
  }

  func testCreateSubscription_OwnerIsNotTakingSeat() async throws {
    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.createSubscription(.mock, user.id, false, nil)

    let freshUser = try await self.database.fetchUserById(user.id)

    XCTAssertEqual(nil, freshUser.subscriptionId)
  }

  func testCreateSubscription_OwnerIsTakingSeat() async throws {
    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    let subscription = try await self.database.createSubscription(.mock, user.id, true, nil)

    let freshUser = try await self.database.fetchUserById(user.id)

    XCTAssertEqual(subscription.id, freshUser.subscriptionId)
  }

  func testUpdateEpisodeProgress() async throws {
    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.updateEpisodeProgress(1, 20, false, user.id)

    var count = try await self.database.execute(
      """
      SELECT *
      FROM "episode_progresses"
      WHERE "user_id" = \(bind: user.id)
      AND "percent" = 20
      """
    )
    .count
    XCTAssertEqual(count, 1)

    _ = try await self.database.updateEpisodeProgress(1, 10, false, user.id)

    count = try await self.database.execute(
      """
      SELECT *
      FROM "episode_progresses"
      WHERE "user_id" = \(bind: user.id)
      AND "percent" = 10
      """
    )
    .count
    XCTAssertEqual(count, 1)

    _ = try await self.database.updateEpisodeProgress(1, 30, false, user.id)

    count = try await self.database.execute(
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

  func testUpdateEpisodeProgress_IsFinished() async throws {
    let episodeSequence: Episode.Sequence = 1
    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.updateEpisodeProgress(episodeSequence, 99, true, user.id)

    var progress = try await self.database.fetchEpisodeProgress(user.id, episodeSequence)
    XCTAssertNoDifference(
      progress,
      EpisodeProgress(
        createdAt: progress.createdAt,
        episodeSequence: 1,
        id: EpisodeProgress.ID(uuidString: "00000000-0000-0000-0000-000000000007")!,
        isFinished: true,
        percent: 99,
        userID: user.id,
        updatedAt: progress.updatedAt
      )
    )

    _ = try await self.database.updateEpisodeProgress(episodeSequence, 20, false, user.id)

    progress = try await self.database.fetchEpisodeProgress(user.id, episodeSequence)
    XCTAssertNoDifference(
      progress,
      EpisodeProgress(
        createdAt: progress.createdAt,
        episodeSequence: 1,
        id: EpisodeProgress.ID(uuidString: "00000000-0000-0000-0000-000000000007")!,
        isFinished: true,
        percent: 20,
        userID: user.id,
        updatedAt: progress.updatedAt
      )
    )
  }

  func testUpdateEpisodeProgresses() async throws {
    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.updateEpisodeProgress(1, 90, true, user.id)
    _ = try await self.database.updateEpisodeProgress(2, 20, true, user.id)
    _ = try await self.database.updateEpisodeProgress(3, 40, false, user.id)

    let progresses = try await self.database.fetchEpisodeProgresses(user.id)
    XCTAssertNoDifference(
      progresses,
      [
        EpisodeProgress(
          createdAt: progresses[0].createdAt,
          episodeSequence: 1,
          id: EpisodeProgress.ID(uuidString: "00000000-0000-0000-0000-000000000007")!,
          isFinished: true,
          percent: 90,
          userID: user.id,
          updatedAt: progresses[0].updatedAt
        ),
        EpisodeProgress(
          createdAt: progresses[1].createdAt,
          episodeSequence: 2,
          id: EpisodeProgress.ID(uuidString: "00000000-0000-0000-0000-000000000008")!,
          isFinished: true,
          percent: 20,
          userID: user.id,
          updatedAt: progresses[1].updatedAt
        ),
        EpisodeProgress(
          createdAt: progresses[2].createdAt,
          episodeSequence: 3,
          id: EpisodeProgress.ID(uuidString: "00000000-0000-0000-0000-000000000009")!,
          isFinished: false,
          percent: 40,
          userID: user.id,
          updatedAt: progresses[2].updatedAt
        ),
      ]
    )
  }

  func testFetchEpisodeProgress() async throws {
    let progress = 20
    let episodeSequence: Episode.Sequence = 1

    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.updateEpisodeProgress(episodeSequence, progress, false, user.id)

    let fetchedProgress = try await self.database.fetchEpisodeProgress(user.id, episodeSequence)

    XCTAssertNoDifference(
      fetchedProgress,
      EpisodeProgress(
        createdAt: fetchedProgress.createdAt,
        episodeSequence: 1,
        id: EpisodeProgress.ID(uuidString: "00000000-0000-0000-0000-000000000007")!,
        isFinished: false,
        percent: 20,
        userID: user.id,
        updatedAt: fetchedProgress.updatedAt
      )
    )
  }

  func testFetchEpisodeProgress_NoProgress() async throws {
    let episodeSequence: Episode.Sequence = 1

    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    do {
      _ = try await self.database.fetchEpisodeProgress(user.id, episodeSequence)
      XCTFail("fetchEpisodeProgress should throw")
    } catch {}
  }
}
