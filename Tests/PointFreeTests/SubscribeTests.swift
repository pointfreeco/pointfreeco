import Dependencies
import Either
import EmailAddress
import HttpPipeline
import Models
import ModelsTestSupport
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import TaggedMoney
import XCTest

@testable import GitHub
@testable import PointFree
@testable import Stripe

@MainActor
final class SubscribeIntegrationTests: LiveDatabaseTestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testCoupon_Individual() async throws {
    var subscribeData = SubscribeData.individualMonthly
    subscribeData.coupon = "deadbeef"

    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn = await siteMiddleware(
      connection(
        from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
    )
    .performAsync()

    #if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = try await Current.database.fetchSubscriptionByOwnerId(user.id)

    #if !os(Linux)
      await assertSnapshot(matching: subscription, as: .customDump)
    #endif
  }

  func testCoupon_Team() async throws {
    var subscribeData = SubscribeData.teamYearly(quantity: 4)
    subscribeData.coupon = "deadbeef"

    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn = await siteMiddleware(
      connection(
        from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
    )
    .performAsync()

    #if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = try? await Current.database.fetchSubscriptionByOwnerId(user.id)
    XCTAssertNil(subscription)
  }

  func testHappyPath() async throws {
    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var balance: Cents<Int>?
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]

    try await withDependencyValues {
      $0.stripe.createCustomer = {
        balance = $4
        return update(.mock) { $0.id = "cus_referred" }
      }
      $0.stripe.updateCustomerBalance = {
        balanceUpdates[$0] = $1
        return .mock
      }
    } operation: {
      let conn = await siteMiddleware(
        connection(
          from: request(to: .subscribe(.some(.individualMonthly)), session: session)
        )
      )
      .performAsync()

      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif

      let subscription = try await Current.database.fetchSubscriptionByOwnerId(user.id)

      #if !os(Linux)
        await assertSnapshot(matching: subscription, as: .customDump)
      #endif
      XCTAssertNil(balance)
      XCTAssertEqual(balanceUpdates, [:])
    }
  }

  func testHappyPath_Yearly() async throws {
    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var balance: Cents<Int>?
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]

