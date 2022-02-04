import CustomDump
import Models
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import SnapshotTesting
import UrlFormEncoding
import XCTest

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class PointFreeRouterTests: TestCase {
  func testUpdateProfile() {
    let profileData = ProfileData(
      email: "blobby@blob.co",
      extraInvoiceInfo: nil,
      emailSettings: [:],
      name: "Blobby McBlob"
    )
    let route = AppRoute.account(.update(profileData))

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
      token: "deadbeef",
      useRegionalDiscount: true
    )
    let route = AppRoute.subscribe(subscribeData)
    let request = pointFreeRouter.request(for: route)!

    _assertInlineSnapshot(matching: request, as: .raw, with: """
POST http://localhost:8080/subscribe

coupon=student-discount&pricing%5Bbilling%5D=monthly&pricing%5Bquantity%5D=4&ref=cafed00d&teammate=blob.jr%40pointfree.co&teammate=blob.sr%40pointfree.com&token=deadbeef&useRegionalDiscount=true
""")

    XCTAssertEqual(pointFreeRouter.match(request: request)!, route)
  }

  func testEpisodeShowRoute() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/episodes/ep10-hello-world")!)

    let route = AppRoute.episode(.show(.left("ep10-hello-world")))

    XCTAssertEqual(
      pointFreeRouter.match(request: request),
      route
    )

    XCTAssertNoDifference(
      pointFreeRouter.request(for: route),
      request
    )
  }

  func testEpisodeProgressRoute() {
    var request = URLRequest(
      url: URL(string: "http://localhost:8080/episodes/ep10-hello-world/progress?percent=50")!
    )
    request.httpMethod = "POST"

    let route = AppRoute.episode(.progress(param: .left("ep10-hello-world"), percent: 50))

    XCTAssertEqual(
      pointFreeRouter.match(request: request),
      route
    )

    XCTAssertEqual(
      pointFreeRouter.request(for: route),
      request
    )
  }

  func testTeamJoinLanding() {
    let request = URLRequest(
      url: URL(string: "http://localhost:8080/team/deadbeef/join")!
    )

    let route = AppRoute.team(.joinLanding("deadbeef"))

    XCTAssertEqual(
      pointFreeRouter.match(request: request),
      route
    )

    XCTAssertEqual(
      pointFreeRouter.request(for: route),
      request
    )
  }

  func testTeamJoin() {
    var request = URLRequest(url: .init(string: "http://localhost:8080/team/deadbeef/join")!)
    request.httpMethod = "POST"

    let route = AppRoute.team(.join("deadbeef"))

    XCTAssertEqual(
      pointFreeRouter.match(request: request),
      route
    )

    XCTAssertEqual(
      pointFreeRouter.request(for: route),
      request
    )
  }

  func testGiftsIndex() {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts")!)

    let route = AppRoute.gifts(.index)

    XCTAssertEqual(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }

  func testGiftsPlan() {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts/threeMonths")!)

    let route = AppRoute.gifts(.plan(.threeMonths))

    XCTAssertEqual(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }

  func testGiftsRedeemLanding() {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7")!)

    let route = AppRoute.gifts(.redeemLanding(.init(rawValue: UUID(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!)))

    XCTAssertEqual(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }

  func testGiftsRedeem() {
    var request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7")!)
    request.httpMethod = "POST"

    let route = AppRoute.gifts(.redeem(.init(rawValue: UUID(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!)))

    XCTAssertEqual(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }

  func testGiftsConfirmation() {
    var request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts")!)
    request.httpMethod = "POST"
    request.httpBody = Data("""
      fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=3&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.
      """.utf8)

    let route = AppRoute.gifts(.confirmation(update(.empty) {
      $0.fromEmail = "blob@pointfree.co"
      $0.fromName = "Blob"
      $0.message = "HBD!"
      $0.monthsFree = 3
      $0.toEmail = "blob.jr@pointfree.co"
      $0.toName = "Blob Jr."
    }))

    XCTAssertNoDifference(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }
}
