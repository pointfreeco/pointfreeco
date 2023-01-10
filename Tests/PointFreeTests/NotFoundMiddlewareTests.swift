import Dependencies
import Either
import HttpPipeline
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
#if !os(Linux)
  import WebKit
#endif

final class NotFoundMiddlewareTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testNotFound() async throws {
    let conn = connection(from: URLRequest(url: URL(string: "http://localhost:8080/404")!))

    await assertSnapshot(matching: await _siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1000)),
          ]
        )
      }
    #endif
  }

  func testNotFound_LoggedIn() async throws {
    await withDependencies {
      $0 = .test
      $0.date.now = .mock
      $0.uuid = .incrementing
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.database.fetchUserById = { _ in .mock }
      $0.database.sawUser = { _ in }
    } operation: {
      var req = request(to: .home, session: .loggedIn(as: .mock))
      req.url?.appendPathComponent("404")
      let conn = connection(from: req)

      await assertSnapshot(matching: await _siteMiddleware(conn), as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1080, height: 1000)),
              "mobile": .ioConnWebView(size: .init(width: 400, height: 1000)),
            ]
          )
        }
      #endif
    }
  }
}
