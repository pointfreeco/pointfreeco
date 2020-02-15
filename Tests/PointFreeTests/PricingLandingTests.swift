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

class PricingLandingTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testLanding_LoggedIn_ActiveSubscriber() {
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.admin)),
      \.database.fetchSubscriptionById .~ const(pure(.mock)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.mock))
    )

    let conn = connection(from: request(to: .pricingLanding, session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 4000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 4600))
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

    let conn = connection(from: request(to: .pricingLanding, session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 4200)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 4700))
        ]
      )
    }
    #endif
  }

  func testLanding_LoggedOut() {
    let conn = connection(from: request(to: .pricingLanding, session: .loggedOut))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 4200)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 4700))
        ]
      )
    }
    #endif
  }
}
