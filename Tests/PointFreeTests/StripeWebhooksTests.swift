import Either
import Html
import HtmlPlainTextPrint
import HttpPipeline
@testable import PointFree
import Optics
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

final class StripeWebhooksTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testDecoding() throws {
    let json = """
{
  "id": "evt_test",
  "type": "invoice.payment_succeeded",
  "data": {
    "object": {
      "id": "in_test",
      "object": "invoice",
      "amount_due": 1700,
      "amount_paid": 1700,
      "amount_remaining": 0,
      "application_fee": null,
      "attempt_count": 1,
      "attempted": true,
      "billing": "charge_automatically",
      "charge": "ch_test",
      "closed": true,
      "currency": "usd",
      "customer": "cus_test",
      "date": 1526000000,
      "description": null,
      "discount": null,
      "due_date": null,
      "ending_balance": 0,
      "forgiven": false,
      "lines": {
        "object": "list",
        "data": [
          {
            "id": "sub_test",
            "object": "line_item",
            "amount": 1700,
            "currency": "usd",
            "description": null,
            "discountable": true,
            "livemode": true,
            "metadata": {
            },
            "period": {
              "end": 1529000000,
              "start": 1526000000
            },
            "plan": {
              "id": "individual-monthly",
              "object": "plan",
              "aggregate_usage": null,
              "amount": 1700,
              "billing_scheme": "per_unit",
              "created": 1515000000,
              "currency": "usd",
              "interval": "month",
              "interval_count": 1,
              "livemode": true,
              "metadata": {
              },
              "name": "Individual Monthly",
              "nickname": null,
              "product": "prod_test",
              "statement_descriptor": null,
              "tiers": null,
              "tiers_mode": null,
              "transform_usage": null,
              "trial_period_days": null,
              "usage_type": "licensed"
            },
            "proration": false,
            "quantity": 1,
            "subscription": null,
            "subscription_item": "si_test",
            "type": "subscription"
          }
        ],
        "has_more": false,
        "total_count": 1,
        "url": "/v1/invoices/in_test/lines"
      },
      "livemode": true,
      "metadata": {
      },
      "next_payment_attempt": null,
      "number": "DEADBEE-0001",
      "paid": true,
      "period_end": 1526000000,
      "period_start": 1523000000,
      "receipt_number": null,
      "starting_balance": 0,
      "statement_descriptor": null,
      "subscription": "sub_test",
      "subtotal": 1700,
      "tax": null,
      "tax_percent": null,
      "total": 1700,
      "webhooks_delivered_at": 1526000000
    },
    "previous_attributes": null
  }
}
"""

    _ = try stripeJsonDecoder.decode(Stripe.Event<Stripe.Invoice>.self, from: Data(json.utf8))
  }

  func testValidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.event(.invoice))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=e576e9c1db4346e58a376714086c2372986266468e7b8fc0838fe0fa60814be1",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testStaleHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.event(.invoice))))
    hook.addValue(
      "t=\(Int(Current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=4e8996fd5a9a22aa8243ea29f0abf36fb41ec8b77807756cf8cb208b4d3d8150",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testInvalidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.event(.invoice))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=deadbeef",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testPastDueEmail() {
    let doc = pastDueEmailView.view(unit)

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 700)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }
}
