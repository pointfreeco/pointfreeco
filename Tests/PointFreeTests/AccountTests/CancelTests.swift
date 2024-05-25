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

final class CancelTests: TestCase {
  @Dependency(\.stripe) var stripe

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  @MainActor
  func testCancel() async throws {
    var immediately: Bool?
    let expectation = self.expectation(description: "sendEmail")

    await withDependencies {
      let cancelSubscription = self.stripe.cancelSubscription
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
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      XCTAssertEqual(false, immediately)
    }

    _ = { self.wait(for: [expectation], timeout: 0) }()
  }

  @MainActor
  func testCancelPastDue() async throws {
    var immediately: Bool?

    await withDependencies {
      $0.stripe.fetchSubscription = { _ in update(.mock) { $0.status = .pastDue } }
      let cancelSubscription = self.stripe.cancelSubscription
      $0.stripe.cancelSubscription = {
        immediately = $1
        return try await cancelSubscription($0, $1)
      }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
      XCTAssertEqual(true, immediately)
    }
  }

  @MainActor
  func testCancelLoggedOut() async throws {
    let conn = connection(from: request(to: .account(.subscription(.cancel))))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  func testCancelNoSubscription() async throws {
    await withDependencies {
      $0.stripe.fetchSubscription = { _ in throw unit }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testCancelCancelingSubscription() async throws {
    await withDependencies {
      $0.stripe.fetchSubscription = { _ in .canceling }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testCancelCanceledSubscription() async throws {
    await withDependencies {
      $0.stripe.fetchSubscription = { _ in .canceled }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testCancelStripeFailure() async throws {
    await withDependencies {
      $0.stripe.cancelSubscription = { _, _ in throw unit }
    } operation: {
      let conn = connection(from: request(to: .account(.subscription(.cancel)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
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

  @MainActor
  func testReactivate() async throws {
    await withDependencies {
      $0.stripe.fetchSubscription = { _ in .canceling }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testReactivateLoggedOut() async throws {
    let conn = connection(from: request(to: .account(.subscription(.reactivate))))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testReactivateNoSubscription() async throws {
    await withDependencies {
      $0.stripe.fetchSubscription = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testReactivateActiveSubscription() async throws {
    let conn = connection(
      from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testReactivateCanceledSubscription() async throws {
    await withDependencies {
      $0.stripe.fetchSubscription = { _ in .canceled }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testReactivateStripeFailure() async throws {
    await withDependencies {
      $0.stripe.updateSubscription = { _, _, _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(to: .account(.subscription(.reactivate)), session: .loggedIn))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
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
