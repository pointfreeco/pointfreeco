import Either
import HttpPipeline
import ModelsTestSupport
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import Models
@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class CollectionsTests: TestCase {
  override func setUp() {
    super.setUp()
    //    record = true
  }

  func testCollectionIndex() {
    Current.collections = [
      .mock,
      .mock,
      .mock,
      .mock,
    ]

    let conn = connection(
      from: request(to: .collections(.index), basicAuth: true)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 1500)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 1900)),
          ]
        )
      }
    #endif
  }

  func testCollectionShow() {
    let conn = connection(
      from: request(to: .collections(.show(Current.collections[0].slug)), basicAuth: true)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 1100)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 1100)),
          ]
        )
      }
    #endif
  }

  func testCollectionSection() {
    let conn = connection(
      from: request(
        to: .collections(
          .section(
            Current.collections[0].slug,
            Current.collections[0].sections[1].slug
          )
        ),
        basicAuth: true
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 1800)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 1800)),
          ]
        )
      }
    #endif
  }
}