    try await withDependencyValues {
      $0.stripe.createCustomer = {
        balance = $4
        return update(.mock) { $0.id = "cus_referred" }
      }
      $0.stripe.updateCustomerBalance = {
        balanceUpdates[$0] = $1
        return .mock
      }
    } operation: {
      let conn = await siteMiddleware(
        connection(
          from: request(to: .subscribe(.some(.individualYearly)), session: session)
        )
      )
      .performAsync()

      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif

      let subscription = try await Current.database.fetchSubscriptionByOwnerId(user.id)

      #if !os(Linux)
        await assertSnapshot(matching: subscription, as: .customDump)
      #endif
      XCTAssertNil(balance)
      XCTAssertEqual(balanceUpdates, [:])
    }
  }

  func testHappyPath_Team() async throws {
    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let emails: [EmailAddress] = [
      "blob1@pointfree.co",
      "blob2@pointfree.co",
      "blob3@pointfree.co",
      "blob4@pointfree.co",
    ]

    var subscribeData = SubscribeData.teamYearly(quantity: 5)
    subscribeData.teammates = emails

    let req = request(
      to: .subscribe(.some(subscribeData)),
      session: session
    )
    let conn = await siteMiddleware(connection(from: req)).performAsync()

    #if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
    #endif
    let subscription = try await Current.database.fetchSubscriptionByOwnerId(user.id)

    #if !os(Linux)
      await assertSnapshot(matching: subscription, as: .customDump)
    #endif

    let invites = try await Current.database.fetchTeamInvites(user.id)
    XCTAssertEqual(emails, invites.sorted { $0.email < $1.email }.map(\.email))
  }

  func testHappyPath_Team_OwnerIsNotTakingSeat() async throws {
    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let emails: [EmailAddress] = [
      "blob1@pointfree.co",
      "blob2@pointfree.co",
      "blob3@pointfree.co",
      "blob4@pointfree.co",
      "blob5@pointfree.co",
    ]

    var subscribeData = SubscribeData.teamYearly(quantity: 5)
    subscribeData.teammates = emails
    subscribeData.isOwnerTakingSeat = false

    let req = request(
      to: .subscribe(.some(subscribeData)),
      session: session
    )
    let conn = await siteMiddleware(connection(from: req)).performAsync()

    #if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
    #endif
    let subscription = try await Current.database.fetchSubscriptionByOwnerId(user.id)

    #if !os(Linux)
      await assertSnapshot(matching: subscription, as: .customDump)
    #endif

    let invites = try await Current.database.fetchTeamInvites(user.id)
    XCTAssertEqual(emails, invites.sorted { $0.email < $1.email }.map(\.email))

    let freshUser = try await Current.database.fetchUserById(user.id)
    // Confirm that owner of subscription is not taking up a seat on the sub.
    XCTAssertEqual(nil, freshUser.subscriptionId)
  }

  func testHappyPath_Referral_Monthly() async throws {
    let referrer = try await Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 1 }, "referrer@pointfree.co", { .mock })

    /*let referrerSubscription*/_ = try await Current.database.createSubscription(
      .mock, referrer.id, true, nil
    )

    let referred = try await Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 2 }, "referred@pointfree.co", { .mock })

    var session = Session.loggedIn
    session.user = .standard(referred.id)

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .individualMonthly,
      referralCode: referrer.referralCode,
      teammates: [],
      useRegionalDiscount: false
    )
    var balance: Cents<Int>?
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]

    try await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in
        update(.mock) {
          $0.customer = $0.customer.bimap(
            { _ in "cus_referrer" },
            {
              update($0) {
                $0.id = "cus_referrer"
                $0.balance = -18_00
              }
            })
        }
      }
      $0.stripe.createSubscription = { _, _, _, _ in
        update(.mock) {
          $0.id = "sub_referred"
          $0.customer = $0.customer.bimap(
            { _ in "cus_referred" }, { update($0) { $0.id = "cus_referred" } })
        }
      }
      $0.stripe.createCustomer = {
        balance = $4
        return update(.mock) { $0.id = "cus_referred" }
      }
      $0.stripe.updateCustomerBalance = {
        balanceUpdates[$0] = $1
        return .mock
      }
    } operation: {
      let conn = await siteMiddleware(
        connection(
          from: request(to: .subscribe(subscribeData), session: session)
        )
      )
      .performAsync()
      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif

      let referredSubscription = try await Current.database.fetchSubscriptionByOwnerId(referred.id)

      XCTAssertNil(balance)
      XCTAssertEqual(balanceUpdates, ["cus_referrer": -36_00, "cus_referred": -18_00])
      XCTAssertEqual("sub_referred", referredSubscription.stripeSubscriptionId)
    }
  }

  func testHappyPath_Referral_Yearly() async throws {
    let referrer = try await Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 1 }, "referrer@pointfree.co", { .mock })

    /*let referrerSubscription*/_ =
      try await Current
      .database.createSubscription(.mock, referrer.id, true, nil)

    let referred = try await Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 2 }, "referred@pointfree.co", { .mock })

    var session = Session.loggedIn
    session.user = .standard(referred.id)

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .individualYearly,
      referralCode: referrer.referralCode,
      teammates: [],
      useRegionalDiscount: false
    )
    var balance: Cents<Int>?
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]

    try await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in
        update(.mock) {
          $0.customer = $0.customer.bimap(
            { _ in "cus_referrer" }, { update($0) { $0.id = "cus_referrer" } })
        }
      }
      $0.stripe.createSubscription = { _, _, _, _ in
        update(.mock) {
          $0.id = "sub_referred"
          $0.customer = $0.customer.bimap(
            { _ in "cus_referred" }, { update($0) { $0.id = "cus_referred" } })
        }
      }
      $0.stripe.createCustomer = {
        balance = $4
        return update(.mock) { $0.id = "cus_referred" }
      }
      $0.stripe.updateCustomerBalance = {
        balanceUpdates[$0] = $1
        return .mock
      }
    } operation: {
      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: session))
      )
      .performAsync()
      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif

      let referredSubscription = try await Current.database.fetchSubscriptionByOwnerId(referred.id)

      XCTAssertEqual(balance, -18_00)
      XCTAssertEqual(balanceUpdates, ["cus_referrer": -18_00])
      XCTAssertEqual("sub_referred", referredSubscription.stripeSubscriptionId)
    }
  }

  func testHappyPath_RegionalDiscount() async throws {
    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var customer = Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: "pm_card")
    var subscriptionCoupon: Coupon.ID?
    var balance: Cents<Int>?
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]

    try await withDependencyValues {
      $0.stripe.createSubscription = { _, _, _, coupon in
        subscriptionCoupon = coupon
        return .mock
      }
      $0.stripe.createCustomer = { _, _, _, _, newBalance in
        balance = newBalance
        return customer
      }
      $0.stripe.fetchPaymentMethod = { _ in
        .init(
          card: .init(
            brand: .visa,
            country: "BO",
            expMonth: 12,
            expYear: 2025,
            funding: .credit,
            last4: "1111"
          ),
          customer: .left(customer.id),
          id: "pm_card"
        )
      }
      $0.stripe.updateCustomerBalance = {
        balanceUpdates[$0] = $1
        return customer
      }
    } operation: {
      var subscribeData = SubscribeData.individualMonthly
      subscribeData.useRegionalDiscount = true

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(.some(subscribeData)), session: session))
      )
      .performAsync()

      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif

      let subscription = try await Current.database.fetchSubscriptionByOwnerId(user.id)

      #if !os(Linux)
        await assertSnapshot(matching: subscription, as: .customDump)
      #endif
      XCTAssertEqual(subscriptionCoupon, Current.envVars.regionalDiscountCouponId)
      XCTAssertNil(balance)
      XCTAssertEqual(balanceUpdates, [:])
    }
  }

  func testUnhappyPath_RegionalDiscount() async throws {
    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var customer = Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: "pm_card")
    var subscriptionCoupon: Coupon.ID?
    var balance: Cents<Int>?
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]

    try await withDependencyValues {
      $0.stripe.createSubscription = { _, _, _, coupon in
        subscriptionCoupon = coupon
        return .mock
      }
      $0.stripe.createCustomer = { _, _, _, _, newBalance in
        balance = newBalance
        return customer
      }
      $0.stripe.fetchPaymentMethod = { _ in
        .init(
          card: .init(
            brand: .visa,
            country: "US",
            expMonth: 12,
            expYear: 2025,
            funding: .credit,
            last4: "1111"
          ),
          customer: .left(customer.id),
          id: "pm_card"
        )
      }
      $0.stripe.updateCustomerBalance = {
        balanceUpdates[$0] = $1
        return customer
      }
    } operation: {
      var subscribeData = SubscribeData.individualMonthly
      subscribeData.useRegionalDiscount = true

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(.some(subscribeData)), session: session))
      )
      .performAsync()

      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif

      XCTAssertEqual(subscriptionCoupon, nil)
      XCTAssertNil(balance)
      XCTAssertEqual(balanceUpdates, [:])
    }
  }

  func testRegionalDiscountWithReferral_Monthly() async throws {
    let referrer = try await Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 1 }, "referrer@pointfree.co", { .mock })

    /*let referrerSubscription*/_ = try await Current.database.createSubscription(
      .mock, referrer.id, true, nil
    )

    let referred = try await Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 2 }, "referred@pointfree.co", { .mock })

    var session = Session.loggedIn
    session.user = .standard(referred.id)

    var customer = Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: "pm_card")

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .individualMonthly,
      referralCode: referrer.referralCode,
      teammates: [],
      useRegionalDiscount: true
    )
    var subscriptionCoupon: Coupon.ID?
    var balance: Cents<Int>?
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]

    try await withDependencyValues {
      $0.stripe.fetchPaymentMethod = { _ in
        .init(
          card: .init(
            brand: .visa,
            country: "BO",
            expMonth: 12,
            expYear: 2025,
            funding: .credit,
            last4: "1111"
          ),
          customer: .left(customer.id),
          id: "pm_card"
        )
      }
      $0.stripe.fetchSubscription = { _ in
        update(.mock) {
          $0.customer = $0.customer.bimap(
            { _ in "cus_referrer" },
            {
              update($0) {
                $0.id = "cus_referrer"
                $0.balance = -18_00
              }
            })
        }
      }
      $0.stripe.createSubscription = { _, _, _, coupon in
        subscriptionCoupon = coupon
        return update(.mock) {
          $0.id = "sub_referred"
          $0.customer = $0.customer.bimap(
            { _ in "cus_referred" }, { update($0) { $0.id = "cus_referred" } })
        }
      }
      $0.stripe.createCustomer = { _, _, _, _, newBalance in
        balance = newBalance
        return customer
      }
      $0.stripe.updateCustomerBalance = {
        balanceUpdates[$0] = $1
        return customer
      }
    } operation: {
      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: session))
      )
      .performAsync()
      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif

      let referredSubscription = try await Current.database.fetchSubscriptionByOwnerId(referred.id)

      XCTAssertNil(balance)
      XCTAssertEqual(balanceUpdates, ["cus_referrer": -36_00, "cus_referred": -9_00])
      XCTAssertEqual("sub_referred", referredSubscription.stripeSubscriptionId)
      XCTAssertEqual(subscriptionCoupon, Current.envVars.regionalDiscountCouponId)
    }
  }

  func testRegionalDiscountWithReferral_Yearly() async throws {
    let referrer = try await Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 1 }, "referrer@pointfree.co", { .mock })

    /*let referrerSubscription*/_ = try await Current.database.createSubscription(
      .mock, referrer.id, true, nil
    )

    let referred = try await Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 2 }, "referred@pointfree.co", { .mock })

    var session = Session.loggedIn
    session.user = .standard(referred.id)

    var customer = Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: "pm_card")

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .individualYearly,
      referralCode: referrer.referralCode,
      teammates: [],
      useRegionalDiscount: true
    )
    var subscriptionCoupon: Coupon.ID?
    var balance: Cents<Int>?
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]

    try await withDependencyValues {
      $0.stripe.fetchPaymentMethod = { _ in
        .init(
          card: .init(
            brand: .visa,
            country: "BO",
            expMonth: 12,
            expYear: 2025,
            funding: .credit,
            last4: "1111"
          ),
          customer: .left(customer.id),
          id: "pm_card"
        )
      }
      $0.stripe.fetchSubscription = { _ in
        update(.mock) {
          $0.customer = $0.customer.bimap(
            { _ in "cus_referrer" },
            {
              update($0) {
                $0.id = "cus_referrer"
                $0.balance = -18_00
              }
            })
        }
      }
      $0.stripe.createSubscription = { _, _, _, coupon in
        subscriptionCoupon = coupon
        return update(.mock) {
          $0.id = "sub_referred"
          $0.customer = $0.customer.bimap(
            { _ in "cus_referred" }, { update($0) { $0.id = "cus_referred" } })
        }
      }
      $0.stripe.createCustomer = { _, _, _, _, newBalance in
        balance = newBalance
        return customer
      }
      $0.stripe.updateCustomerBalance = {
        balanceUpdates[$0] = $1
        return customer
      }
    } operation: {
      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: session))
      )
      .performAsync()
      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif

      let referredSubscription = try await Current.database.fetchSubscriptionByOwnerId(referred.id)

      XCTAssertEqual(balance, -9_00)
      XCTAssertEqual(balanceUpdates, ["cus_referrer": -36_00])
      XCTAssertEqual("sub_referred", referredSubscription.stripeSubscriptionId)
      XCTAssertEqual(subscriptionCoupon, Current.envVars.regionalDiscountCouponId)
    }
  }

  func testSubscribingWithRegionalDiscountAndCoupon() async throws {
    let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var customer = Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: "pm_card")

    await withDependencyValues {
      $0.stripe.createCustomer = { _, _, _, _, _ in customer }
      $0.stripe.fetchPaymentMethod = {
        PaymentMethod(
          card: .regional,
          customer: .left(customer.id),
          id: $0
        )
      }
    } operation: {
      var subscribeData = SubscribeData.individualMonthly
      subscribeData.coupon = "deadbeef"
      subscribeData.useRegionalDiscount = true

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(.some(subscribeData)), session: session))
      )
      .performAsync()

      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif
    }
  }
}

