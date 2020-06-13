import Either
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class PricingLandingIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
    //    record = true
  }

  func testLanding_LoggedIn_InactiveSubscriber() {
    var user = User.mock
    user.subscriptionId = nil

    Current.database.fetchUserById = const(pure(user))

    let conn = connection(from: request(to: .pricingLanding, session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 4200)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 4700)),
          ]
        )
      }
    #endif
  }
}

class PricingLandingTests: TestCase {
  override func setUp() {
    super.setUp()
    //    record = true
  }

  func testLanding_LoggedIn_ActiveSubscriber() {
    Current.database.fetchUserById = const(pure(.mock))
    Current.database.fetchSubscriptionById = const(pure(.mock))
    Current.database.fetchSubscriptionByOwnerId = const(pure(.mock))

    let conn = connection(from: request(to: .pricingLanding, session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 4000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 4600)),
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
            "mobile": .ioConnWebView(size: .init(width: 400, height: 4700)),
          ]
        )
      }
    #endif
  }
}
