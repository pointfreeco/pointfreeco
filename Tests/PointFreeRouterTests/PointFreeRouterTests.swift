import CustomDump
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Models
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import SnapshotTesting
import UrlFormEncoding
import XCTest

class PointFreeRouterTests: TestCase {
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
      token: "deadbeef",
      useRegionalDiscount: true
    )
    let route = Route.subscribe(subscribeData)
    let request = pointFreeRouter.request(for: route)!

    _assertInlineSnapshot(matching: request, as: .raw, with: """
POST http://localhost:8080/subscribe

coupon=student-discount&isOwnerTakingSeat=false&pricing[billing]=monthly&pricing[quantity]=4&teammates[0]=blob.jr@pointfree.co&teammates[1]=blob.sr@pointfree.com&token=deadbeef&ref=cafed00d&useRegionalDiscount=true
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

  func testTeamJoinLanding() {
    let request = URLRequest(
      url: URL(string: "http://localhost:8080/team/deadbeef/join")!
    )

    let route = Route.team(.joinLanding("deadbeef"))

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

    let route = Route.team(.join("deadbeef"))

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

    let route = Route.gifts(.index)

    XCTAssertEqual(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }

  func testGiftsPlan() {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts/threeMonths")!)

    let route = Route.gifts(.plan(.threeMonths))

    XCTAssertEqual(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }

  func testGiftsRedeemLanding() {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7")!)

    let route = Route.gifts(.redeemLanding(.init(rawValue: UUID(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!)))

    XCTAssertEqual(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }

  func testGiftsRedeem() {
    var request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7")!)
    request.httpMethod = "POST"

    let route = Route.gifts(.redeem(.init(rawValue: UUID(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!)))

    XCTAssertEqual(pointFreeRouter.match(request: request), route)
    XCTAssertEqual(pointFreeRouter.request(for: route), request)
  }

  func testGiftsConfirmation() {
    var request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts")!)
    request.httpMethod = "POST"
    request.httpBody = Data("""
      fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=3&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.
      """.utf8)

    let route = Route.gifts(.confirmation(update(.empty) {
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
