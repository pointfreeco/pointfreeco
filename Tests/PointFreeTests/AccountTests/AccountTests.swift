import Either
import Html
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

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
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

  func testAccount_WithRssFeatureFlag() {
    Current = .teamYearly
      |> \.features .~ [.podcastRss |> \.isEnabled .~ true]

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 2500)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 2500))
        ]
      )
    }
    #endif
  }

  func testTeam_OwnerIsNotSubscriber() {
    let currentUser = Database.User.nonSubscriber
    let subscription = Database.Subscription.mock
      |> (\Database.Subscription.userId) .~ currentUser.id

    Current = .teamYearly
      |> (\Environment.database.fetchUserById) .~ const(pure(.some(currentUser)))
      |> (\Environment.database.fetchSubscriptionTeammatesByOwnerId) .~ const(pure([]))
      |> (\Environment.database.fetchSubscriptionById) .~ const(pure(.some(subscription)))

    let session = Session.loggedIn
      |> (\Session.userId) .~ currentUser.id
    let conn = connection(from: request(to: .account(.index), session: session))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> \.flash .~ flash))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> \.flash .~ flash))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

    let conn = connection(from: request(to: .account(.index), session: .loggedIn |> \.flash .~ flash))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    update(&Current, \.stripe.fetchSubscription .~ const(pure(.canceled)))

    let conn = connection(from: request(to: .account(.index), session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    let user = Database.User.mock
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
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    let user = Database.User.mock
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
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
