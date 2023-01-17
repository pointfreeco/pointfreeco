import Dependencies
import HttpPipeline
import PointFreePrelude
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
class HomeTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  override func invokeTest() {
    withDependencies {
      var e1 = Episode.ep10_aTaleOfTwoFlatMaps
      e1.permission = .subscriberOnly
      e1.references = [.mock]
      let e2 = Episode.ep2_sideEffects
      var e3 = Episode.ep1_functions
      e3.permission = .subscriberOnly
      let e4 = Episode.ep0_introduction
      $0.episodes = unzurry(
        [e1, e2, e3, e4]
          .map {
            var e = $0
            e.image = "http://localhost:8080/images/\(e.sequence).jpg"
            return e
          }
      )
    } operation: {
      super.invokeTest()
    }
  }

  func testHomepage_LoggedOut() async throws {
    let conn = connection(from: request(to: .home))
    let result = await siteMiddleware(conn)

    await assertSnapshot(matching: result, as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: await siteMiddleware(conn),
          as: [
            "desktop": .connWebView(size: .init(width: 1080, height: 3000)),
            "mobile": .connWebView(size: .init(width: 400, height: 3500)),
          ]
        )
      }
    #endif
  }

  func testHomepage_Subscriber() async throws {
    await withDependencies {
      $0.database.fetchEpisodeProgresses = { [dependencies = $0] userID in
        [
          EpisodeProgress(
            episodeSequence: dependencies.episodes()[0].sequence,
            id: EpisodeProgress.ID(),
            isFinished: true,
            percent: 100,
            userID: userID
          ),
          EpisodeProgress(
            episodeSequence: dependencies.episodes()[1].sequence,
            id: EpisodeProgress.ID(),
            isFinished: false,
            percent: 30,
            userID: userID
          ),
          EpisodeProgress(
            episodeSequence: dependencies.episodes()[2].sequence,
            id: EpisodeProgress.ID(),
            isFinished: true,
            percent: 20,
            userID: userID
          ),
        ]
      }
    } operation: {
      let conn = connection(from: request(to: .home, session: .loggedIn))

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(conn),
            as: [
              "desktop": .connWebView(size: .init(width: 1080, height: 2300)),
              "mobile": .connWebView(size: .init(width: 400, height: 2800)),
            ]
          )
        }
      #endif
    }
  }

  func testEpisodesIndex() async throws {
    let conn = connection(from: request(to: .episode(.index)))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }
}
