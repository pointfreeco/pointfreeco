import ApplicativeRouter
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
import Optics
#if !os(Linux)
import WebKit
#endif

class HomeTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true

    let eps = [
      ep10 |> \.permission .~ .subscriberOnly,
      ep2,
      ep1 |> \.permission .~ .subscriberOnly,
      introduction,
      ]
      .suffix(4)
      .map(\.image .~ "")

    update(
      &Current, 
      \.database .~ .mock,
      \.episodes .~ unzurry(eps)
    )
  }

  func testHomepage_LoggedOut() {
    let conn = connection(from: request(to: .home))
    let result = conn |> siteMiddleware

    assertSnapshot(of: .ioConn, matching: result)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 3000))
      webView.loadHTMLString(String(decoding: result.perform().data, as: UTF8.self), baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 400
      webView.frame.size.height = 3500

      self.assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testHomepage_Subscriber() {
    let conn = connection(from: request(to: .home, session: .loggedIn))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        of: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2300)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2800))
        ],
        matching: conn |> siteMiddleware
      )
    }
    #endif
  }

  func testEpisodesIndex() {
    let conn = connection(from: request(to: .episodes))

    assertSnapshot(of: .ioConn, matching: conn |> siteMiddleware)
  }
}
