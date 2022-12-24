import Either
import HttpPipeline
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import XCTest

@testable import PointFree

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@MainActor
class DiscountsTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  func testDiscounts_LoggedOut() async throws {
    await assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil)))
        |> siteMiddleware,
      as: .ioConn
    )

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: connection(from: request(to: .discounts(code: "blobfest", nil)))
            |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testDiscounts_LoggedIn_PercentOff_Forever() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "50% off forever",
      rate: .percentOff(50),
      valid: true
    )
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    Current.stripe.fetchCoupon = { _ in fiftyPercentOffForever }

    await assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: connection(
            from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn)
          )
            |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testDiscounts_LoggedIn_5DollarsOff_Forever() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "$5 off forever",
      rate: .amountOff(5_00),
      valid: true
    )
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    Current.stripe.fetchCoupon = { _ in fiftyPercentOffForever }

    await assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_PercentOff_Repeating() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .repeating(months: 12),
      id: "deadbeef",
      name: "50% off 12 months",
      rate: .percentOff(50),
      valid: true
    )
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    Current.stripe.fetchCoupon = { _ in fiftyPercentOffForever }

    await assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_5DollarsOff_Repeating() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .repeating(months: 12),
      id: "deadbeef",
      name: "$5 off for 12 months",
      rate: .amountOff(5_00),
      valid: true
    )
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    Current.stripe.fetchCoupon = { _ in fiftyPercentOffForever }

    await assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_PercentOff_Once() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .once,
      id: "deadbeef",
      name: "50% off once",
      rate: .percentOff(50),
      valid: true
    )
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    Current.stripe.fetchCoupon = { _ in fiftyPercentOffForever }

    await assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_5DollarsOff_Once() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .once,
      id: "deadbeef",
      name: "$5 off once",
      rate: .amountOff(5_00),
      valid: true
    )
    Current.database.fetchSubscriptionById = { _ in throw unit }
    Current.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    Current.stripe.fetchCoupon = { _ in fiftyPercentOffForever }

    await assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_UsingRegionalCouponId() async throws {
    await assertSnapshot(
      matching: siteMiddleware(
        connection(
          from: request(to: .discounts(code: Current.envVars.regionalDiscountCouponId, nil))
        )
      ),
      as: .ioConn
    )
  }
}
