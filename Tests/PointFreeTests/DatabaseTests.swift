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
    let publishedAt = Date(timeIntervalSince1970: 1_234_567_890)
    try await self.database.refreshEpisodeSearchIndex([
      EpisodeSearchDocument(
        content: "Functions",
        episodeSequence: 1,
        kind: .episodeTitle,
        publishedAt: publishedAt,
        sectionTitle: nil,
        timestamp: nil
      ),
      EpisodeSearchDocument(
        content: "We discuss what makes functions great.",
        episodeSequence: 1,
        kind: .blurb,
        publishedAt: publishedAt,
        sectionTitle: nil,
        timestamp: nil
      ),
      EpisodeSearchDocument(
        content: "Introduction",
        episodeSequence: 1,
        kind: .title,
        publishedAt: publishedAt,
        sectionTitle: "Introduction",
        timestamp: 68
      ),
      EpisodeSearchDocument(
        content: "We can define an increment function that takes an Int and returns an Int.",
        episodeSequence: 1,
        kind: .prose,
        publishedAt: publishedAt,
        sectionTitle: "Introduction",
        timestamp: 68
      ),
      EpisodeSearchDocument(
        content: "func increment(_ x: Int) -> Int { x + 1 }",
        episodeSequence: 1,
        kind: .code,
        publishedAt: publishedAt,
        sectionTitle: "Introduction",
        timestamp: 68
      ),
      EpisodeSearchDocument(
        content: "Swift's ~Copyable annotation marks types as noncopyable.",
        episodeSequence: 1,
        kind: .prose,
        publishedAt: publishedAt,
        sectionTitle: "Ownership",
        timestamp: 90
      ),
      EpisodeSearchDocument(
        content: "Murmurs and whispers",
        episodeSequence: 2,
        kind: .title,
        publishedAt: publishedAt,
        sectionTitle: "Murmurs and whispers",
        timestamp: 650
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
        publishedAt: publishedAt,
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
        publishedAt: publishedAt,
        sectionTitle: "Whispers",
        timestamp: 600
      ),
      EpisodeSearchDocument(
        content: "You should flibbertigibbet often, and flibbertigibbet loudly.",
        episodeSequence: 1,
        kind: .prose,
        publishedAt: publishedAt,
        sectionTitle: "Chatter",
        timestamp: 700
      ),
      EpisodeSearchDocument(
        content: "The `Flibbertigibbet` type is quite rare.",
        episodeSequence: 2,
        kind: .prose,
        publishedAt: publishedAt,
        sectionTitle: "Rare types",
        timestamp: 800
      ),
      {
        let filler = Array(
          repeating: "The quick brown fox jumps over the lazy dog.", count: 5
        ).joined(separator: " ")
        let opening = "A tintinnabulation rang out. "
        return EpisodeSearchDocument(
          content: "\(opening)\(filler)\n\(filler) And then a psithurism was heard.",
          episodeSequence: 2,
          kind: .prose,
          publishedAt: publishedAt,
          sectionTitle: "Sounds",
          timestamp: 900,
          timestampMarkers: [
            EpisodeSearchDocument.TimestampMarker(offset: 0, seconds: 900),
            EpisodeSearchDocument.TimestampMarker(
              offset: (opening + filler).unicodeScalars.count + 1,
              seconds: 999
            ),
          ]
        )
      }(),
      EpisodeSearchDocument(
        content: "Unreleased zymurgy",
        episodeSequence: 3,
        kind: .episodeTitle,
        publishedAt: Date().addingTimeInterval(60 * 60 * 24 * 30),
        sectionTitle: nil,
        timestamp: nil
      ),
    ])

    let searchResults = try await self.database.searchEpisodes(query: "increment function")
    XCTAssertEqual(1, searchResults.matchCount)
    let results = searchResults.results

    XCTAssertEqual(4, results.count)
    XCTAssertEqual(.episodeTitle, results[0].kind)
    XCTAssertEqual(Set([.blurb, .prose]), Set(results[1...2].map(\.kind)))
    XCTAssertEqual(.code, results[3].kind)
    XCTAssertEqual("⟪Functions⟫", results[0].snippet)
    XCTAssertEqual(["function"], results[0].matchedTerms)
    let prose = try XCTUnwrap(results.first(where: { $0.kind == .prose }))
    XCTAssertEqual(
      "We can define an ⟪increment⟫ ⟪function⟫ that takes an Int and returns an Int.",
      prose.snippet
    )
    XCTAssertEqual(["function", "increment"], prose.matchedTerms)
    XCTAssertEqual(1, prose.episodeSequence)
    XCTAssertEqual("Introduction", prose.sectionTitle)
    XCTAssertEqual(68, prose.timestamp)
    XCTAssertFalse(prose.snippetIsTruncatedAtStart)
    XCTAssertFalse(prose.snippetIsTruncatedAtEnd)

    let crossSectionResults = try await self.database.searchEpisodes(
      query: "borborygmus susurration"
    )
    XCTAssertEqual(
      ["Digressions", "Whispers"],
      crossSectionResults.results.compactMap(\.sectionTitle).sorted()
    )
    XCTAssertTrue(crossSectionResults.results.allSatisfy { $0.matchedTerms.count == 1 })

    let crossEpisodeResults = try await self.database.searchEpisodes(
      query: "borborygmus increment"
    )
    XCTAssertEqual(EpisodeSearchResults(), crossEpisodeResults)

    let orResults = try await self.database.searchEpisodes(query: "borborygmus or increment")
    XCTAssertEqual(2, orResults.matchCount)
    XCTAssertEqual([1, 2], Array(Set(orResults.results.map(\.episodeSequence))).sorted())

    let orAndResults = try await self.database.searchEpisodes(
      query: "psithurism borborygmus or increment"
    )
    XCTAssertEqual(1, orAndResults.matchCount)
    XCTAssertEqual([2], Array(Set(orAndResults.results.map(\.episodeSequence))).sorted())

    let negatedResults = try await self.database.searchEpisodes(query: "increment -copyable")
    XCTAssertEqual(EpisodeSearchResults(), negatedResults)

    let negatedKeptResults = try await self.database.searchEpisodes(query: "murmurs -increment")
    XCTAssertEqual(1, negatedKeptResults.matchCount)
    XCTAssertEqual([2], Array(Set(negatedKeptResults.results.map(\.episodeSequence))))

    let truncatedResults = try await self.database.searchEpisodes(query: "borborygmus").results
    XCTAssertEqual(1, truncatedResults.count)
    XCTAssertTrue(truncatedResults[0].snippet.contains("⟪borborygmus⟫"))
    XCTAssertTrue(truncatedResults[0].snippetIsTruncatedAtStart)
    XCTAssertTrue(truncatedResults[0].snippetIsTruncatedAtEnd)
    XCTAssertFalse(truncatedResults[0].snippetStartsInsideCodeSpan)

    let codeSpanResults = try await self.database.searchEpisodes(query: "susurration").results
    XCTAssertEqual(1, codeSpanResults.count)
    XCTAssertTrue(codeSpanResults[0].snippet.contains("⟪susurration⟫"))
    XCTAssertTrue(codeSpanResults[0].snippetIsTruncatedAtStart)
    XCTAssertTrue(codeSpanResults[0].snippetStartsInsideCodeSpan)

    let multiTermTitleResults =
      try await self.database.searchEpisodes(query: "murmurs whispers").results
    let titleRow = try XCTUnwrap(multiTermTitleResults.first(where: { $0.kind == .title }))
    XCTAssertTrue(titleRow.snippet.contains("⟪Murmurs⟫"))
    XCTAssertTrue(titleRow.snippet.contains("⟪whispers⟫"))
    XCTAssertEqual(2, titleRow.matchedTerms.count)

    let tildeResults = try await self.database.searchEpisodes(query: "~Copyable").results
    XCTAssertEqual(1, tildeResults.count)
    XCTAssertTrue(tildeResults[0].snippet.contains("⟪Copyable⟫"))

    let literalResults = try await self.database.searchEpisodes(query: "\"x + 1\"").results
    XCTAssertEqual(1, literalResults.count)
    XCTAssertEqual(.code, literalResults[0].kind)
    XCTAssertTrue(literalResults[0].snippet.contains("⟪x + 1⟫"))
    XCTAssertEqual(["\"x + 1\""], literalResults[0].matchedTerms)

    let markerResults = try await self.database.searchEpisodes(query: "psithurism").results
    XCTAssertEqual(1, markerResults.count)
    XCTAssertEqual(999, markerResults[0].timestamp)

    let fragmentResults = try await self.database.searchEpisodes(
      query: "tintinnabulation psithurism"
    ).results
    XCTAssertEqual(2, fragmentResults.count)
    let early = try XCTUnwrap(
      fragmentResults.first(where: { $0.snippet.contains("⟪tintinnabulation⟫") })
    )
    XCTAssertEqual(900, early.timestamp)
    let late = try XCTUnwrap(
      fragmentResults.first(where: { $0.snippet.contains("⟪psithurism⟫") })
    )
    XCTAssertEqual(999, late.timestamp)

    let unpublishedResults = try await self.database.searchEpisodes(query: "zymurgy")
    XCTAssertEqual(EpisodeSearchResults(), unpublishedResults)

    let capitalizedResults =
      try await self.database.searchEpisodes(query: "Flibbertigibbet").results
    XCTAssertEqual(["Rare types", "Chatter"], capitalizedResults.map(\.sectionTitle))

    let lowercasedResults =
      try await self.database.searchEpisodes(query: "flibbertigibbet").results
    XCTAssertEqual(["Chatter", "Rare types"], lowercasedResults.map(\.sectionTitle))

    let codeResults = try await self.database.searchEpisodes(query: "increment").results
    XCTAssertEqual([.prose, .code], codeResults.map(\.kind))

    let scopedResults = try await self.database.searchEpisodes(
      query: "increment", kinds: [.code], sequences: nil
    ).results
    XCTAssertEqual([.code], scopedResults.map(\.kind))

    let titleScopedResults = try await self.database.searchEpisodes(
      query: "functions", kinds: [.title, .episodeTitle], sequences: nil
    ).results
    XCTAssertEqual([.episodeTitle], titleScopedResults.map(\.kind))

    let sequenceScopedResults = try await self.database.searchEpisodes(
      query: "flibbertigibbet", kinds: nil, sequences: [2]
    )
    XCTAssertEqual(1, sequenceScopedResults.matchCount)
    XCTAssertEqual([2], sequenceScopedResults.results.map(\.episodeSequence))

    let titleResults = try await self.database.searchEpisodes(query: "introduction").results
    XCTAssertEqual([.title], titleResults.map(\.kind))
    XCTAssertEqual("⟪Introduction⟫", titleResults[0].snippet)

    let episodeTitleResults = try await self.database.searchEpisodes(query: "functions").results
    XCTAssertEqual([.episodeTitle, .blurb, .prose], episodeTitleResults.map(\.kind))
    XCTAssertEqual("⟪Functions⟫", episodeTitleResults[0].snippet)

    let blurbResults = try await self.database.searchEpisodes(query: "great functions").results
    XCTAssertEqual(3, blurbResults.count)
    let blurb = try XCTUnwrap(blurbResults.first(where: { $0.kind == .blurb }))
    XCTAssertTrue(blurb.snippet.contains("⟪great⟫"))
    XCTAssertTrue(blurb.snippet.contains("⟪functions⟫"))
    XCTAssertEqual(["functions", "great"], blurb.matchedTerms)
    XCTAssertEqual(nil, blurb.sectionTitle)

    let emptyResults = try await self.database.searchEpisodes(query: "quantum chromodynamics")
    XCTAssertEqual(EpisodeSearchResults(), emptyResults)

    try await self.database.refreshEpisodeSearchIndex([])
    let clearedResults = try await self.database.searchEpisodes(query: "increment function")
    XCTAssertEqual(EpisodeSearchResults(), clearedResults)
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
