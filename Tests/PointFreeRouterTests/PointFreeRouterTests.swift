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
      teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.com"],
      token: "deadbeef"
    )
    let route = Route.subscribe(subscribeData)
    let request = pointFreeRouter.request(for: route)!

    assertSnapshot(matching: request, as: .raw)

    XCTAssertEqual(pointFreeRouter.match(request: request)!, route)
  }
}
