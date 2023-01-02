import Dependencies
import Either
import Html
import HtmlPlainTextPrint
import HtmlSnapshotTesting
import HttpPipeline
import Mailgun
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree
@testable import Stripe

#if !os(Linux)
  import WebKit
#endif

@MainActor
final class CancelTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  func testCancel() async throws {
    var immediately: Bool?
    let expectation = self.expectation(description: "sendEmail")

    await withDependencyValues {
      let cancelSubscription = Current.stripe.cancelSubscription
      $0.stripe.cancelSubscription = {
        immediately = $1
        return try await cancelSubscription($0, $1)
      }
      $0.mailgun.sendEmail = { email in
        expectation.fulfill()
        XCTAssertEqual(email.subject, "[testing] Your subscription has been canceled")
        return SendEmailResponse(id: "mail-id", message: "")
      }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      XCTAssertEqual(false, immediately)
    }

    self.wait(for: [expectation], timeout: 0)
  }

  func testCancelPastDue() async throws {
    var immediately: Bool?

    await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in update(.mock) { $0.status = .pastDue } }
      let cancelSubscription = Current.stripe.cancelSubscription
      $0.stripe.cancelSubscription = {
        immediately = $1
        return try await cancelSubscription($0, $1)
      }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      XCTAssertEqual(true, immediately)
    }
  }

  func testCancelLoggedOut() async throws {
    let conn = connection(from: request(to: .account(.subscription(.cancel))))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testCancelNoSubscription() async throws {
    await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in throw unit }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testCancelCancelingSubscription() async throws {
    await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in .canceling }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testCancelCanceledSubscription() async throws {
    await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in .canceled }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testCancelStripeFailure() async throws {
    await withDependencyValues {
      $0.stripe.cancelSubscription = { _, _ in throw unit }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testCancelEmail() async throws {
    let doc = cancelEmailView((.mock, .mock))

    await assertSnapshot(matching: doc, as: .html)
    await assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
        webView.loadHTMLString(render(doc), baseURL: nil)
        await assertSnapshot(matching: webView, as: .image)

        webView.frame.size = .init(width: 400, height: 700)
        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }

  func testReactivate() async throws {
    await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in .canceling }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testReactivateLoggedOut() async throws {
    let conn = connection(from: request(to: .account(.subscription(.reactivate))))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateNoSubscription() async throws {
    await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testReactivateActiveSubscription() async throws {
    let conn = connection(
      from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testReactivateCanceledSubscription() async throws {
    await withDependencyValues {
      $0.stripe.fetchSubscription = { _ in .canceled }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testReactivateStripeFailure() async throws {
    await withDependencyValues {
      $0.stripe.updateSubscription = { _, _, _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testReactivateEmail() async throws {
    let doc = reactivateEmailView((.mock, .mock))

    await assertSnapshot(matching: doc, as: .html)
    await assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
        webView.loadHTMLString(render(doc), baseURL: nil)
        await assertSnapshot(matching: webView, as: .image)

        webView.frame.size = .init(width: 400, height: 700)
        await assertSnapshot(matching: webView, as: .image)
      }
    #endif
  }
}
