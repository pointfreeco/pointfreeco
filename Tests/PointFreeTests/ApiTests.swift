import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

final class ApiTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testEmptyArray() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let value: [Int] = []

    XCTAssertEqual(String.init(decoding: try encoder.encode(value), as: UTF8.self) , """
[

]
""")
  }

  func testEpisodes() {
    let conn = connection(from: request(to: .api(.episodes)))
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn, as: .conn)
  }

  func testEpisode() {
    let conn = connection(from: request(to: .api(.episode(1))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testEpisode_NotFound() {
    let conn = connection(from: request(to: .api(.episode(424242))))
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(matching: conn, as: .conn)
  }
}
