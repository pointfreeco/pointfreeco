import Models
import PointFreeRouter
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
}
