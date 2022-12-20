import CustomDump
import Database
import Either
import HttpPipeline
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import TaggedMoney
import XCTest

@testable import Models
@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class GiftTests: TestCase {
  override func setUp() {
    super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testGiftCreate() {
    var createGiftRequest: Database.Client.CreateGiftRequest!
    Current.database.createGift = { request in
      createGiftRequest = request
      return .unfulfilled
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

    _assertInlineSnapshot(
      matching: result, as: .ioConn,
      with: """
        POST http://localhost:8080/gifts
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={}

        fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=3&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.

        302 Found
        Location: /gifts
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Your gift has been delivered to blob.jr@pointfree.co.","priority":"notice"}}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
    )

    XCTAssertNoDifference(
      createGiftRequest,
      .init(
        deliverAt: nil,
        fromEmail: "blob@pointfree.co",
        fromName: "Blob",
        message: "HBD!",
        monthsFree: 3,
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

    _assertInlineSnapshot(
      matching: result, as: .ioConn,
      with: """
        POST http://localhost:8080/gifts
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={}

        fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=3&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.

        302 Found
        Location: /gifts
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Unknown error with our payment processor","priority":"notice"}}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
    )
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

    _assertInlineSnapshot(
      matching: result, as: .ioConn,
      with: """
        POST http://localhost:8080/gifts
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={}

        fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=1&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.

        302 Found
        Location: /gifts
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Unknown gift option.","priority":"notice"}}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
    )
  }

  func testGiftRedeem_NonSubscriber() {
    Current = .failing

    let user = User.nonSubscriber

    var credit: Cents<Int>?
    var stripeSubscriptionId: Stripe.Subscription.ID?
    var userId: User.ID?

    Current.database.createSubscription = { _, id, _, _ in
      userId = id
      return .mock
    }
    Current.database.fetchGift = { _ in pure(.unfulfilled) }
    Current.database.fetchSubscriptionByOwnerId = { _ in pure(nil) }
    Current.database.fetchUserById = { _ in pure(user) }
    Current.database.sawUser = { _ in pure(unit) }
    Current.database.updateGift = { _, id in
      stripeSubscriptionId = id
      return pure(.fulfilled)
    }
    Current.date = { .mock }
    Current.stripe.createCustomer = { _, _, _, _, amount in
      credit = amount
      return pure(
        update(.mock) {
          $0.invoiceSettings = .init(defaultPaymentMethod: nil)
        })
    }
    Current.stripe.createSubscription = { _, _, _, _ in
      pure(.individualMonthly)
    }
    Current.stripe.fetchPaymentIntent = { _ in pure(.succeeded) }

    let conn = connection(
      from: request(
        to: .gifts(
          .redeem(
            .init(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!,
            .confirm
          )
        ),
        session: .loggedIn(as: user),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(
      matching: result, as: .ioConn,
      with: """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
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
        """
    )

    XCTAssertEqual(credit, -54_00)
    XCTAssertNotNil(stripeSubscriptionId)
    XCTAssertNotNil(userId)
  }

  func testGiftRedeem_Subscriber() {
    Current = .failing

    let user = User.owner

    var credit: Cents<Int>?
    var stripeSubscriptionId: Stripe.Subscription.ID?

    Current.database.fetchGift = { _ in pure(.unfulfilled) }
    Current.database.fetchEnterpriseAccountForSubscription = { _ in pure(nil) }
    Current.database.fetchSubscriptionById = { _ in pure(.mock) }
    Current.database.fetchSubscriptionByOwnerId = { _ in pure(.mock) }
    Current.database.fetchUserById = { _ in pure(user) }
    Current.database.sawUser = { _ in pure(unit) }
    Current.database.updateGift = { _, id in
      stripeSubscriptionId = id
      return pure(.fulfilled)
    }
    Current.date = { .mock }
    Current.stripe.fetchPaymentIntent = { _ in pure(.succeeded) }
    Current.stripe.fetchSubscription = { _ in pure(.individualMonthly) }
    Current.stripe.updateCustomerBalance = { _, amount in
      credit = amount
      return pure(update(.mock))
    }

    let conn = connection(
      from: request(
        to: .gifts(
          .redeem(
            .init(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!, .confirm
          )
        ),
        session: .loggedIn(as: user),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(
      matching: result, as: .ioConn,
      with: """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
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
        """
    )

    XCTAssertEqual(credit, -54_00)
    XCTAssertNotNil(stripeSubscriptionId)
  }

  func testGiftRedeem_Invalid_LoggedOut() {
    Current.stripe.fetchCoupon = { _ in pure(update(.mock) { $0.rate = .amountOff(54_00) }) }

    let conn = connection(
      from: request(
        to: .gifts(
          .redeem(
            .init(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!, .confirm
          )
        ),
        session: .loggedOut,
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(
      matching: result, as: .ioConn,
      with: """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={}

        302 Found
        Location: /login?redirect=http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Referrer-Policy: strict-origin-when-cross-origin
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
    )
  }

  func testGiftRedeem_Invalid_Redeemed() {
    Current = .failing

    let user = User.nonSubscriber

    Current.database.fetchGift = { _ in pure(.fulfilled) }
    Current.database.fetchSubscriptionByOwnerId = { _ in pure(nil) }
    Current.database.fetchUserById = { _ in pure(user) }
    Current.database.sawUser = { _ in pure(unit) }
    Current.date = { .mock }
    Current.stripe.fetchPaymentIntent = { _ in pure(.succeeded) }

    let conn = connection(
      from: request(
        to: .gifts(
          .redeem(
            .init(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!, .confirm
          )
        ),
        session: .loggedIn(as: user),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(
      matching: result, as: .ioConn,
      with: """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
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
        """
    )
  }

  func testGiftRedeem_Invalid_Teammate() {
    Current = .failing

    let user = User.teammate

    Current.database.fetchGift = { _ in pure(.unfulfilled) }
    Current.database.fetchEnterpriseAccountForSubscription = { _ in pure(nil) }
    Current.database.fetchSubscriptionById = { _ in pure(.mock) }
    Current.database.fetchSubscriptionByOwnerId = { _ in pure(nil) }
    Current.database.fetchUserById = { _ in pure(user) }
    Current.database.sawUser = { _ in pure(unit) }
    Current.date = { .mock }
    Current.stripe.fetchPaymentIntent = { _ in pure(.succeeded) }
    Current.stripe.fetchSubscription = { _ in pure(.teamYearly) }

    let conn = connection(
      from: request(
        to: .gifts(
          .redeem(
            .init(uuidString: "61f761f7-61f7-61f7-61f7-61f761f761f7")!, .confirm
          )
        ),
        session: .loggedIn(as: user),
        basicAuth: true
      )
    )
    let result = conn |> siteMiddleware

    _assertInlineSnapshot(
      matching: result, as: .ioConn,
      with: """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={"userId":"11111111-1111-1111-1111-111111111111"}

        302 Found
        Location: /gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"You are already part of an active team subscription.","priority":"error"},"userId":"11111111-1111-1111-1111-111111111111"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
    )
  }

  func testGiftLanding() {
    Current = .failing
    Current.date = { .mock }
    Current.episodes = { [] }

    let conn = connection(from: request(to: .gifts()))

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: siteMiddleware(conn),
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2300)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2300)),
          ]
        )
      }
    #endif

    assertSnapshot(matching: siteMiddleware(conn), as: .ioConn)
  }

  func testGiftRedeemLanding() {
    Current = .failing
    Current.date = { .mock }
    Current.episodes = { [] }
    Current.database.fetchGift = { _ in pure(.unfulfilled) }
    Current.stripe.fetchPaymentIntent = { _ in pure(.succeeded) }

    let conn = connection(from: request(to: .gifts(.redeem(.init(rawValue: .mock)))))

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: siteMiddleware(conn),
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2300)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2300)),
          ]
        )
      }
    #endif

    assertSnapshot(matching: siteMiddleware(conn), as: .ioConn)
  }
}
