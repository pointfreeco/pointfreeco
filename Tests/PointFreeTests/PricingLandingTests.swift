import Dependencies
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
    //    SnapshotTesting.isRecording = true
  }

  func testLanding_LoggedIn_InactiveSubscriber() {
    var user = User.mock
    user.subscriptionId = nil

    DependencyValues.withValues {
      $0.database.fetchUserById = const(pure(user))
    } operation: {
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
}

class PricingLandingTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  func testLanding_LoggedIn_ActiveSubscriber() {
    DependencyValues.withValues {
      $0.database.fetchUserById = const(pure(.mock))
      $0.database.fetchSubscriptionById = const(pure(.mock))
      $0.database.fetchSubscriptionByOwnerId = const(pure(.mock))
    } operation: {
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
