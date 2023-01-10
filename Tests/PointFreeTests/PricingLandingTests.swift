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

@MainActor
class PricingLandingIntegrationTests: LiveDatabaseTestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testLanding_LoggedIn_InactiveSubscriber() async throws {
    var user = User.mock
    user.subscriptionId = nil

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
    } operation: {
      let conn = connection(from: request(to: .pricingLanding, session: .loggedIn))
      let result = await _siteMiddleware(conn)

      await assertSnapshot(matching: result, as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
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

@MainActor
class PricingLandingTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testLanding_LoggedIn_ActiveSubscriber() async throws {
    await withDependencies {
      $0.database.fetchUserById = { _ in .mock }
      $0.database.fetchSubscriptionById = { _ in .mock }
      $0.database.fetchSubscriptionByOwnerId = { _ in .mock }
    } operation: {
      let conn = connection(from: request(to: .pricingLanding, session: .loggedIn))
      let result = await _siteMiddleware(conn)
      await assertSnapshot(matching: result, as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
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

  func testLanding_LoggedOut() async throws {
    let conn = connection(from: request(to: .pricingLanding, session: .loggedOut))
    let result = await _siteMiddleware(conn)

    await assertSnapshot(matching: result, as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
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
