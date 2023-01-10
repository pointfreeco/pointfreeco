import Dependencies
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

@MainActor
class CollectionsTests: TestCase {
  @Dependency(\.collections) var collections

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testCollectionIndex() async throws {
    await withDependencies {
      $0.collections = [
        .mock,
        .mock,
        .mock,
        .mock,
      ]
    } operation: {
      let conn = connection(
        from: request(to: .collections(), basicAuth: true)
      )

      await assertSnapshot(matching: await _siteMiddleware(conn), as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 1500)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 1900)),
            ]
          )
        }
      #endif
    }
  }

  func testCollectionShow() async throws {
    let conn = connection(
      from: request(to: .collections(.collection(self.collections[0].slug)), basicAuth: true)
    )

    await assertSnapshot(matching: await _siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 1100)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 1100)),
          ]
        )
      }
    #endif
  }

  func testCollectionSection() async throws {
    let conn = connection(
      from: request(
        to: .collections(
          .collection(
            self.collections[0].slug,
            .section(self.collections[0].sections[1].slug)
          )
        ),
        basicAuth: true
      )
    )

    await assertSnapshot(matching: await _siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
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
