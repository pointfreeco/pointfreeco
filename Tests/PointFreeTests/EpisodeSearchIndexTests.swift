import Models
import PointFreeTestSupport
import XCTest

@testable import PointFree

class EpisodeSearchIndexTests: TestCase {
  func testSearchDocuments() {
    let documents = transcriptSearchDocuments(
      episodeSequence: 1,
      publishedAt: Date(timeIntervalSince1970: 1_234_567_890),
      transcript: """
        ## Introduction

        @T(00:00:05, Brandon)
        Welcome to Point-Free.

        @Comment {
          An internal note.
        }

        ```swift
        func incr(_ x: Int) -> Int {
          x + 1
        }
        ```

        @T(00:01:08)
        We can call `incr` directly. See [our GitHub](https://github.com/pointfreeco) for **more** info.

        ## Composition

        @T(01:02:03)
        Function composition is the essence of this episode.
        """
    )

    XCTAssertEqual(documents.count, 5)

    XCTAssertEqual(documents[0].kind, .title)
    XCTAssertEqual(documents[0].content, "Introduction")
    XCTAssertEqual(documents[0].sectionTitle, "Introduction")
    XCTAssertEqual(documents[0].timestamp, 5)

    XCTAssertEqual(documents[1].kind, .prose)
    XCTAssertEqual(documents[1].sectionTitle, "Introduction")
    XCTAssertEqual(documents[1].timestamp, 5)
    XCTAssertEqual(
      documents[1].timestampMarkers,
      [
        EpisodeSearchDocument.TimestampMarker(offset: 0, seconds: 5),
        EpisodeSearchDocument.TimestampMarker(offset: 23, seconds: 68),
      ]
    )
    XCTAssertTrue(documents[1].content.contains("Welcome to Point-Free."))
    XCTAssertTrue(documents[1].content.contains("We can call `incr` directly."))
    XCTAssertTrue(documents[1].content.contains("See our GitHub for more info."))
    XCTAssertFalse(documents[1].content.contains("https://github.com/pointfreeco"))
    XCTAssertFalse(documents[1].content.contains("**"))
    XCTAssertFalse(documents[1].content.contains("func incr"))
    XCTAssertFalse(documents[1].content.contains("An internal note."))
    XCTAssertFalse(documents[1].content.contains("@T"))

    XCTAssertEqual(documents[2].kind, .code)
    XCTAssertEqual(documents[2].sectionTitle, "Introduction")
    XCTAssertEqual(documents[2].timestamp, 5)
    XCTAssertEqual(
      documents[2].timestampMarkers,
      [EpisodeSearchDocument.TimestampMarker(offset: 0, seconds: 5)]
    )
    XCTAssertEqual(
      documents[2].content,
      """
      func incr(_ x: Int) -> Int {
        x + 1
      }
      """
    )

    XCTAssertEqual(documents[3].kind, .title)
    XCTAssertEqual(documents[3].content, "Composition")
    XCTAssertEqual(documents[3].timestamp, 3723)

    XCTAssertEqual(documents[4].kind, .prose)
    XCTAssertEqual(documents[4].sectionTitle, "Composition")
    XCTAssertEqual(documents[4].timestamp, 3723)
    XCTAssertEqual(documents[4].content, "Function composition is the essence of this episode.")
    XCTAssertEqual(
      documents[4].timestampMarkers,
      [EpisodeSearchDocument.TimestampMarker(offset: 0, seconds: 3723)]
    )
  }
}
