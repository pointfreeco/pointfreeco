import Either
import HttpPipeline
@testable import Models
import ModelsTestSupport
@testable import PointFree
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class CollectionsTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testCollectionShow() {
    let conn = connection(
      from: request(to: .collections(.show("map-zip-flatmap")))
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 1100)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 1100))
        ]
      )
    }
    #endif
  }
}
