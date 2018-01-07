import Either
import Html
import HtmlPrettyPrint
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

final class ChangeSeatsTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testConfirmChangeSeats() {
    let subscription = Stripe.Subscription.mock
      |> \.plan .~ .teamYearly
      |> \.quantity .~ 5

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: .account(.subscription(.changeSeats(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 1000))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")
        }
      #endif
    }
  }

  func testConfirmChangeSeatsLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.changeSeats(.show)))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testConfirmChangeSeatsNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .account(.subscription(.changeSeats(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testConfirmChangeSeatsCanceledSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.mock |> \.status .~ .canceled))) {
      let conn = connection(from: request(to: .account(.subscription(.changeSeats(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testConfirmChangeSeatsInvalidPlan() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualMonthly))) {
      let conn = connection(from: request(to: .account(.subscription(.changeSeats(.show))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testChangeSeats() {
    let subscription = Stripe.Subscription.mock
      |> \.plan .~ .teamYearly
      |> \.quantity .~ 5

    AppEnvironment.with(
        (\.stripe.fetchSubscription .~ const(pure(subscription)))
        >>> (\.stripe.updateSubscription .~ { _, _, _, _ in pure(subscription |> \.quantity .~ 10) })
    ) {
      let conn = connection(
        from: request(to: .account(.subscription(.changeSeats(.update(10)))), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testChangeSeatsLoggedOut() {
    let conn = connection(from: request(to: .account(.subscription(.changeSeats(.update(10))))))
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testChangeSeatsNoSubscription() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(throwE(unit))) {
      let conn = connection(from: request(to: .account(.subscription(.changeSeats(.update(10)))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testChangeSeatsCanceledSubscription() {
    let subscription = Stripe.Subscription.mock
      |> \.plan .~ .teamYearly
      |> \.quantity .~ 5
      |> \.status .~ .canceled

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: .account(.subscription(.changeSeats(.update(10)))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testChangeSeatsInvalidPlan() {
    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(.mock |> \.plan .~ .individualMonthly))) {
      let conn = connection(from: request(to: .account(.subscription(.changeSeats(.update(10)))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testChangeSeatsInvalidSeats() {
    let subscription = Stripe.Subscription.mock
      |> \.plan .~ .teamYearly
      |> \.quantity .~ 5

    let env: (Environment) -> Environment =
      (\.database.fetchSubscriptionTeammatesByOwnerId .~ const(pure([.teammate, .teammate])))
        >>> (\.database.fetchTeamInvites .~ const(pure([.mock, .mock])))
        >>> (\.stripe.fetchSubscription .~ const(pure(subscription)))

    AppEnvironment.with(env) {
      let conn = connection(from: request(to: .account(.subscription(.changeSeats(.update(3)))), session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }
}
