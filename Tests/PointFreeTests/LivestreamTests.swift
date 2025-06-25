import Database
import DatabaseTestSupport
import Dependencies
import Either
import GitHub
import GitHubTestSupport
import Html
import HttpPipeline
import Models
import ModelsTestSupport
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class LivestreamTests: TestCase {
  override func setUp() {
    super.setUp()
    //isRecording = true
  }

  @MainActor
  func testCurrent() async {
    await withDependencies {
      $0.database.fetchLivestreams = {
        [
          Livestream(
            id: Livestream.ID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            isActive: true,
            isLive: true,
            videoID: "deadbeef"
          )
        ]
      }
    } operation: {
      let episode = request(to: .live(.current))

      let conn = connection(from: episode)
      let result = await siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: result,
            as: [
              "desktop": .connWebView(size: .init(width: 1100, height: 1000)),
              "mobile": .connWebView(size: .init(width: 500, height: 1000)),
            ]
          )
        }
      #endif
    }
  }

  @MainActor
  func testBanner() async {
    await withDependencies {
      $0.database.fetchLivestreams = {
        [
          Livestream(
            id: Livestream.ID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            isActive: true,
            isLive: true,
            videoID: "deadbeef"
          )
        ]
      }
    } operation: {
      let episode = request(to: .home)

      let conn = connection(from: episode)
      let result = await siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: result,
            as: [
              "desktop": .connWebView(size: .init(width: 1100, height: 400)),
              "mobile": .connWebView(size: .init(width: 500, height: 400)),
            ]
          )
        }
      #endif
    }
  }
}
