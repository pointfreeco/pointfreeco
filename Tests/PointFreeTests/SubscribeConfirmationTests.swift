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

class SubscriptionConfirmationTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testPersonal_LoggedIn() {
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.personal), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1200))
        ]
      )
    }
    #endif
  }

  func testTeam_LoggedIn() {
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock |> \.gitHubUserId .~ -1)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.team), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1400))
        ]
      )
    }
    #endif
  }

  func testPersonal_LoggedIn_ActiveSubscriber() {
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.mock)),
      \.database.fetchSubscriptionById .~ const(pure(.mock)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.mock))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.personal), session: .loggedIn))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)
  }

  func testPersonal_LoggedOut() {
    update(
      &Current,
      \.database.fetchUserById .~ const(pure(nil)),
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .subscribeConfirmation(.personal), session: .loggedOut))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result, as: .ioConn)
  }
}
