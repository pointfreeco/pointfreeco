import Dependencies
import HttpPipeline
import Models
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import PointFree

class SearchTests: TestCase {
  override func setUp() {
    super.setUp()
    //SnapshotTesting.isRecording=true
  }

  @MainActor
  func testSearch() async throws {
    let conn = connection(from: request(to: .search()))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testSearch_NoResults() async throws {
    try await withDependencies {
      $0.database.searchEpisodes = { _ in [] }
      $0.database.suggestEpisodeSearchTerms = { _ in
        ["Modern UIKit", "UIKit navigation"]
      }
      $0.episodes = { [.free, .subscriberOnly] }
    } operation: {
      let conn = connection(from: request(to: .search(query: "uikot")))

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testSearch_Results_FreeFilter() async throws {
    try await withDependencies {
      $0.database.searchEpisodes = { _ in
        [
          EpisodeSearchResult(
            episodeSequence: 2,
            headline: "⟪Functions⟫ with compiler proofs",
            kind: .prose,
            sectionTitle: "Proofs",
            timestamp: 10
          ),
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "We can define ⟪functions⟫ by extending `Int`.",
            kind: .prose,
            sectionTitle: "Introduction",
            timestamp: 68
          ),
        ]
      }
      $0.episodes = { [.free, .subscriberOnly] }
    } operation: {
      let conn = connection(
        from: request(to: .search(query: "functions", access: .free, sort: .newest))
      )

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testSearch_Results() async throws {
    try await withDependencies {
      $0.database.searchEpisodes = { _ in
        [
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "⟪Incrementing⟫ and ⟪functions⟫",
            kind: .episodeTitle,
            sectionTitle: nil,
            timestamp: nil
          ),
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "⟪Incrementing⟫ numbers",
            kind: .title,
            sectionTitle: "Incrementing numbers",
            timestamp: 120
          ),
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "Functions that ⟪increment⟫",
            kind: .title,
            sectionTitle: "Functions that increment",
            timestamp: 68
          ),
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "We can define an ⟪increment⟫ ⟪function⟫ by extending `Int`",
            headlineIsTruncatedAtEnd: true,
            headlineIsTruncatedAtStart: true,
            kind: .prose,
            sectionTitle: "Functions that increment",
            timestamp: 68
          ),
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "func ⟪increment⟫(_ x: Int) -> Int {\n  x + 1\n}",
            kind: .code,
            sectionTitle: "Functions that increment",
            timestamp: 68
          ),
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "Never>` effect because it doesn’t ⟪increment⟫ anything",
            headlineIsTruncatedAtEnd: true,
            headlineIsTruncatedAtStart: true,
            headlineStartsInsideCodeSpan: true,
            kind: .prose,
            sectionTitle: "Functions that increment",
            timestamp: 68
          ),
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "pretty` was ⟪increment⟫ed by `Goodnight",
            headlineIsTruncatedAtEnd: true,
            headlineIsTruncatedAtStart: true,
            headlineStartsInsideCodeSpan: true,
            kind: .prose,
            sectionTitle: "Functions that increment",
            timestamp: 68
          ),
          EpisodeSearchResult(
            episodeSequence: 1,
            headline: "We discuss what makes ⟪functions⟫ great.",
            kind: .blurb,
            sectionTitle: nil,
            timestamp: nil
          ),
          EpisodeSearchResult(
            episodeSequence: 2,
            headline: "⟪Functions⟫ and proofs go hand in hand.",
            kind: .prose,
            sectionTitle: "Proofs as programs",
            timestamp: 300
          ),
          EpisodeSearchResult(
            episodeSequence: 2,
            headline: "⟪Functions⟫ can be bound to controls.",
            kind: .prose,
            sectionTitle: "`UIControl` bindings",
            timestamp: 400
          ),
        ]
      }
      $0.episodes = { [.free, .subscriberOnly] }
    } operation: {
      let conn = connection(from: request(to: .search(query: "increment function")))

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }
}
