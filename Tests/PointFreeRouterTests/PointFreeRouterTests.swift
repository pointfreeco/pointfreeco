import CustomDump
import Models
import PointFreePrelude
@testable import PointFreeRouter
import PointFreeTestSupport
import SnapshotTesting
import UrlFormEncoding
import URLRouting
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
    let route = SiteRoute.account(.update(profileData))

    guard let request = try? siteRouter.request(for: route) else {
      XCTFail("")
      return
    }

    XCTAssertEqual("POST", request.httpMethod)
    XCTAssertEqual("/account", request.url?.path)
    XCTAssertEqual(route, try siteRouter.match(request: request))
  }

  func testSubscribeRoute_FormData() {
    let subscribeData = SubscribeData(
      coupon: "student-discount",
      isOwnerTakingSeat: false,
      paymentType: .token("deadbeef"),
      pricing: .init(billing: .monthly, quantity: 4),
      referralCode: "cafed00d",
      teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.com"],
      useRegionalDiscount: true
    )
    let route = SiteRoute.subscribe(subscribeData)
    let request = try! siteRouter.request(for: route)

    _assertInlineSnapshot(
      matching: request, as: .raw,
      with: """
        POST http://localhost:8080/subscribe

        coupon=student-discount&pricing%5Bbilling%5D=monthly&pricing%5Bquantity%5D=4&ref=cafed00d&teammate=blob.jr%40pointfree.co&teammate=blob.sr%40pointfree.com&token=deadbeef&useRegionalDiscount=true
        """)

    XCTAssertEqual(try siteRouter.match(request: request), route)
  }

//  func testSubscribeRoute_JSONData() throws {
//    let request = URLRequestData(
//      method: "POST",
//      scheme: "http",
//      host: "localhost",
//      port: 8080,
//      path: "subscribe",
//      body: Data(
//        """
//        {"coupon":"student-discount","isOwnerTakingSeat":true,"paymenthMethodID": "pm_deadbeef","pricing":{"billing":"monthly","quantity":1},"teammates":[],"token":"src_deadbeef","useRegionalDiscount":false}
//        """.utf8
//      )
//    )
//
//    let route = SiteRoute.subscribe(
//      .init(
//        coupon: "student-discount",
//        isOwnerTakingSeat: true,
//        paymentType: .token("src_deadbeef"),
//        pricing: .individualMonthly,
//        referralCode: nil,
//        teammates: [],
//        useRegionalDiscount: false
//      )
//    )
//
//    XCTAssertNoDifference(try siteRouter.parse(request), route)
//
//    try JSONDecoder().decode(SubscribeData.self, from: Data("""
//      {"isOwnerTakingSeat":false,"paymenthMethodID":"pm_1MDc7sD0Nyli3dRg4bIYC6t2","pricing":{"billing":"yearly","quantity":1},"teammates":[]}
//
//      """.utf8))
//  }

  func testEpisodeShowRoute() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/episodes/ep10-hello-world")!)

    let route = SiteRoute.episode(.show(.left("ep10-hello-world")))

    XCTAssertEqual(
      try siteRouter.match(request: request),
      route
    )

    XCTAssertNoDifference(
      try siteRouter.request(for: route),
      request
    )
  }

  func testEpisodeProgressRoute() {
    var request = URLRequest(
      url: URL(string: "http://localhost:8080/episodes/ep10-hello-world/progress?percent=50")!
    )
    request.httpMethod = "POST"

    let route = SiteRoute.episode(.progress(param: .left("ep10-hello-world"), percent: 50))

    XCTAssertEqual(
      try siteRouter.match(request: request),
      route
    )

    XCTAssertEqual(
      try siteRouter.request(for: route),
      request
    )
  }

  func testTeamJoinLanding() {
    let request = URLRequest(
      url: URL(string: "http://localhost:8080/team/deadbeef/join")!
    )

    let route = SiteRoute.team(.join("deadbeef"))

    XCTAssertEqual(
      try siteRouter.match(request: request),
      route
    )

    XCTAssertEqual(
      try siteRouter.request(for: route),
      request
    )
  }

  func testTeamJoin() {
    var request = URLRequest(url: .init(string: "http://localhost:8080/team/deadbeef/join")!)
    request.httpMethod = "POST"

    let route = SiteRoute.team(.join("deadbeef", .confirm))

    XCTAssertEqual(
      try siteRouter.match(request: request),
      route
    )

    XCTAssertEqual(
      try siteRouter.request(for: route),
      request
    )
  }

  func testGiftsIndex() {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts")!)

    let route = SiteRoute.gifts()

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testGiftsPlan() {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts/threeMonths")!)

    let route = SiteRoute.gifts(.plan(.threeMonths))

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testGiftsRedeemLanding() {
    let request = URLRequest.init(
      url: .init(string: "http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7")!)

    let route = SiteRoute.gifts(
      .redeem(.init(rawValue: UUID(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!)))

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testGiftsRedeem() {
    var request = URLRequest.init(
      url: .init(string: "http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7")!)
    request.httpMethod = "POST"

    let route = SiteRoute.gifts(
      .redeem(.init(rawValue: UUID(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!), .confirm))

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testGiftsConfirmation() {
    var request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts")!)
    request.httpMethod = "POST"
    request.httpBody = Data(
      """
      fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=3&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.
      """.utf8)

    let route = SiteRoute.gifts(
      .confirmation(
        update(.empty) {
          $0.fromEmail = "blob@pointfree.co"
          $0.fromName = "Blob"
          $0.message = "HBD!"
          $0.monthsFree = 3
          $0.toEmail = "blob.jr@pointfree.co"
          $0.toName = "Blob Jr."
        }))

    XCTAssertNoDifference(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }
}