@MainActor
final class SubscribeTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testNotLoggedIn_IndividualMonthly() async throws {
    let conn = await siteMiddleware(
      connection(from: request(to: .subscribe(.some(.individualMonthly))))
    )
    .performAsync()

    #if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCouponFailure_Individual() async throws {
    try await withDependencyValues {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.createSubscription = { _, _, _, _ in throw StripeErrorEnvelope.mock }
    } operation: {
      var subscribeData = SubscribeData.individualMonthly
      subscribeData.coupon = "deadbeef"

      let user = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      var session = Session.loggedIn
      session.user = .standard(user.id)

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(.some(subscribeData)), session: session))
      )
      .performAsync()

      #if !os(Linux)
        await assertSnapshot(matching: conn, as: .conn)
      #endif
    }
  }

  func testNotLoggedIn_IndividualYearly() async throws {
    let conn = await siteMiddleware(
      connection(from: request(to: .subscribe(.some(.individualYearly))))
    )
    .performAsync()

    #if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testNotLoggedIn_Team() async throws {
    let conn = await siteMiddleware(
      connection(from: request(to: .subscribe(.some(.teamYearly(quantity: 5)))))
    )
    .performAsync()

    #if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCurrentSubscribers() async throws {
    let conn = await siteMiddleware(
      connection(from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn))
    )
    .performAsync()

    #if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testInvalidQuantity() async throws {
    #if !os(Linux)
      await withDependencyValues {
        $0.database.fetchSubscriptionById = { _ in throw unit }
        $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      } operation: {
        let conn = await siteMiddleware(
          connection(
            from: request(to: .subscribe(.some(.teamYearly(quantity: 200))), session: .loggedIn)
          )
        )
        .performAsync()

        await assertSnapshot(matching: conn, as: .conn, named: "too_high")

        let conn2 = await siteMiddleware(
          connection(
            from: request(to: .subscribe(.some(.teamYearly(quantity: 0))), session: .loggedIn)
          )
        )
        .performAsync()

        await assertSnapshot(matching: conn2, as: .conn, named: "too_low")
      }
    #endif
  }

  func testCreateCustomerFailure() async throws {
    await withDependencyValues {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.createCustomer = { _, _, _, _, _ in throw unit }
    } operation: {
      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn))
      )
        .performAsync()

