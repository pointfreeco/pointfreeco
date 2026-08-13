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
import XCTest

@testable import PointFree

final class DatabaseTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  func testUpsertUser_FetchUserById() async throws {
    let userA = try await self.database.upsertUser(.mock, .mock, "hello@pointfree.co", { .mock })
    let userB = try await self.database.fetchUserById(userA.id)
    XCTAssertEqual(userA.id, userB.id)
    XCTAssertEqual("hello@pointfree.co", userB.email.rawValue)
  }

  func testEpisodeSearch() async throws {
    try await self.database.refreshEpisodeSearchIndex([
      EpisodeSearchDocument(
        content: "Functions",
        episodeSequence: 1,
        kind: .episodeTitle,
        sectionTitle: nil,
        timestamp: nil
      ),
      EpisodeSearchDocument(
        content: "We discuss what makes functions great.",
        episodeSequence: 1,
        kind: .blurb,
        sectionTitle: nil,
        timestamp: nil
      ),
      EpisodeSearchDocument(
        content: "Introduction",
        episodeSequence: 1,
        kind: .title,
        sectionTitle: "Introduction",
        timestamp: 68
      ),
      EpisodeSearchDocument(
        content: "We can define an increment function that takes an Int and returns an Int.",
        episodeSequence: 1,
        kind: .prose,
        sectionTitle: "Introduction",
        timestamp: 68
      ),
      EpisodeSearchDocument(
        content: "func increment(_ x: Int) -> Int { x + 1 }",
        episodeSequence: 1,
        kind: .code,
        sectionTitle: "Introduction",
        timestamp: 68
      ),
      EpisodeSearchDocument(
        content: {
          let filler = Array(
            repeating: "The quick brown fox jumps over the lazy dog.", count: 5
          ).joined(separator: " ")
          return "\(filler) A borborygmus interrupted the silence. \(filler)"
        }(),
        episodeSequence: 2,
        kind: .prose,
        sectionTitle: "Digressions",
        timestamp: 500
      ),
      EpisodeSearchDocument(
        content: {
          let code = Array(
            repeating: "let value = compute(from: input)", count: 8
          ).joined(separator: "; ")
          return "A code example: `\(code); let susurration = whisper(); \(code)` and that is all."
        }(),
        episodeSequence: 2,
        kind: .prose,
        sectionTitle: "Whispers",
        timestamp: 600
      ),
      EpisodeSearchDocument(
        content: "You should flibbertigibbet often, and flibbertigibbet loudly.",
        episodeSequence: 1,
        kind: .prose,
        sectionTitle: "Chatter",
        timestamp: 700
      ),
      EpisodeSearchDocument(
        content: "The `Flibbertigibbet` type is quite rare.",
        episodeSequence: 2,
        kind: .prose,
        sectionTitle: "Rare types",
        timestamp: 800
      ),
    ])

    let results = try await self.database.searchEpisodes(query: "increment function")

    XCTAssertEqual(1, results.count)
    XCTAssertEqual(1, results[0].episodeSequence)
    XCTAssertEqual(.prose, results[0].kind)
    XCTAssertEqual("Introduction", results[0].sectionTitle)
    XCTAssertEqual(68, results[0].timestamp)
    XCTAssertTrue(results[0].headline.contains("⟪increment⟫"))
    XCTAssertTrue(results[0].headline.contains("⟪function⟫"))
    XCTAssertFalse(results[0].headlineIsTruncatedAtStart)
    XCTAssertFalse(results[0].headlineIsTruncatedAtEnd)

    let truncatedResults = try await self.database.searchEpisodes(query: "borborygmus")
    XCTAssertEqual(1, truncatedResults.count)
    XCTAssertTrue(truncatedResults[0].headline.contains("⟪borborygmus⟫"))
    XCTAssertTrue(truncatedResults[0].headlineIsTruncatedAtStart)
    XCTAssertTrue(truncatedResults[0].headlineIsTruncatedAtEnd)
    XCTAssertFalse(truncatedResults[0].headlineStartsInsideCodeSpan)

    let codeSpanResults = try await self.database.searchEpisodes(query: "susurration")
    XCTAssertEqual(1, codeSpanResults.count)
    XCTAssertTrue(codeSpanResults[0].headline.contains("⟪susurration⟫"))
    XCTAssertTrue(codeSpanResults[0].headlineIsTruncatedAtStart)
    XCTAssertTrue(codeSpanResults[0].headlineStartsInsideCodeSpan)

    let suggestions = try await self.database.suggestEpisodeSearchTerms(query: "function")
    XCTAssertEqual(["Functions"], suggestions)

    let capitalizedResults = try await self.database.searchEpisodes(query: "Flibbertigibbet")
    XCTAssertEqual(["Rare types", "Chatter"], capitalizedResults.map(\.sectionTitle))

    let lowercasedResults = try await self.database.searchEpisodes(query: "flibbertigibbet")
    XCTAssertEqual(["Chatter", "Rare types"], lowercasedResults.map(\.sectionTitle))

    let codeResults = try await self.database.searchEpisodes(query: "increment")
    XCTAssertEqual([.prose, .code], codeResults.map(\.kind))

    let titleResults = try await self.database.searchEpisodes(query: "introduction")
    XCTAssertEqual([.title], titleResults.map(\.kind))
    XCTAssertEqual("⟪Introduction⟫", titleResults[0].headline)

    let episodeTitleResults = try await self.database.searchEpisodes(query: "functions")
    XCTAssertEqual([.episodeTitle, .blurb, .prose], episodeTitleResults.map(\.kind))
    XCTAssertEqual("⟪Functions⟫", episodeTitleResults[0].headline)

    let blurbResults = try await self.database.searchEpisodes(query: "great functions")
    XCTAssertEqual(1, blurbResults.count)
    XCTAssertEqual(.blurb, blurbResults[0].kind)
    XCTAssertEqual(nil, blurbResults[0].sectionTitle)

    let emptyResults = try await self.database.searchEpisodes(query: "quantum chromodynamics")
    XCTAssertEqual([], emptyResults)

    try await self.database.refreshEpisodeSearchIndex([])
    let clearedResults = try await self.database.searchEpisodes(query: "increment function")
    XCTAssertEqual([], clearedResults)
  }

  func testFetchEnterpriseAccount() async throws {
    let user = try await self.database.registerUser(
      accessToken: .mock, gitHubUser: .mock, email: "blob@pointfree.co", now: { .mock }
    )
    let subscription = try await self.database.createSubscription(.mock, user.id, true, nil, .pro)

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
      accessToken: .mock, gitHubUser: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.createSubscription(.mock, user.id, false, nil, .pro)

    let freshUser = try await self.database.fetchUserById(user.id)

    XCTAssertEqual(nil, freshUser.subscriptionId)
  }

  func testCreateSubscription_OwnerIsTakingSeat() async throws {
    let user = try await self.database.registerUser(
      accessToken: .mock, gitHubUser: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    let subscription = try await self.database.createSubscription(.mock, user.id, true, nil, .pro)

    let freshUser = try await self.database.fetchUserById(user.id)

    XCTAssertEqual(subscription.id, freshUser.subscriptionId)
  }

  func testUpdateEpisodeProgress() async throws {
    let user = try await self.database.registerUser(
      accessToken: .mock, gitHubUser: .mock, email: "blob@pointfree.co", now: { .mock }
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
      accessToken: .mock, gitHubUser: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.updateEpisodeProgress(episodeSequence, 99, true, user.id)

    var progress = try await self.database.fetchEpisodeProgress(user.id, episodeSequence)
    expectNoDifference(
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
    expectNoDifference(
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
      accessToken: .mock, gitHubUser: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.updateEpisodeProgress(1, 90, true, user.id)
    _ = try await self.database.updateEpisodeProgress(2, 20, true, user.id)
    _ = try await self.database.updateEpisodeProgress(3, 40, false, user.id)

    let progresses = try await self.database.fetchEpisodeProgresses(user.id)
    expectNoDifference(
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
      accessToken: .mock, gitHubUser: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    _ = try await self.database.updateEpisodeProgress(episodeSequence, progress, false, user.id)

    let fetchedProgress = try await self.database.fetchEpisodeProgress(user.id, episodeSequence)

    expectNoDifference(
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
      accessToken: .mock, gitHubUser: .mock, email: "blob@pointfree.co", now: { .mock }
    )

    do {
      _ = try await self.database.fetchEpisodeProgress(user.id, episodeSequence)
      XCTFail("fetchEpisodeProgress should throw")
    } catch {}
  }
}
