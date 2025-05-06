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
            eventID: 42,
            isActive: true,
            isLive: true
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
  func testPastLivestream() async {
    await withDependencies {
      $0.database.fetchClipByVimeoVideoID = { id in
        Clip(
          id: Clip.ID(rawValue: UUID()),
          blurb: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor \
            incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \
            exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat
            """,
          createdAt: .mock,
          description: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor \
            incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \
            exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat
            """,
          duration: 100,
          order: 0,
          posterURL: "image.png",
          title: "Video Title",
          vimeoVideoID: id
        )
      }
    } operation: {
      let episode = request(to: .live(.stream(id: 42)))

      let conn = connection(from: episode)
      let result = await siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: result,
            as: [
              "desktop": .connWebView(size: .init(width: 1100, height: 1600)),
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
            eventID: 42,
            isActive: true,
            isLive: true
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
