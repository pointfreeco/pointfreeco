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

final class SubscribeIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testCoupon_Individual() {
    var subscribeData = SubscribeData.individualMonthly
    subscribeData.coupon = "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn =
      connection(
        from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
      assertSnapshot(matching: subscription, as: .customDump)
    #endif
  }

  func testCoupon_Team() {
    var subscribeData = SubscribeData.teamYearly(quantity: 4)
    subscribeData.coupon = "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn =
      connection(
        from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!
    XCTAssertNil(subscription)
  }

  func testHappyPath() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var balance: Cents<Int>?
    Current.stripe.createCustomer = {
      balance = $4
      return pure(update(.mock) { $0.id = "cus_referred" })
    }
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]
    Current.stripe.updateCustomerBalance = {
      balanceUpdates[$0] = $1
      return pure(.mock)
    }

    let conn =
      connection(
        from: request(to: .subscribe(.some(.individualMonthly)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
      assertSnapshot(matching: subscription, as: .customDump)
    #endif
    XCTAssertNil(balance)
    XCTAssertEqual(balanceUpdates, [:])
  }

  func testHappyPath_Yearly() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var balance: Cents<Int>?
    Current.stripe.createCustomer = {
      balance = $4
      return pure(update(.mock) { $0.id = "cus_referred" })
    }
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]
    Current.stripe.updateCustomerBalance = {
      balanceUpdates[$0] = $1
      return pure(.mock)
    }

    let conn =
      connection(
        from: request(to: .subscribe(.some(.individualYearly)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
      assertSnapshot(matching: subscription, as: .customDump)
    #endif
    XCTAssertNil(balance)
    XCTAssertEqual(balanceUpdates, [:])
  }

  func testHappyPath_Team() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
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
    let conn =
      connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
      assertSnapshot(matching: subscription, as: .customDump)
    #endif

    let invites = Current.database.fetchTeamInvites(user.id)
      .run
      .perform()
      .right!
    XCTAssertEqual(emails, invites.sorted { $0.email < $1.email }.map(\.email))
  }

  func testHappyPath_Team_OwnerIsNotTakingSeat() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
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
    let conn =
      connection(from: req)
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
      assertSnapshot(matching: subscription, as: .customDump)
    #endif

    let invites = Current.database.fetchTeamInvites(user.id)
      .run
      .perform()
      .right!
    XCTAssertEqual(emails, invites.sorted { $0.email < $1.email }.map(\.email))

    let freshUser = Current.database.fetchUserById(user.id)
      .run
      .perform()
      .right!!
    // Confirm that owner of subscription is not taking up a seat on the sub.
    XCTAssertEqual(nil, freshUser.subscriptionId)
  }

  func testHappyPath_Referral_Monthly() {
    let referrer = Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 1 }, "referrer@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    /*let referrerSubscription*/_ = Current.database.createSubscription(
      .mock, referrer.id, true, nil
    )
    .run
    .perform()
    .right!!

