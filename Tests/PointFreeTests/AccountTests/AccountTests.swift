import Database
import DatabaseTestSupport
import Either
import GitHub
import HttpPipeline
import Models
import ModelsTestSupport
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import StripeTestSupport
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

final class AccountIntegrationTests: LiveDatabaseTestCase {
  func testLeaveTeam() {
    let currentUser = Current.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-currentUser"),
        gitHubUser: .init(
          createdAt: .init(timeIntervalSince1970: 1_234_543_210), id: 1, name: "Blob")
      ),
      email: "blob@pointfree.co",
      now: { .mock }
    )
    .run.perform().right!!

    _ = Current.database.createEnterpriseEmail("blob@corporate.com", currentUser.id)
      .run.perform().right!!

    let owner = Current.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-owner"),
        gitHubUser: .init(
          createdAt: .init(timeIntervalSince1970: 1_234_543_210), id: 2, name: "Owner")
      ),
      email: "owner@pointfree.co",
      now: { .mock }
    )
    .run.perform().right!!

    let subscription = Current.database.createSubscription(
      Stripe.Subscription.mock,
      owner.id,
      false,
      nil
    )
    .run.perform().right!!

    _ = Current.database.addUserIdToSubscriptionId(currentUser.id, subscription.id)
      .run.perform().right!

    let conn = connection(from: request(to: .team(.leave), session: .loggedIn(as: currentUser)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertEqual(
      Current.database.fetchUserById(currentUser.id)
        .run.perform().right!!.subscriptionId,
      nil
    )

    XCTAssertEqual(
      Current.database.fetchEnterpriseEmails()
        .run.perform().right!,
      []
    )
  }
}