#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }

  func testCreateStripeSubscriptionFailure() async throws {
    await withDependencyValues {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.createSubscription = { _, _, _, _ in throw StripeErrorEnvelope.mock }
    } operation: {
      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn))
      )
        .performAsync()

#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }

  func testCreateStripeSubscriptionFailure_TeamAndMonthly() async throws {
    await withDependencyValues {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.createSubscription = { _, _, _, _ in throw StripeErrorEnvelope.mock }
    } operation: {
      let subscribeData = SubscribeData(
        coupon: nil,
        isOwnerTakingSeat: true,
        paymentMethodID: "pm_deadbeef",
        pricing: .init(billing: .monthly, quantity: 3),
        referralCode: nil,
        teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.co"],
        useRegionalDiscount: false
      )

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: .loggedIn))
      )
        .performAsync()

#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }

  func testCreateStripeSubscriptionFailure_TeamAndMonthly_TooManyEmails() async throws {
    await withDependencyValues {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.createSubscription = { _, _, _, _ in throw StripeErrorEnvelope.mock }
    } operation: {
      let subscribeData = SubscribeData(
        coupon: nil,
        isOwnerTakingSeat: true,
        paymentMethodID: "pm_deadbeef",
        pricing: .init(billing: .monthly, quantity: 3),
        referralCode: nil,
        teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.co", "fake@pointfree.co"],
        useRegionalDiscount: false
      )

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: .loggedIn))
      )
        .performAsync()

