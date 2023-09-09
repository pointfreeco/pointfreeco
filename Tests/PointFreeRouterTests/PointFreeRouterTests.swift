import CustomDump
import Dependencies
import InlineSnapshotTesting
import Models
import PointFreePrelude
import PointFreeTestSupport
import URLRouting
import UrlFormEncoding
import XCTest

@testable import PointFreeRouter

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@MainActor
class PointFreeRouterTests: TestCase {
  @Dependency(\.siteRouter) var siteRouter

  func testUpdateProfile() async throws {
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

  func testSubscribeRoute_FormData() async throws {
    let subscribeData = SubscribeData(
      coupon: "student-discount",
      isOwnerTakingSeat: false,
      paymentMethodID: "pm_deadbeef",
      pricing: .init(billing: .monthly, quantity: 4),
      referralCode: "cafed00d",
      subscriptionID: nil,
      teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.com"],
      useRegionalDiscount: true
    )
    let route = SiteRoute.subscribe(subscribeData)
    let request = try! siteRouter.request(for: route)

    await assertInlineSnapshot(of: request, as: .raw) {
      """
      POST http://localhost:8080/subscribe

      coupon=student-discount&paymentMethodID=pm_deadbeef&pricing%5Bbilling%5D=monthly&pricing%5Bquantity%5D=4&ref=cafed00d&teammate=blob.jr%40pointfree.co&teammate=blob.sr%40pointfree.com&useRegionalDiscount=true
      """
    }

    XCTAssertEqual(try siteRouter.match(request: request), route)
  }

  func testEpisodeShowRoute() async throws {
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

  func testEpisodeProgressRoute() async throws {
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

  func testTeamJoinLanding() async throws {
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

  func testTeamJoin() async throws {
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

  func testGiftsIndex() async throws {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts")!)

    let route = SiteRoute.gifts()

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testGiftsPlan() async throws {
    let request = URLRequest.init(url: .init(string: "http://localhost:8080/gifts/threeMonths")!)

    let route = SiteRoute.gifts(.plan(.threeMonths))

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testGiftsRedeemLanding() async throws {
    let request = URLRequest.init(
      url: .init(string: "http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7")!)

    let route = SiteRoute.gifts(
      .redeem(.init(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!))

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testGiftsRedeem() async throws {
    var request = URLRequest.init(
      url: .init(string: "http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7")!)
    request.httpMethod = "POST"

    let route = SiteRoute.gifts(
      .redeem(.init(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!, .confirm))

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testLive() async throws {
    var request = URLRequest.init(
      url: .init(string: "http://localhost:8080/live")!)
    var route = SiteRoute.live(.current)
    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)

    request = URLRequest.init(
      url: .init(string: "http://localhost:8080/live/streams/1")!)
    route = SiteRoute.live(.stream(id: 1))
    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }

  func testCollectionEpisodeProgress() throws {
    var request = URLRequest(
      url: URL(string: "http://localhost:8080/collections/tca/basics/1/progress?percent=50")!
    )
    request.httpMethod = "POST"
    let route = SiteRoute.collections(
      .collection("tca", .section("basics", .progress(param: .left("1"), percent: 50)))
    )

    XCTAssertEqual(try siteRouter.match(request: request), route)
    XCTAssertEqual(try siteRouter.request(for: route), request)
  }
}
