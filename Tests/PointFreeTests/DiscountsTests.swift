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

class DiscountsTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording=true
  }

  func testDiscounts_LoggedOut() {
    assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil)))
        |> siteMiddleware,
      as: .ioConn
    )

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
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

  func testDiscounts_LoggedIn_PercentOff_Forever() {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "50% off forever",
      rate: .percentOff(50),
      valid: true
    )
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.fetchCoupon = const(pure(fiftyPercentOffForever))

    assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
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

  func testDiscounts_LoggedIn_5DollarsOff_Forever() {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "$5 off forever",
      rate: .amountOff(5_00),
      valid: true
    )
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.fetchCoupon = const(pure(fiftyPercentOffForever))

    assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_PercentOff_Repeating() {
    let fiftyPercentOffForever = Coupon(
      duration: .repeating(months: 12),
      id: "deadbeef",
      name: "50% off 12 months",
      rate: .percentOff(50),
      valid: true
    )
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.fetchCoupon = const(pure(fiftyPercentOffForever))

    assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_5DollarsOff_Repeating() {
    let fiftyPercentOffForever = Coupon(
      duration: .repeating(months: 12),
      id: "deadbeef",
      name: "$5 off for 12 months",
      rate: .amountOff(5_00),
      valid: true
    )
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.fetchCoupon = const(pure(fiftyPercentOffForever))

    assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_PercentOff_Once() {
    let fiftyPercentOffForever = Coupon(
      duration: .once,
      id: "deadbeef",
      name: "50% off once",
      rate: .percentOff(50),
      valid: true
    )
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.fetchCoupon = const(pure(fiftyPercentOffForever))

    assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_5DollarsOff_Once() {
    let fiftyPercentOffForever = Coupon(
      duration: .once,
      id: "deadbeef",
      name: "$5 off once",
      rate: .amountOff(5_00),
      valid: true
    )
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.fetchCoupon = const(pure(fiftyPercentOffForever))

    assertSnapshot(
      matching: connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_UsingRegionalCouponId() {
    assertSnapshot(
      matching: siteMiddleware(
        connection(
          from: request(to: .discounts(code: Current.envVars.regionalDiscountCouponId, nil))
        )
      ),
      as: .ioConn
    )
  }
}
