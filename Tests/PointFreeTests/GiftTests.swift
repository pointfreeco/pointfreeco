import CustomDump
import Database
import Dependencies
import Either
import HttpPipeline
import InlineSnapshotTesting
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import Stripe
import TaggedMoney
import XCTest

@testable import Models
@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class GiftTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  @MainActor
  func testGiftCreate() async throws {
    let expectation = self.expectation(description: "createGift")
    await withDependencies {
      $0.database.createGift = {
        XCTAssertEqual($0, nil)
        XCTAssertEqual($1, "blob@pointfree.co")
        XCTAssertEqual($2, "Blob")
        XCTAssertEqual($3, "HBD!")
        XCTAssertEqual($4, 3)
        XCTAssertEqual($5, "pi_test")
        XCTAssertEqual($6, "blob.jr@pointfree.co")
        XCTAssertEqual($7, "Blob Jr.")
        expectation.fulfill()
        return .unfulfilled
      }
    } operation: {
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

      await assertRequest(conn) {
        """
        POST http://localhost:8080/gifts
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={}

        fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=3&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.
        """
      } response: {
        """
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
      }
    }

    { self.wait(for: [expectation], timeout: 0) }()
  }

  @MainActor
  func testGiftCreate_StripeFailure() async throws {
    await withDependencies {
      $0.stripe.createPaymentIntent = { _, _, _, _, _, _ in
        struct Error: Swift.Error {}
        throw Error()
      }
    } operation: {
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
      await assertRequest(conn) {
        """
        POST http://localhost:8080/gifts
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={}

        fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=3&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.
        """
      } response: {
        """
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
      }
    }
  }

  @MainActor
  func testGiftCreate_InvalidMonths() async throws {
    await withDependencies {
      $0.stripe.createPaymentIntent = { _, _, _, _, _, _ in
        struct Error: Swift.Error {}
        throw Error()
      }
    } operation: {
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
      await assertRequest(conn) {
        """
        POST http://localhost:8080/gifts
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={}

        fromEmail=blob%40pointfree.co&fromName=Blob&message=HBD%21&monthsFree=1&toEmail=blob.jr%40pointfree.co&toName=Blob%20Jr.
        """
      } response: {
        """
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
      }
    }
  }

  @MainActor
  func testGiftRedeem_NonSubscriber() async throws {
    let user = User.nonSubscriber
    var credit: Cents<Int>?
    var stripeSubscriptionId: Stripe.Subscription.ID?
    var userId: User.ID?

    await withDependencies {
      $0.database.createSubscription = { _, id, _, _ in
        userId = id
        return .mock
      }
      $0.database.fetchGift = { _ in .unfulfilled }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.database.fetchUserById = { _ in user }
      $0.database.sawUser = { _ in }
      $0.database.updateGift = { _, id in
        stripeSubscriptionId = id
        return .fulfilled
      }
      $0.date.now = .mock
      $0.stripe.createCustomer = { _, _, _, _, amount in
        credit = amount
        return update(.mock) {
          $0.invoiceSettings = .init(defaultPaymentMethod: nil)
        }
      }
      $0.stripe.createSubscription = { _, _, _, _ in .individualMonthly }
      $0.stripe.fetchPaymentIntent = { _ in .succeeded }
    } operation: {
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
      await assertRequest(conn) {
        """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
        """
      } response: {
        """
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
      }

      XCTAssertEqual(credit, -54_00)
      XCTAssertNotNil(stripeSubscriptionId)
      XCTAssertNotNil(userId)
    }
  }

  @MainActor
  func testGiftRedeem_Subscriber() async throws {
    let user = User.owner
    var credit: Cents<Int>?
    var stripeSubscriptionId: Stripe.Subscription.ID?

    await withDependencies {
      $0.database.fetchGift = { _ in .unfulfilled }
      $0.database.fetchEnterpriseAccountForSubscription = { _ in throw unit }
      $0.database.fetchSubscriptionById = { _ in .mock }
      $0.database.fetchSubscriptionByOwnerId = { _ in .mock }
      $0.database.fetchUserById = { _ in user }
      $0.database.sawUser = { _ in }
      $0.database.updateGift = { _, id in
        stripeSubscriptionId = id
        return .fulfilled
      }
      $0.date.now = .mock
      $0.stripe.fetchPaymentIntent = { _ in .succeeded }
      $0.stripe.fetchSubscription = { _ in .individualMonthly }
      $0.stripe.updateCustomerBalance = { _, amount in
        credit = amount
        return update(.mock)
      }
    } operation: {
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
      await assertRequest(conn) {
        """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
        """
      } response: {
        """
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
      }

      XCTAssertEqual(credit, -54_00)
      XCTAssertNotNil(stripeSubscriptionId)
    }
  }

  @MainActor
  func testGiftRedeem_Invalid_LoggedOut() async throws {
    await withDependencies {
      $0.stripe.fetchCoupon = { _ in update(.mock) { $0.rate = .amountOff(54_00) } }
    } operation: {
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
      await assertRequest(conn) {
        """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={}
        """
      } response: {
        """
        302 Found
        Location: /login?redirect=http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Referrer-Policy: strict-origin-when-cross-origin
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  @MainActor
  func testGiftRedeem_Invalid_Redeemed() async throws {
    let user = User.nonSubscriber

    await withDependencies {
      $0.database.fetchGift = { _ in .fulfilled }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.database.fetchUserById = { _ in user }
      $0.database.sawUser = { _ in }
      $0.date.now = .mock
      $0.stripe.fetchPaymentIntent = { _ in .succeeded }
    } operation: {
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
      await assertRequest(conn) {
        """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
        """
      } response: {
        """
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
      }
    }
  }

  @MainActor
  func testGiftRedeem_Invalid_Teammate() async throws {
    let user = User.teammate

    await withDependencies {
      $0.database.fetchGift = { _ in .unfulfilled }
      $0.database.fetchEnterpriseAccountForSubscription = { _ in throw unit }
      $0.database.fetchSubscriptionById = { _ in .mock }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.database.fetchUserById = { _ in user }
      $0.database.sawUser = { _ in }
      $0.date.now = .mock
      $0.stripe.fetchPaymentIntent = { _ in .succeeded }
      $0.stripe.fetchSubscription = { _ in .teamYearly }
    } operation: {
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
      await assertRequest(conn) {
        """
        POST http://localhost:8080/gifts/61F761F7-61F7-61F7-61F7-61F761F761F7
        Authorization: Basic aGVsbG86d29ybGQ=
        Cookie: pf_session={"userId":"11111111-1111-1111-1111-111111111111"}
        """
      } response: {
        """
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
      }
    }
  }

  @MainActor
  func testGiftLanding() async throws {
    await withDependencies {
      $0.date.now = .mock
      $0.episodes = { [] }
    } operation: {
      let conn = connection(from: request(to: .gifts()))

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(conn),
            as: [
              "desktop": .connWebView(size: .init(width: 1100, height: 2300)),
              "mobile": .connWebView(size: .init(width: 500, height: 2300)),
            ]
          )
        }
      #endif

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testGiftRedeemLanding() async throws {
    await withDependencies {
      $0.date.now = .mock
      $0.episodes = { [] }
      $0.database.fetchGift = { _ in .unfulfilled }
      $0.stripe.fetchPaymentIntent = { _ in .succeeded }
    } operation: {
      let conn = connection(from: request(to: .gifts(.redeem(.init(rawValue: .mock)))))

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(conn),
            as: [
              "desktop": .connWebView(size: .init(width: 1100, height: 2300)),
              "mobile": .connWebView(size: .init(width: 500, height: 2300)),
            ]
          )
        }
      #endif

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }
}