    let referred = Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 2 }, "referred@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

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

    Current.stripe.fetchSubscription = { _ in
      pure(
        update(.mock) {
          $0.customer = $0.customer.bimap(
            { _ in "cus_referrer" },
            {
              update($0) {
                $0.id = "cus_referrer"
                $0.balance = -18_00
              }
            })
        })
    }
    Current.stripe.createSubscription = { _, _, _, _ in
      pure(
        update(.mock) {
          $0.id = "sub_referred"
          $0.customer = $0.customer.bimap(
            { _ in "cus_referred" }, { update($0) { $0.id = "cus_referred" } })
        })
    }

    var balance: Cents<Int>?
    Current.stripe.createCustomer = {
      balance = $4
      return pure(update(.mock) { $0.id = "cus_referred" })
    }
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]
    Current.stripe.updateCustomerBalance = {
      balanceUpdates[$0] = $1
      return pure(.mock)
    }

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform
    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let referredSubscription = Current.database.fetchSubscriptionByOwnerId(referred.id)
      .run
      .perform()
      .right!!

    XCTAssertNil(balance)
    XCTAssertEqual(balanceUpdates, ["cus_referrer": -36_00, "cus_referred": -18_00])
    XCTAssertEqual("sub_referred", referredSubscription.stripeSubscriptionId)
  }

  func testHappyPath_Referral_Yearly() {
    let referrer = Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 1 }, "referrer@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    /*let referrerSubscription*/_ = Current
      .database.createSubscription(.mock, referrer.id, true, nil)
      .run
      .perform()
      .right!!

    let referred = Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 2 }, "referred@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

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

    Current.stripe.fetchSubscription = { _ in
      pure(
        update(.mock) {
          $0.customer = $0.customer.bimap(
            { _ in "cus_referrer" }, { update($0) { $0.id = "cus_referrer" } })
        })
    }
    Current.stripe.createSubscription = { _, _, _, _ in
      pure(
        update(.mock) {
          $0.id = "sub_referred"
          $0.customer = $0.customer.bimap(
            { _ in "cus_referred" }, { update($0) { $0.id = "cus_referred" } })
        })
    }

    var balance: Cents<Int>?
    Current.stripe.createCustomer = {
      balance = $4
      return pure(update(.mock) { $0.id = "cus_referred" })
    }
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]
    Current.stripe.updateCustomerBalance = {
      balanceUpdates[$0] = $1
      return pure(.mock)
    }

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform
    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let referredSubscription = Current.database.fetchSubscriptionByOwnerId(referred.id)
      .run
      .perform()
      .right!!

    XCTAssertEqual(balance, -18_00)
    XCTAssertEqual(balanceUpdates, ["cus_referrer": -18_00])
    XCTAssertEqual("sub_referred", referredSubscription.stripeSubscriptionId)
  }

  func testHappyPath_RegionalDiscount() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var customer = Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: "pm_card")

    var subscriptionCoupon: Coupon.ID?
    Current.stripe.createSubscription = { _, _, _, coupon in
      subscriptionCoupon = coupon
      return pure(.mock)
    }
    var balance: Cents<Int>?
    Current.stripe.createCustomer = { _, _, _, _, newBalance in
      balance = newBalance
      return pure(customer)
    }
    Current.stripe.fetchPaymentMethod = { _ in
      return pure(
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
      )
    }
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]
    Current.stripe.updateCustomerBalance = {
      balanceUpdates[$0] = $1
      return pure(customer)
    }

    var subscribeData = SubscribeData.individualMonthly
    subscribeData.useRegionalDiscount = true

    let conn =
      connection(
        from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let subscription = Current.database.fetchSubscriptionByOwnerId(user.id)
      .run
      .perform()
      .right!!

    #if !os(Linux)
      assertSnapshot(matching: subscription, as: .customDump)
    #endif
    XCTAssertEqual(subscriptionCoupon, Current.envVars.regionalDiscountCouponId)
    XCTAssertNil(balance)
    XCTAssertEqual(balanceUpdates, [:])
  }

  func testUnhappyPath_RegionalDiscount() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var customer = Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: "pm_card")

    var subscriptionCoupon: Coupon.ID?
    Current.stripe.createSubscription = { _, _, _, coupon in
      subscriptionCoupon = coupon
      return pure(.mock)
    }
    var balance: Cents<Int>?
    Current.stripe.createCustomer = { _, _, _, _, newBalance in
      balance = newBalance
      return pure(customer)
    }
    Current.stripe.fetchPaymentMethod = { _ in
      return pure(
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
      )
    }
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]
    Current.stripe.updateCustomerBalance = {
      balanceUpdates[$0] = $1
      return pure(customer)
    }

    var subscribeData = SubscribeData.individualMonthly
    subscribeData.useRegionalDiscount = true

    let conn =
      connection(
        from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    XCTAssertEqual(subscriptionCoupon, nil)
    XCTAssertNil(balance)
    XCTAssertEqual(balanceUpdates, [:])
  }

  func testRegionalDiscountWithReferral_Monthly() {
    let referrer = Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 1 }, "referrer@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    /*let referrerSubscription*/_ = Current.database.createSubscription(
      .mock, referrer.id, true, nil
    )
    .run
    .perform()
    .right!!

    let referred = Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 2 }, "referred@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

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

    Current.stripe.fetchPaymentMethod = { _ in
      return pure(
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
      )
    }
    Current.stripe.fetchSubscription = { _ in
      pure(
        update(.mock) {
          $0.customer = $0.customer.bimap(
            { _ in "cus_referrer" },
            {
              update($0) {
                $0.id = "cus_referrer"
                $0.balance = -18_00
              }
            })
        })
    }

    var subscriptionCoupon: Coupon.ID?
    Current.stripe.createSubscription = { _, _, _, coupon in
      subscriptionCoupon = coupon
      return pure(
        update(.mock) {
          $0.id = "sub_referred"
          $0.customer = $0.customer.bimap(
            { _ in "cus_referred" }, { update($0) { $0.id = "cus_referred" } })
        })
    }

    var balance: Cents<Int>?
    Current.stripe.createCustomer = { _, _, _, _, newBalance in
      balance = newBalance
      return pure(customer)
    }
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]
    Current.stripe.updateCustomerBalance = {
      balanceUpdates[$0] = $1
      return pure(customer)
    }

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform
    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let referredSubscription = Current.database.fetchSubscriptionByOwnerId(referred.id)
      .run
      .perform()
      .right!!

    XCTAssertNil(balance)
    XCTAssertEqual(balanceUpdates, ["cus_referrer": -36_00, "cus_referred": -9_00])
    XCTAssertEqual("sub_referred", referredSubscription.stripeSubscriptionId)
    XCTAssertEqual(subscriptionCoupon, Current.envVars.regionalDiscountCouponId)
  }

  func testRegionalDiscountWithReferral_Yearly() {
    let referrer = Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 1 }, "referrer@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    /*let referrerSubscription*/_ = Current.database.createSubscription(
      .mock, referrer.id, true, nil
    )
    .run
    .perform()
    .right!!

    let referred = Current.database
      .upsertUser(update(.mock) { $0.gitHubUser.id = 2 }, "referred@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

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

    Current.stripe.fetchPaymentMethod = { _ in
      return pure(
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
      )
    }
    Current.stripe.fetchSubscription = { _ in
      pure(
        update(.mock) {
          $0.customer = $0.customer.bimap(
            { _ in "cus_referrer" },
            {
              update($0) {
                $0.id = "cus_referrer"
                $0.balance = -18_00
              }
            })
        })
    }

    var subscriptionCoupon: Coupon.ID?
    Current.stripe.createSubscription = { _, _, _, coupon in
      subscriptionCoupon = coupon
      return pure(
        update(.mock) {
          $0.id = "sub_referred"
          $0.customer = $0.customer.bimap(
            { _ in "cus_referred" }, { update($0) { $0.id = "cus_referred" } })
        })
    }

    var balance: Cents<Int>?
    Current.stripe.createCustomer = { _, _, _, _, newBalance in
      balance = newBalance
      return pure(customer)
    }
    var balanceUpdates: [Customer.ID: Cents<Int>] = [:]
    Current.stripe.updateCustomerBalance = {
      balanceUpdates[$0] = $1
      return pure(customer)
    }

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform
    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif

    let referredSubscription = Current.database.fetchSubscriptionByOwnerId(referred.id)
      .run
      .perform()
      .right!!

    XCTAssertEqual(balance, -9_00)
    XCTAssertEqual(balanceUpdates, ["cus_referrer": -36_00])
    XCTAssertEqual("sub_referred", referredSubscription.stripeSubscriptionId)
    XCTAssertEqual(subscriptionCoupon, Current.envVars.regionalDiscountCouponId)
  }

  func testSubscribingWithRegionalDiscountAndCoupon() {
    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var customer = Customer.mock
    customer.invoiceSettings = .init(defaultPaymentMethod: "pm_card")
    Current.stripe.createCustomer = { _, _, _, _, _ in pure(customer) }
    Current.stripe.fetchPaymentMethod = {
      pure(
        PaymentMethod(
          card: .regional,
          customer: .left(customer.id),
          id: $0
        )
      )
    }

    var subscribeData = SubscribeData.individualMonthly
    subscribeData.coupon = "deadbeef"
    subscribeData.useRegionalDiscount = true

    let conn =
      connection(
        from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }
}

