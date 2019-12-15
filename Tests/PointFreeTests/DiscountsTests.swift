import Either
import Html
import HttpPipeline
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import Stripe
import XCTest

private func secureRequest(_ urlString: String) -> URLRequest {
  return URLRequest(url: URL(string: urlString)!)
    |> \.allHTTPHeaderFields .~ ["X-Forwarded-Proto": "https"]
}

class DiscountsTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record=true
  }

  func testDiscounts_LoggedOut() {
    assertSnapshot(
      matching: connection(from: request(with: secureRequest("http://localhost:8080/discounts/blobfest")))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_PercentOff_Forever() {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "50% off forever",
      rate: .percentOff(50),
      valid: true
    )
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.fetchCoupon .~ const(pure(fiftyPercentOffForever))
    )

    assertSnapshot(
      matching: connection(
        from: request(
        from: request(with: secureRequest("http://localhost:8080/discounts/blobfest"), session: .loggedIn)
          with: secureRequest("http://localhost:8080/discounts/blobfest")
        )
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_5DollarsOff_Forever() {
    let fiftyPercentOffForever = Coupon(
      duration: .forever,
      id: "deadbeef",
      name: "$5 off forever",
      rate: .amountOff(5_00),
      valid: true
    )
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.fetchCoupon .~ const(pure(fiftyPercentOffForever))
    )

    assertSnapshot(
      matching: connection(
        from: request(with: secureRequest("http://localhost:8080/discounts/blobfest"), session: .loggedIn)
        )
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_PercentOff_Repeating() {
    let fiftyPercentOffForever = Coupon(
    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
      duration: .repeating(months: 12),
        matching: connection(
          from: request(
      id: "deadbeef",
            with: secureRequest("http://localhost:8080/discounts/blobfest")
          )
          )
          |> siteMiddleware,
      name: "50% off 12 months",
        as: [
      rate: .percentOff(50),
      valid: true
    )
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.fetchCoupon .~ const(pure(fiftyPercentOffForever))
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2000))
    )

    assertSnapshot(
      matching: connection(
        from: request(with: secureRequest("http://localhost:8080/discounts/blobfest"), session: .loggedIn)
        )
        |> siteMiddleware,
      as: .ioConn
        ]
      )
    }
    )
    #endif
  }

  func testDiscounts_LoggedIn_5DollarsOff_Repeating() {
  func testDiscounts_LoggedIn() {
    let fiftyPercentOffForever = Coupon(
      duration: .repeating(months: 12),
      id: "deadbeef",
      name: "$5 off for 12 months",
      rate: .amountOff(5_00),
      valid: true
    )
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
      \.stripe.fetchCoupon .~ const(pure(fiftyPercentOffForever))
    )

    assertSnapshot(
      matching: connection(
        from: request(
        from: request(with: secureRequest("http://localhost:8080/discounts/blobfest"), session: .loggedIn)
          with: secureRequest("http://localhost:8080/discounts/blobfest"),
          session: .loggedIn
        )
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
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      \.stripe.fetchCoupon .~ const(pure(fiftyPercentOffForever))
    )

    assertSnapshot(
      matching: connection(
        from: request(with: secureRequest("http://localhost:8080/discounts/blobfest"), session: .loggedIn)
        )
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testDiscounts_LoggedIn_5DollarsOff_Once() {
    let fiftyPercentOffForever = Coupon(
    #if !os(Linux)
      duration: .once,
      id: "deadbeef",
      name: "$5 off once",
      rate: .amountOff(5_00),
      valid: true
    )
    if self.isScreenshotTestingAvailable {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(nil)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil)),
      assertSnapshots(
      \.stripe.fetchCoupon .~ const(pure(fiftyPercentOffForever))
    )

    assertSnapshot(
      matching: connection(
        from: request(with: secureRequest("http://localhost:8080/discounts/blobfest"), session: .loggedIn)
        matching: connection(
          from: request(
            with: secureRequest("http://localhost:8080/discounts/blobfest"),
            session: .loggedIn
          )
        )
        |> siteMiddleware,
      as: .ioConn
          )
          |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2000))
        ]
      )
    }
    )
    #endif
  }
}
