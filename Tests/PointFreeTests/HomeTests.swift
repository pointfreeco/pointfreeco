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

class HomeTests: TestCase {
  override func setUp() {
    super.setUp()
    // SnapshotTesting.isRecording=true
  }

  override func invokeTest() {
    DependencyValues.withTestValues {
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

  func testHomepage_LoggedOut() {
    let conn = connection(from: request(to: .home))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: result,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 3000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 3500)),
          ]
        )
      }
    #endif
  }

  func testHomepage_Subscriber() {
    let conn = connection(from: request(to: .home, session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2300)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2800)),
          ]
        )
      }
    #endif
  }

  func testEpisodesIndex() {
    let conn = connection(from: request(to: .episode(.index)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
