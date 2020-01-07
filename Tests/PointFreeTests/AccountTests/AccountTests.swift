import Database
import DatabaseTestSupport
import Either
import HttpPipeline
import Models
import ModelsTestSupport
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import StripeTestSupport
#if !os(Linux)
import WebKit
#endif
import XCTest

final class AccountTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testAccount() {
    Current = .teamYearly

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testAccount_InvoiceBilling() {
    let customer = Stripe.Customer.mock
      |> (\Stripe.Customer.sources) .~ .mock([.right(.mock)])
    let subscription = Stripe.Subscription.teamYearly
      |> (\Stripe.Subscription.customer) .~ .right(customer)
    Current = .teamYearly
      |> (\Environment.stripe.fetchSubscription) .~ const(pure(subscription))

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2400)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2400))
        ]
      )
    }
    #endif
  }

  func testTeam_OwnerIsNotSubscriber() {
    let currentUser = User.nonSubscriber
      |> \.episodeCreditCount .~ 2
    let subscription = Subscription.mock
      |> \.userId .~ currentUser.id

    Current = .teamYearly
      |> (\Environment.database.fetchUserById) .~ const(pure(.some(currentUser)))
      |> (\Environment.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([]))
      |> (\Environment.database.fetchSubscriptionById) .~ const(pure(.some(subscription)))

    let session = Session.loggedIn
      |> \.user .~ .standard(currentUser.id)
    let conn = connection(from: request(to: .account(.index), session: session))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testTeam_NoRemainingSeats() {
    let currentUser = User.nonSubscriber
    let subscription = Subscription.mock
      |> \.userId .~ currentUser.id
    let stripeSubscription = Stripe.Subscription.mock
      |> (\Stripe.Subscription.quantity) .~ 2

    Current = .teamYearly
      |> (\Environment.database.fetchUserById) .~ const(pure(.some(currentUser)))
      |> (\Environment.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([.mock, .mock]))
      |> (\Environment.database.fetchSubscriptionById) .~ const(pure(.some(subscription)))
      |> (\Environment.database.fetchTeamInvites) .~ const(pure([]))
      |> (\Environment.stripe.fetchSubscription) .~ const(pure(stripeSubscription))

    let session = Session.loggedIn
      |> \.user .~ .standard(currentUser.id)
    let conn = connection(from: request(to: .account(.index), session: session))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testTeam_AsTeammate() {
    Current = .teamYearlyTeammate

    let conn = connection(from: request(to: .account(.index), session: .loggedIn(as: .teammate)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testAccount_WithExtraInvoiceInfo() {
    Current = .teamYearly
      |> \.stripe.fetchSubscription .~ const(
        pure(
          .mock
            |> \.customer .~ .right(
              .mock
                |> \.metadata .~ ["extraInvoiceInfo": "VAT: 1234567890"]
          )
        )
    )

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testAccountWithFlashNotice() {
    let flash = Flash(priority: .notice, message: "You’ve subscribed!")

    let conn = connection(
      from: request(to: .account(.index), session: .loggedIn |> (\Session.flash) .~ flash))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testAccountWithFlashWarning() {
    let flash = Flash(priority: .warning, message: "Your subscription is past-due!")

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> (\Session.flash) .~ flash))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testAccountWithFlashError() {
    let flash = Flash(priority: .error, message: "An error has occurred!")

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> (\Session.flash) .~ flash))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testAccountWithPastDue() {
    update(
      &Current,
      \.database.fetchSubscriptionById .~ const(pure(.mock |> \.stripeSubscriptionStatus .~ .pastDue)),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(.mock |> \.stripeSubscriptionStatus .~ .pastDue))
    )

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testAccountCancelingSubscription() {
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceling)))

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testAccountCanceledSubscription() {
    update(
      &Current,
      \.stripe.fetchSubscription .~ const(pure(.canceled)),
      \.database.fetchSubscriptionById .~ const(pure(.canceled))
    )

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }

  func testEpisodeCredits_1Credit_NoneChosen() {
    let user = User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    update(
      &Current,
      (\Environment.database.fetchUserById) .~ const(pure(.some(user))),
      \.database.fetchEpisodeCredits .~ const(pure([])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )
    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1500)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1500))
        ]
      )
    }
    #endif
  }

  func testEpisodeCredits_1Credit_1Chosen() {
    let user = User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    update(
      &Current,
      (\Environment.database.fetchUserById) .~ const(pure(.some(user))),
      \.database.fetchEpisodeCredits .~ const(pure([.mock])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 1500)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 1500))
        ]
      )
    }
    #endif
  }

  func testAccountWithDiscount() {
    let subscription = Stripe.Subscription.mock
      |> \.discount .~ .mock
    Current = .teamYearly
      |> \.stripe.fetchSubscription .~ const(pure(subscription))

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2000))
        ]
      )
    }
    #endif
  }
}
