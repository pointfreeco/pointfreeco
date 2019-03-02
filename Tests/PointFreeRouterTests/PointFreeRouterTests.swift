import Models
import PointFreeRouter
import UrlFormEncoding
import XCTest

class PointFreeRouterTests: XCTestCase {
  func testUpdateProfile() {
    let router = pointFreeRouter(appSecret: "deadbeef", mailgunApiKey: "deadbeef")
    let profileData = ProfileData(
      email: "blobby@blob.co",
      extraInvoiceInfo: nil,
      emailSettings: [:],
      name: "Blobby McBlob"
    )
    let route = Route.account(.update(profileData))

    guard let request = router.request(for: route) else {
        XCTFail("")
        return
    }

    XCTAssertEqual("POST", request.httpMethod)
    XCTAssertEqual("account", request.url?.path)
    XCTAssertEqual(
      profileData,
      try UrlFormDecoder().decode(ProfileData.self, from: request.httpBody!)
    )

    XCTAssertEqual(route, router.match(request: request))
  }
}