#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }

  func testCreateDatabaseSubscriptionFailure() async throws {
    await withDependencyValues {
      $0.database.createSubscription = { _, _, _, _ in throw unit }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn))
      )
        .performAsync()

#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }

  func testReferrals_InvalidCode() async throws {
    await withDependencyValues {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.database.fetchUserByReferralCode = { _ in throw unit }
    } operation: {
      let subscribeData = SubscribeData(
        coupon: nil,
        isOwnerTakingSeat: true,
        paymentMethodID: "pm_deadbeef",
        pricing: .individualMonthly,
        referralCode: "cafed00d",
        teammates: [],
        useRegionalDiscount: false
      )

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: .loggedIn))
      )
        .performAsync()

#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }

  func testReferrals_InvalidLane() async throws {
    await withDependencyValues {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let subscribeData = SubscribeData(
        coupon: nil,
        isOwnerTakingSeat: true,
        paymentMethodID: "pm_deadbeef",
        pricing: .teamYearly,
        referralCode: "cafed00d",
        teammates: [],
        useRegionalDiscount: false
      )

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: .loggedIn))
      )
        .performAsync()

#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }

  func testReferrals_InactiveCode() async throws {
    await withDependencyValues {
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.stripe.fetchSubscription = { _ in update(.mock) { $0.status = .canceled } }
    } operation: {
      let subscribeData = SubscribeData(
        coupon: nil,
        isOwnerTakingSeat: true,
        paymentMethodID: "pm_deadbeef",
        pricing: .individualMonthly,
        referralCode: "cafed00d",
        teammates: [],
        useRegionalDiscount: false
      )

      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: .loggedIn))
      )
        .performAsync()

#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }

  func testReferrals_PreviouslyReferred() async throws {
    let user = update(User.nonSubscriber) {
      $0.referrerId = .init(rawValue: .mock)
    }

    await withDependencyValues {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let subscribeData = SubscribeData(
        coupon: nil,
        isOwnerTakingSeat: true,
        paymentMethodID: "pm_deadbeef",
        pricing: .individualMonthly,
        referralCode: "cafed00d",
        teammates: [],
        useRegionalDiscount: false
      )
      
      let conn = await siteMiddleware(
        connection(from: request(to: .subscribe(subscribeData), session: .loggedIn(as: user)))
      )
        .performAsync()
      
#if !os(Linux)
      await assertSnapshot(matching: conn, as: .conn)
#endif
    }
  }
}
