import Either
import HttpPipeline
import Models
import Optics
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

class SubscriptionLandingTests: TestCase {

  override func setUp() {
    super.setUp()
    record = true
  }

  func testLanding_LoggedIn_ActiveSubscriber() {
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.admin)),
      \.database.fetchSubscriptionById .~ const(pure(.mock)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.mock))
    )

    let conn = connection(from: request(to: .subscribeLanding, session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1600)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1600))
        ]
      )
    }
    #endif
  }

  func testLanding_LoggedIn_InactiveSubscriber() {
    let user = User.admin |> \.subscriptionId .~ nil
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(user))
    )

    let conn = connection(from: request(to: .subscribeLanding, session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1600)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1600))
        ]
      )
    }
    #endif
  }
}
