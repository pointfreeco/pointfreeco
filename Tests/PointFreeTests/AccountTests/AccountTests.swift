import Database
import DatabaseTestSupport
import Dependencies
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

@MainActor
final class AccountIntegrationTests: LiveDatabaseTestCase {
  func testLeaveTeam() async throws {
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-currentUser"),
        gitHubUser: .init(
          createdAt: .init(timeIntervalSince1970: 1_234_543_210), id: 1, name: "Blob")
      ),
      email: "blob@pointfree.co",
      now: { .mock }
    )
    .performAsync()!

    _ = try await Current.database.createEnterpriseEmail("blob@corporate.com", currentUser.id)
      .performAsync()!

    let owner = try await Current.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-owner"),
        gitHubUser: .init(
          createdAt: .init(timeIntervalSince1970: 1_234_543_210), id: 2, name: "Owner")
      ),
      email: "owner@pointfree.co",
      now: { .mock }
    )
    .performAsync()!

    let subscription = try await Current.database.createSubscription(
      Stripe.Subscription.mock,
      owner.id,
      false,
      nil
    )
    .performAsync()!

    _ = try await Current.database.addUserIdToSubscriptionId(currentUser.id, subscription.id)
      .performAsync()

    let conn = connection(from: request(to: .team(.leave), session: .loggedIn(as: currentUser)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    let subscriptionId = try await Current.database.fetchUserById(currentUser.id)
      .performAsync()!.subscriptionId
    XCTAssertEqual(subscriptionId, nil)

    let emails = try await Current.database.fetchEnterpriseEmails().performAsync()
    XCTAssertEqual(emails, [])
  }
}

final class AccountTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  func testAccount() {
    DependencyValues.withValues {
      $0.teamYearly()
    } operation: {
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

  func testAccount_InvoiceBilling() {
    var customer = Stripe.Customer.mock
    customer.invoiceSettings.defaultPaymentMethod = nil
    var subscription = Stripe.Subscription.teamYearly
    subscription.customer = .right(customer)

    DependencyValues.withValues {
      $0.teamYearly()
      $0.stripe.fetchSubscription = const(pure(subscription))
    } operation: {
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

  func testTeam_OwnerIsNotSubscriber() {
    var currentUser = User.nonSubscriber
    currentUser.episodeCreditCount = 2
    var subscription = Models.Subscription.mock
    subscription.userId = currentUser.id

    DependencyValues.withValues {
      $0.teamYearly()
      $0.database.fetchUserById = const(pure(.some(currentUser)))
      $0.database.fetchSubscriptionTeammatesByOwnerId = const(pure([]))
      $0.database.fetchSubscriptionById = const(pure(.some(subscription)))
    } operation: {
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
  }

  func testTeam_NoRemainingSeats() {
    let currentUser = User.nonSubscriber
    var subscription = Models.Subscription.mock
    subscription.userId = currentUser.id
    var stripeSubscription = Stripe.Subscription.mock
    stripeSubscription.quantity = 2

    DependencyValues.withValues {
      $0.teamYearly()
      $0.database.fetchUserById = const(pure(.some(currentUser)))
      $0.database.fetchSubscriptionTeammatesByOwnerId = const(pure([.mock, .mock]))
      $0.database.fetchSubscriptionById = const(pure(.some(subscription)))
      $0.database.fetchTeamInvites = const(pure([]))
      $0.stripe.fetchSubscription = const(pure(stripeSubscription))
    } operation: {
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
  }

  func testTeam_AsTeammate() {
    DependencyValues.withValues {
      $0.teamYearly()
    } operation: {
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
  }

  func testTeam_AsTeammate_previousSubscription() {
    DependencyValues.withValues {
      $0.teamYearly()
      $0.database.fetchSubscriptionByOwnerId = const(
        pure(update(.canceled) { $0.userId = User.teammate.id })
      )
    } operation: {
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
  }

  func testAccount_WithExtraInvoiceInfo() {
    var customer = Stripe.Customer.mock
    customer.metadata = ["extraInvoiceInfo": "VAT: 1234567890"]
    var subscription = Stripe.Subscription.mock
    subscription.customer = .right(customer)

    print(DependencyValues._current.context)
    print("-----")

    DependencyValues.withTestValues {
      $0.teamYearly()
      $0.stripe.fetchSubscription = const(pure(subscription))
    } operation: {
      let conn = connection(from: request(to: .account(), session: .loggedIn))

      print(DependencyValues._current.context)
      print("-----")

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

    DependencyValues.withValues {
      $0.database.fetchSubscriptionById = const(pure(subscription))
      $0.database.fetchSubscriptionByOwnerId = const(pure(subscription))
      $0.stripe.fetchSubscription = const(pure(stripeSubscription))
    } operation: {
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
  }

  func testAccountCancelingSubscription() {
    DependencyValues.withValues {
      $0.stripe.fetchSubscription = const(pure(.canceling))
    } operation: {
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
  }

  func testAccountCanceledSubscription() {
    DependencyValues.withValues {
      $0.database.fetchSubscriptionById = const(pure(.canceled))
      $0.stripe.fetchSubscription = const(pure(.canceled))
    } operation: {
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
  }

  func testEpisodeCredits_1Credit_NoneChosen() {
    var user = User.mock
    user.subscriptionId = nil
    user.episodeCreditCount = 1

    DependencyValues.withValues {
      $0.database.fetchUserById = const(pure(.some(user)))
      $0.database.fetchEpisodeCredits = const(pure([]))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
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
  }

  func testEpisodeCredits_1Credit_1Chosen() {
    var user = User.mock
    user.subscriptionId = nil
    user.episodeCreditCount = 1

    DependencyValues.withValues {
      $0.database.fetchUserById = const(pure(.some(user)))
      $0.database.fetchEpisodeCredits = const(pure([.mock]))
      $0.database.fetchSubscriptionByOwnerId = const(pure(nil))
    } operation: {
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
  }

  func testAccountWithDiscount() {
    var subscription = Stripe.Subscription.mock
    subscription.discount = .mock

    DependencyValues.withValues {
      $0.teamYearly()
      $0.stripe.fetchSubscription = const(pure(subscription))
    } operation: {
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
  }

  func testAccountWithCredit() {
    var subscription = Stripe.Subscription.mock
    subscription.customer = .right(update(.mock) { $0.balance = -18_00 })

    DependencyValues.withValues {
      $0 = .individualMonthly
      $0.stripe.fetchSubscription = const(pure(subscription))
    } operation: {
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
}
