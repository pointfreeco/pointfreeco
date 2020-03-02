import ApplicativeRouter
import HttpPipeline
@testable import Models
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class HomeTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true

    var e1 = Episode.ep10_aTaleOfTwoFlatMaps
    e1.permission = .subscriberOnly
    e1.references = [.mock]
    let e2 = Episode.ep2_sideEffects
    var e3 = Episode.ep1_functions
    e3.permission = .subscriberOnly
    let e4 = Episode.ep0_introduction

    Current.episodes = unzurry(
      [e1, e2, e3, e4]
        .map { var e = $0; e.image = ""; return e }
    )
  }

  func testHomepage_LoggedOut() {
    let conn = connection(from: request(to: .home))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 3000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, as: .image, named: "desktop")

      webView.frame.size.width = 400
      webView.frame.size.height = 3500

      assertSnapshot(matching: webView, as: .image, named: "mobile")
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
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2800))
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
