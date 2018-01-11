import ApplicativeRouter
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
#if !os(Linux)
  import WebKit
#endif

class AtomFeedTests: TestCase {
  func testAtomFeed() {
    let conn = connection(from: request(to: .feed(.atom)))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }
}
