import Dependencies
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
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  @MainActor
  func testDiscounts_LoggedOut() async throws {
    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: request(to: .discounts(code: "blobfest", nil)))
      ),
      as: .conn
    )

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: await siteMiddleware(
            connection(from: request(to: .discounts(code: "blobfest", nil)))
          ),
          as: [
            "desktop": .connWebView(size: .init(width: 1100, height: 2000)),
            "mobile": .connWebView(size: .init(width: 500, height: 2000)),
          ]
        )
      }
    #endif
  }

  @MainActor
  func testDiscounts_LoggedIn_PercentOff_Forever() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "50% off forever",
      rate: .percentOff(50),
      valid: true
    )

    await withDependencies {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.fetchCoupon = { _ in fiftyPercentOffForever }
    } operation: {
      await assertSnapshot(
        matching: await siteMiddleware(
          connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        ),
        as: .conn
      )

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(
              connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
            ),
            as: [
              "desktop": .connWebView(size: .init(width: 1100, height: 2000)),
              "mobile": .connWebView(size: .init(width: 500, height: 2000)),
            ]
          )
        }
      #endif
    }
  }

  @MainActor
  func testDiscounts_LoggedIn_5DollarsOff_Forever() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "$5 off forever",
      rate: .amountOff(5_00),
      valid: true
    )

    await withDependencies {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.fetchCoupon = { _ in fiftyPercentOffForever }
    } operation: {
      await assertSnapshot(
        matching: await siteMiddleware(
          connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        ),
        as: .conn
      )
    }
  }

  @MainActor
  func testDiscounts_LoggedIn_PercentOff_Repeating() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .repeating(months: 12),
      id: "deadbeef",
      name: "50% off 12 months",
      rate: .percentOff(50),
      valid: true
    )

    await withDependencies {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.fetchCoupon = { _ in fiftyPercentOffForever }
    } operation: {
      await assertSnapshot(
        matching: await siteMiddleware(
          connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        ),
        as: .conn
      )
    }
  }

  @MainActor
  func testDiscounts_LoggedIn_5DollarsOff_Repeating() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .repeating(months: 12),
      id: "deadbeef",
      name: "$5 off for 12 months",
      rate: .amountOff(5_00),
      valid: true
    )

    await withDependencies {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.fetchCoupon = { _ in fiftyPercentOffForever }
    } operation: {
      await assertSnapshot(
        matching: await siteMiddleware(
          connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        ),
        as: .conn
      )
    }
  }

  @MainActor
  func testDiscounts_LoggedIn_PercentOff_Once() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .once,
      id: "deadbeef",
      name: "50% off once",
      rate: .percentOff(50),
      valid: true
    )

    await withDependencies {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.fetchCoupon = { _ in fiftyPercentOffForever }
    } operation: {
      await assertSnapshot(
        matching: await siteMiddleware(
          connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        ),
        as: .conn
      )
    }
  }

  @MainActor
  func testDiscounts_LoggedIn_5DollarsOff_Once() async throws {
    let fiftyPercentOffForever = Coupon(
      duration: .once,
      id: "deadbeef",
      name: "$5 off once",
      rate: .amountOff(5_00),
      valid: true
    )

    await withDependencies {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.fetchCoupon = { _ in fiftyPercentOffForever }
    } operation: {
      await assertSnapshot(
        matching: await siteMiddleware(
          connection(from: request(to: .discounts(code: "blobfest", nil), session: .loggedIn))
        ),
        as: .conn
      )
    }
  }

  @MainActor
  func testDiscounts_UsingRegionalCouponId() async throws {
    @Dependency(\.envVars.regionalDiscountCouponId) var regionalDiscountCouponId: Coupon.ID

    await assertSnapshot(
      matching: await siteMiddleware(
        connection(
          from: request(to: .discounts(code: regionalDiscountCouponId, nil))
        )
      ),
      as: .conn
    )
  }
}