final class SubscribeTests: TestCase {
  override func setUp() {
    super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testNotLoggedIn_IndividualMonthly() {
    let conn =
      connection(from: request(to: .subscribe(.some(.individualMonthly))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCouponFailure_Individual() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createSubscription = { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }

    var subscribeData = SubscribeData.individualMonthly
    subscribeData.coupon = "deadbeef"

    let user = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    var session = Session.loggedIn
    session.user = .standard(user.id)

    let conn =
      connection(
        from: request(to: .subscribe(.some(subscribeData)), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testNotLoggedIn_IndividualYearly() {
    let conn =
      connection(from: request(to: .subscribe(.some(.individualYearly))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testNotLoggedIn_Team() {
    let conn =
      connection(from: request(to: .subscribe(.some(.teamYearly(quantity: 5)))))
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCurrentSubscribers() {
    let conn =
      connection(
        from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testInvalidQuantity() {
    #if !os(Linux)
      Current.database.fetchSubscriptionById = const(pure(nil))
      Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

      let conn =
        connection(
          from: request(to: .subscribe(.some(.teamYearly(quantity: 200))), session: .loggedIn)
        )
        |> siteMiddleware
        |> Prelude.perform

      assertSnapshot(matching: conn, as: .conn, named: "too_high")

      let conn2 =
        connection(
          from: request(to: .subscribe(.some(.teamYearly(quantity: 0))), session: .loggedIn)
        )
        |> siteMiddleware
        |> Prelude.perform

      assertSnapshot(matching: conn2, as: .conn, named: "too_low")
    #endif
  }

  func testCreateCustomerFailure() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createCustomer = { _, _, _, _, _ in throwE(unit as Error) }

    let conn =
      connection(
        from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCreateStripeSubscriptionFailure() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createSubscription = { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }

    let conn =
      connection(
        from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCreateStripeSubscriptionFailure_TeamAndMonthly() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createSubscription = { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .init(billing: .monthly, quantity: 3),
      referralCode: nil,
      teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.co"],
      useRegionalDiscount: false
    )

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCreateStripeSubscriptionFailure_TeamAndMonthly_TooManyEmails() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.createSubscription = { _, _, _, _ in throwE(StripeErrorEnvelope.mock as Error) }

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .init(billing: .monthly, quantity: 3),
      referralCode: nil,
      teammates: ["blob.jr@pointfree.co", "blob.sr@pointfree.co", "fake@pointfree.co"],
      useRegionalDiscount: false
    )

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testCreateDatabaseSubscriptionFailure() {
    Current.database.createSubscription = { _, _, _, _ in throwE(unit as Error) }
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn =
      connection(
        from: request(to: .subscribe(.some(.individualMonthly)), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testReferrals_InvalidCode() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.database.fetchUserByReferralCode = const(pure(nil))

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .individualMonthly,
      referralCode: "cafed00d",
      teammates: [],
      useRegionalDiscount: false
    )

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testReferrals_InvalidLane() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .teamYearly,
      referralCode: "cafed00d",
      teammates: [],
      useRegionalDiscount: false
    )

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testReferrals_InactiveCode() {
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))
    Current.stripe.fetchSubscription = { _ in pure(update(.mock) { $0.status = .canceled }) }

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .individualMonthly,
      referralCode: "cafed00d",
      teammates: [],
      useRegionalDiscount: false
    )

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: .loggedIn)
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }

  func testReferrals_PreviouslyReferred() {
    let user = update(User.nonSubscriber) {
      $0.referrerId = .init(rawValue: .mock)
    }

    Current.database.fetchUserById = const(pure(user))
    Current.database.fetchSubscriptionById = const(pure(nil))
    Current.database.fetchSubscriptionByOwnerId = const(pure(.mock))

    let subscribeData = SubscribeData(
      coupon: nil,
      isOwnerTakingSeat: true,
      paymentMethodID: "pm_deadbeef",
      pricing: .individualMonthly,
      referralCode: "cafed00d",
      teammates: [],
      useRegionalDiscount: false
    )

    let conn =
      connection(
        from: request(to: .subscribe(subscribeData), session: .loggedIn(as: user))
      )
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
      assertSnapshot(matching: conn, as: .conn)
    #endif
  }
}
