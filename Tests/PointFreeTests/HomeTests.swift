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

  func testHomepage_LoggedOut() async throws {
    let conn = connection(from: request(to: .home))
    let result = conn |> siteMiddleware

    await assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 3000))
        await webView.loadHTMLString(
          String(decoding: result.performAsync().data, as: UTF8.self), baseURL: nil
        )
        await assertSnapshot(matching: webView, as: .image, named: "desktop")

        webView.frame.size.width = 400
        webView.frame.size.height = 3500

        await assertSnapshot(matching: webView, as: .image, named: "mobile")
      }
    #endif
  }

  func testHomepage_Subscriber() async throws {
    let conn = connection(from: request(to: .home, session: .loggedIn))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2300)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2800)),
          ]
        )
      }
    #endif
  }

  func testEpisodesIndex() async throws {
    let conn = connection(from: request(to: .episode(.index)))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
