#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Models
import PointFreeRouter
import SnapshotTesting
import UrlFormEncoding
import XCTest

class PointFreeRouterTests: XCTestCase {
  func testUpdateProfile() {
    let profileData = ProfileData(
      email: "blobby@blob.co",
      extraInvoiceInfo: nil,
      emailSettings: [:],
      name: "Blobby McBlob"
    )
    let route = Route.account(.update(profileData))

    guard let request = pointFreeRouter.request(for: route) else {
        XCTFail("")
        return
    }

    XCTAssertEqual("POST", request.httpMethod)
    XCTAssertEqual("/account", request.url?.path)
    XCTAssertEqual(route, pointFreeRouter.match(request: request))
  }

  func testSubscribeRoute() {
    let subscribeData = SubscribeData(
      coupon: "student-discount",
      isOwnerTakingSeat: false,
      pricing: .init(billing: .monthly, quantity: 4),
      referralCode: "cafed00d",
      teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.com"],
      token: "deadbeef"
    )
    let route = Route.subscribe(subscribeData)
    let request = pointFreeRouter.request(for: route)!

    _assertInlineSnapshot(matching: request, as: .raw, with: """
POST http://localhost:8080/subscribe

coupon=student-discount&isOwnerTakingSeat=false&pricing[billing]=monthly&pricing[quantity]=4&teammates[0]=blob.jr@pointfree.co&teammates[1]=blob.sr@pointfree.com&token=deadbeef&ref=cafed00d
""")

    XCTAssertEqual(pointFreeRouter.match(request: request)!, route)
  }

  func testEpisodeShowRoute() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/episodes/ep10-hello-world")!)

    let route = Route.episode(.show(.left("ep10-hello-world")))

    XCTAssertEqual(
      pointFreeRouter.match(request: request),
      route
    )

    XCTAssertEqual(
      pointFreeRouter.request(for: route),
      request
    )
  }

  func testEpisodeProgressRoute() {
    var request = URLRequest(
      url: URL(string: "http://localhost:8080/episodes/ep10-hello-world/progress?percent=50")!
    )
    request.httpMethod = "POST"

    let route = Route.episode(.progress(param: .left("ep10-hello-world"), percent: 50))

    XCTAssertEqual(
      pointFreeRouter.match(request: request),
      route
    )

    XCTAssertEqual(
      pointFreeRouter.request(for: route),
      request
    )
  }
}
