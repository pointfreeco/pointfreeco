import ApplicativeRouter
import CustomDump
import Database
import Either
import HttpPipeline
@testable import Models
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import TaggedMoney
#if !os(Linux)
import WebKit
#endif
import XCTest

class GiftTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.isRecording=true
  }

  func testGiftCreate() {
    var createGiftRequest: Database.Client.CreateGiftRequest!
    Current.database.createGift = { request in
      createGiftRequest = request
      return pure(.mock)
    }

    let conn = connection(
      from: request(
        to: .gifts(
          .create(
            .init(
              deliverAt: nil,
              fromEmail: "blob@pointfree.co",
              fromName: "Blob",
              message: "HBD!",
              monthsFree: 3,
              toEmail: "blob.jr@pointfree.co",
              toName: "Blob Jr."
            )
          )
        ),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    POST http://localhost:8080/gifts
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={}
    
    {
      "from_email" : "blob@pointfree.co",
      "from_name" : "Blob",
      "message" : "HBD!",
      "months_free" : "3",
      "to_email" : "blob.jr@pointfree.co",
      "to_name" : "Blob Jr."
    }
    
    200 OK
    Content-Length: 44
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    
    {
      "clientSecret" : "pi_test_secret_test"
    }
    """)

    XCTAssertNoDifference(
      createGiftRequest,
        .init(
          deliverAt: nil,
          fromEmail: "blob@pointfree.co",
          fromName: "Blob",
          message: "HBD!",
          monthsFree: 3,
          stripeCouponId: nil,
          stripePaymentIntentId: "pi_test",
          toEmail: "blob.jr@pointfree.co",
          toName: "Blob Jr."
        )
    )
  }

  func testGiftCreate_StripeFailure() {
    Current.stripe.createPaymentIntent = { _ in
      struct Error: Swift.Error {}
      return throwE(Error())
    }

    let conn = connection(
      from: request(
        to: .gifts(
          .create(
            .init(
              deliverAt: nil,
              fromEmail: "blob@pointfree.co",
              fromName: "Blob",
              message: "HBD!",
              monthsFree: 3,
              toEmail: "blob.jr@pointfree.co",
              toName: "Blob Jr."
            )
          )
        ),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    POST http://localhost:8080/gifts
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={}
    
    {
      "from_email" : "blob@pointfree.co",
      "from_name" : "Blob",
      "message" : "HBD!",
      "months_free" : "3",
      "to_email" : "blob.jr@pointfree.co",
      "to_name" : "Blob Jr."
    }
    
    400 Bad Request
    Content-Length: 65
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    
    {
      "errorMessage" : "Unknown error with our payment processor"
    }
    """)
  }

  func testGiftCreate_InvalidMonths() {
    Current.stripe.createPaymentIntent = { _ in
      struct Error: Swift.Error {}
      return throwE(Error())
    }

    let conn = connection(
      from: request(
        to: .gifts(
          .create(
            .init(
              deliverAt: nil,
              fromEmail: "blob@pointfree.co",
              fromName: "Blob",
              message: "HBD!",
              monthsFree: 1,
              toEmail: "blob.jr@pointfree.co",
              toName: "Blob Jr."
            )
          )
        ),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    POST http://localhost:8080/gifts
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={}
    
    {
      "from_email" : "blob@pointfree.co",
      "from_name" : "Blob",
      "message" : "HBD!",
      "months_free" : "1",
      "to_email" : "blob.jr@pointfree.co",
      "to_name" : "Blob Jr."
    }
    
    400 Bad Request
    Content-Length: 45
    Content-Type: application/json
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    
    {
      "errorMessage" : "Unknown gift option."
    }
    """)
  }

  func testGiftRedeem_NonSubscriber() {
    Current = .failing

    let user = User.nonSubscriber

    Current.database.fetchGiftByStripeCouponId = { _ in pure(.mock) }
    Current.database.fetchSubscriptionByOwnerId = { _ in pure(nil) }
    Current.database.fetchUserById = { _ in pure(user) }
    Current.database.sawUser = { _ in pure(unit) }
    Current.date = { .mock }
    var credit: Cents<Int>?
    Current.stripe.createCustomer = { _, _, _, _, amount in
      credit = amount
      return pure(update(.mock) {
        $0.defaultSource = nil
        $0.sources = .mock([])
      })
    }
    Current.stripe.createSubscription = { _, _, _, _ in
      pure(.individualMonthly)
    }
    Current.stripe.deleteCoupon = { _ in pure(unit) }
    Current.stripe.fetchCoupon = { _ in pure(update(.mock) { $0.rate = .amountOff(54_00) }) }

    let conn = connection(
      from: request(
        to: .gifts(.redeem("deadbeef")),
        session: .loggedIn(as: user),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    GET http://localhost:8080/gifts/deadbeef
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
    
    302 Found
    Location: /account
    Referrer-Policy: strict-origin-when-cross-origin
    Set-Cookie: pf_session={"flash":{"message":"You now have access to Point-Free!","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    """)

    XCTAssertEqual(credit, 54_00)
  }

  func testGiftRedeem_Subscriber() {
    Current = .failing

    let user = User.owner

    Current.database.fetchGiftByStripeCouponId = { _ in pure(.mock) }
    Current.database.fetchEnterpriseAccountForSubscription = { _ in pure(nil) }
    Current.database.fetchSubscriptionById = { _ in pure(.mock) }
    Current.database.fetchSubscriptionByOwnerId = { _ in pure(.mock) }
    Current.database.fetchUserById = { _ in pure(user) }
    Current.database.sawUser = { _ in pure(unit) }
    Current.date = { .mock }
    Current.stripe.fetchCoupon = { _ in pure(update(.mock) { $0.rate = .amountOff(54_00) }) }
    Current.stripe.fetchSubscription = { _ in pure(.individualMonthly) }
    var credit: Cents<Int>?
    Current.stripe.updateCustomerBalance = { _, amount in
      credit = amount
      return pure(update(.mock))
    }

    let conn = connection(
      from: request(
        to: .gifts(.redeem("deadbeef")),
        session: .loggedIn(as: user),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    POST http://localhost:8080/gifts/deadbeef
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
    
    302 Found
    Location: /account
    Referrer-Policy: strict-origin-when-cross-origin
    Set-Cookie: pf_session={"flash":{"message":"The gift has been applied to your account as credit.","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    """)

    XCTAssertEqual(credit, 54_00)
  }

  func testGiftRedeem_Invalid_LoggedOut() {
    Current.stripe.fetchCoupon = { _ in pure(update(.mock) { $0.rate = .amountOff(54_00) }) }

    let conn = connection(
      from: request(to: .gifts(.redeem("deadbeef")), session: .loggedOut, basicAuth: true)
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    GET http://localhost:8080/gifts/deadbeef
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={}

    302 Found
    Location: /login?redirect=http://localhost:8080/gifts/deadbeef
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    """)
  }

  func testGiftRedeem_Invalid_Redeemed() {
    Current = .failing

    let user = User.nonSubscriber

    Current.database.fetchGiftByStripeCouponId = { _ in pure(.mock) }
    Current.database.fetchSubscriptionByOwnerId = { _ in pure(nil) }
    Current.database.fetchUserById = { _ in pure(user) }
    Current.database.sawUser = { _ in pure(unit) }
    Current.date = { .mock }
    Current.stripe.fetchCoupon = { _ in
      pure(update(.mock) {
        $0.rate = .amountOff(54_00)
        $0.valid = false
      })
    }

    let conn = connection(
      from: request(
        to: .gifts(.redeem("deadbeef")),
        session: .loggedIn(as: user),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    POST http://localhost:8080/gifts/deadbeef
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
    
    302 Found
    Location: /gifts
    Referrer-Policy: strict-origin-when-cross-origin
    Set-Cookie: pf_session={"flash":{"message":"This gift was already redeemed.","priority":"error"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    """)
  }

  func testGiftRedeem_Invalid_Teammate() {
    Current = .failing

    let user = User.teammate

    Current.database.fetchGiftByStripeCouponId = { _ in pure(.mock) }
    Current.database.fetchEnterpriseAccountForSubscription = { _ in pure(nil) }
    Current.database.fetchSubscriptionById = { _ in pure(.mock) }
    Current.database.fetchSubscriptionByOwnerId = { _ in pure(nil) }
    Current.database.fetchUserById = { _ in pure(user) }
    Current.database.sawUser = { _ in pure(unit) }
    Current.date = { .mock }
    Current.stripe.fetchCoupon = { _ in pure(update(.mock) { $0.rate = .amountOff(54_00) }) }
    Current.stripe.fetchSubscription = { _ in pure(.teamYearly) }

    let conn = connection(
      from: request(
        to: .gifts(.redeem("deadbeef")),
        session: .loggedIn(as: user),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(matching: result, as: .ioConn, with: """
    GET http://localhost:8080/gifts/deadbeef
    Authorization: Basic aGVsbG86d29ybGQ=
    Cookie: pf_session={"userId":"11111111-1111-1111-1111-111111111111"}
    
    302 Found
    Location: /gifts/coupon-deadbeef
    Referrer-Policy: strict-origin-when-cross-origin
    Set-Cookie: pf_session={"flash":{"message":"You are already part of an active team subscription.","priority":"error"},"userId":"11111111-1111-1111-1111-111111111111"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    """)
  }
}