final class AccountTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  func testAccount() {
    Current = .teamYearly

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2400)),
          ]
        )
      }
    #endif
  }

  func testAccount_InvoiceBilling() {
    var customer = Stripe.Customer.mock
    customer.sources = .mock([.right(.mock)])
    var subscription = Stripe.Subscription.teamYearly
    subscription.customer = .right(customer)
    Current = .teamYearly
    Current.stripe.fetchSubscription = const(pure(subscription))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2400)),
          ]
        )
      }
    #endif
  }

  func testTeam_OwnerIsNotSubscriber() {
    var currentUser = User.nonSubscriber
    currentUser.episodeCreditCount = 2
    var subscription = Models.Subscription.mock
    subscription.userId = currentUser.id

    Current = .teamYearly
    Current.database.fetchUserById = const(pure(.some(currentUser)))
    Current.database.fetchSubscriptionTeammatesByOwnerId = const(pure([]))
    Current.database.fetchSubscriptionById = const(pure(.some(subscription)))

    var session = Session.loggedIn
    session.user = .standard(currentUser.id)
    let conn = connection(from: request(to: .account(), session: session))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1800)),
          ]
        )
      }
    #endif
  }

  func testTeam_NoRemainingSeats() {
    let currentUser = User.nonSubscriber
    var subscription = Models.Subscription.mock
    subscription.userId = currentUser.id
    var stripeSubscription = Stripe.Subscription.mock
    stripeSubscription.quantity = 2

    Current = .teamYearly
    Current.database.fetchUserById = const(pure(.some(currentUser)))
    Current.database.fetchSubscriptionTeammatesByOwnerId = const(pure([.mock, .mock]))
    Current.database.fetchSubscriptionById = const(pure(.some(subscription)))
    Current.database.fetchTeamInvites = const(pure([]))
    Current.stripe.fetchSubscription = const(pure(stripeSubscription))

    var session = Session.loggedIn
    session.user = .standard(currentUser.id)
    let conn = connection(from: request(to: .account(), session: session))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1600)),
          ]
        )
      }
    #endif
  }

  func testTeam_AsTeammate() {
    Current = .teamYearlyTeammate

    let conn = connection(from: request(to: .account(), session: .loggedIn(as: .teammate)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1500)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1300)),
          ]
        )
      }
    #endif
  }

  func testTeam_AsTeammate_previousSubscription() {
    Current = .teamYearlyTeammate
    Current.database.fetchSubscriptionByOwnerId = const(
      pure(update(.canceled) { $0.userId = User.teammate.id })
    )

    let conn = connection(from: request(to: .account(), session: .loggedIn(as: .teammate)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1500)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1300)),
          ]
        )
      }
    #endif
  }

  func testAccount_WithExtraInvoiceInfo() {
    var customer = Stripe.Customer.mock
    customer.metadata = ["extraInvoiceInfo": "VAT: 1234567890"]
    var subscription = Stripe.Subscription.mock
    subscription.customer = .right(customer)

    Current = .teamYearly
    Current.stripe.fetchSubscription = const(pure(subscription))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1000)),
          ]
        )
      }
    #endif
  }

  func testAccountWithFlashNotice() {
    var session = Session.loggedIn
    session.flash = Flash(.notice, "You’ve subscribed!")

    let conn = connection(
      from: request(to: .account(), session: session))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 80)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 80)),
          ]
        )
      }
    #endif
  }

  func testAccountWithFlashWarning() {
    var session = Session.loggedIn
    session.flash = Flash(.warning, "Your subscription is past-due!")

    let conn = connection(from: request(to: .account(), session: session))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 80)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 80)),
          ]
        )
      }
    #endif
  }

  func testAccountWithFlashError() {
    var session = Session.loggedIn
    session.flash = Flash(.error, "An error has occurred!")

    let conn = connection(from: request(to: .account(), session: session))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 80)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 80)),
          ]
        )
      }
    #endif
  }

  func testAccountWithPastDue() {
    var subscription = Models.Subscription.mock
    subscription.stripeSubscriptionStatus = .pastDue

    var stripeSubscription = Stripe.Subscription.mock
    stripeSubscription.cancelAtPeriodEnd = false
    stripeSubscription.status = .pastDue

    Current.database.fetchSubscriptionById = const(pure(subscription))
    Current.database.fetchSubscriptionByOwnerId = const(pure(subscription))
    Current.stripe.fetchSubscription = const(pure(stripeSubscription))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1800)),
          ]
        )
      }
    #endif
  }

  func testAccountCancelingSubscription() {
    Current.stripe.fetchSubscription = const(pure(.canceling))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2200)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testAccountCanceledSubscription() {
    Current.database.fetchSubscriptionById = const(pure(.canceled))
    Current.stripe.fetchSubscription = const(pure(.canceled))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1200)),
          ]
        )
      }
    #endif
  }

  func testEpisodeCredits_1Credit_NoneChosen() {
    var user = User.mock
    user.subscriptionId = nil
    user.episodeCreditCount = 1

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.database.fetchEpisodeCredits = const(pure([]))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1200)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1000)),
          ]
        )
      }
    #endif
  }

  func testEpisodeCredits_1Credit_1Chosen() {
    var user = User.mock
    user.subscriptionId = nil
    user.episodeCreditCount = 1

    Current.database.fetchUserById = const(pure(.some(user)))
    Current.database.fetchEpisodeCredits = const(pure([.mock]))
    Current.database.fetchSubscriptionByOwnerId = const(pure(nil))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 1200)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 1000)),
          ]
        )
      }
    #endif
  }

  func testAccountWithDiscount() {
    var subscription = Stripe.Subscription.mock
    subscription.discount = .mock
    Current = .teamYearly
    Current.stripe.fetchSubscription = const(pure(subscription))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2400)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testAccountWithCredit() {
    var subscription = Stripe.Subscription.mock
    subscription.customer = .right(update(.mock) { $0.balance = -18_00 })
    Current = .individualMonthly
    Current.stripe.fetchSubscription = const(pure(subscription))

    let conn = connection(from: request(to: .account(), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 2800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 2400)),
          ]
        )
      }
    #endif
  }
}
