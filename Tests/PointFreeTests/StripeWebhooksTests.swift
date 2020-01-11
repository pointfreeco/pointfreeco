import Either
import Html
import HtmlPlainTextPrint
import HttpPipeline
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
@testable import Stripe
#if !os(Linux)
import WebKit
#endif
import XCTest

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
  "object": "event",
  "api_version": "2017-08-15",
  "created": 1578691068,
  "data": {
    "object": {
      "id": "in_test",
      "object": "invoice",
      "account_country": "US",
      "account_name": "Point-Free, Inc.",
      "amount_due": 1260,
      "amount_paid": 1260,
      "amount_remaining": 0,
      "application_fee": null,
      "attempt_count": 2,
      "attempted": true,
      "auto_advance": false,
      "billing": "charge_automatically",
      "billing_reason": "subscription_cycle",
      "charge": "ch_test",
      "closed": true,
      "collection_method": "charge_automatically",
      "created": 1577988811,
      "currency": "usd",
      "custom_fields": null,
      "customer": "cus_test",
      "customer_address": null,
      "customer_email": "test@example.com",
      "customer_name": null,
      "customer_phone": null,
      "customer_shipping": null,
      "customer_tax_exempt": "none",
      "customer_tax_ids": [
      ],
      "date": 1577988811,
      "default_payment_method": null,
      "default_source": null,
      "default_tax_rates": [
      ],
      "description": null,
      "discount": {
        "object": "discount",
        "coupon": {
          "id": "cyber-monday-2019",
          "object": "coupon",
          "amount_off": null,
          "created": 1575243866,
          "currency": null,
          "duration": "repeating",
          "duration_in_months": 12,
          "livemode": true,
          "max_redemptions": null,
          "metadata": {
          },
          "name": "Cyber Monday 2019",
          "percent_off": 30,
          "percent_off_precise": 30,
          "redeem_by": 1575392400,
          "times_redeemed": 72,
          "valid": false
        },
        "customer": "cus_test",
        "end": 1606932807,
        "start": 1575310407,
        "subscription": "sub_test"
      },
      "due_date": null,
      "ending_balance": 0,
      "finalized_at": 1577992648,
      "footer": null,
      "forgiven": false,
      "hosted_invoice_url": "https://pay.stripe.com/invoice/invst_test",
      "invoice_pdf": "https://pay.stripe.com/invoice/invst_test/pdf",
      "lines": {
        "object": "list",
        "data": [
          {
            "id": "sub_test",
            "object": "line_item",
            "amount": 1800,
            "currency": "usd",
            "description": null,
            "discountable": true,
            "livemode": true,
            "metadata": {
            },
            "period": {
              "end": 1580667207,
              "start": 1577988807
            },
            "plan": {
              "id": "monthly-2019",
              "object": "plan",
              "active": true,
              "aggregate_usage": null,
              "amount": null,
              "amount_decimal": null,
              "billing_scheme": "tiered",
              "created": 1566052471,
              "currency": "usd",
              "interval": "month",
              "interval_count": 1,
              "livemode": true,
              "metadata": {
              },
              "name": "Point-Free Monthly",
              "nickname": "Point-Free Monthly",
              "product": "prod_test",
              "statement_descriptor": "POINT-FREE MONTHLY",
              "tiers": [
                {
                  "amount": 1800,
                  "flat_amount": null,
                  "flat_amount_decimal": null,
                  "unit_amount_decimal": "1800",
                  "up_to": 1
                },
                {
                  "amount": 1600,
                  "flat_amount": null,
                  "flat_amount_decimal": null,
                  "unit_amount_decimal": "1600",
                  "up_to": null
                }
              ],
              "tiers_mode": "volume",
              "transform_usage": null,
              "trial_period_days": null,
              "usage_type": "licensed"
            },
            "proration": false,
            "quantity": 1,
            "subscription": null,
            "subscription_item": "si_test",
            "tax_amounts": [
            ],
            "tax_rates": [
            ],
            "type": "subscription",
            "unique_id": "il_test",
            "unique_line_item_id": "sli_test"
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
      "number": "A7CC96D4-0002",
      "paid": true,
      "payment_intent": "pi_test",
      "period_end": 1577988807,
      "period_start": 1575310407,
      "post_payment_credit_notes_amount": 0,
      "pre_payment_credit_notes_amount": 0,
      "receipt_number": null,
      "starting_balance": 0,
      "statement_descriptor": null,
      "status": "paid",
      "status_transitions": {
        "finalized_at": 1577992648,
        "marked_uncollectible_at": null,
        "paid_at": 1578691067,
        "voided_at": null
      },
      "subscription": "sub_test",
      "subtotal": 1800,
      "tax": null,
      "tax_percent": null,
      "total": 1260,
      "total_tax_amounts": [
      ],
      "webhooks_delivered_at": 1577988812
    }
  },
  "livemode": true,
  "pending_webhooks": 1,
  "request": {
    "id": null,
    "idempotency_key": null
  },
  "type": "invoice.payment_succeeded"
}
"""

    try Stripe.jsonDecoder.decode(Stripe.Event<Stripe.Invoice>.self, from: Data(json.utf8))
  }

  func testValidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.knownEvent(.invoice))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=0a40efd7b8fa89a7a4f5ce3138dcd18cfb63f12bdccf5a9c77f405c43b57a2d1",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testStaleHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.knownEvent(.invoice))))
    hook.addValue(
      "t=\(Int(Current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=0a40efd7b8fa89a7a4f5ce3138dcd18cfb63f12bdccf5a9c77f405c43b57a2d1",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testInvalidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.knownEvent(.invoice))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=deadbeef",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testNoInvoiceSubscriptionId() {
    #if !os(Linux)
    let invoice = Invoice.mock(charge: .left("ch_test"))
      |> \.subscription .~ nil
    let event = Event<Either<Invoice, Subscription>>(
      data: .init(object: .left(invoice)),
      id: "evt_test",
      type: .invoicePaymentFailed
    )

    var hook = request(to: .webhooks(.stripe(.knownEvent(event))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=88c795045454a2977201390f375156287035824e8fbae5da6508777e43b6f637",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testNoInvoiceSubscriptionId_AndNoLineItemSubscriptionId() {
    #if !os(Linux)
    let invoice = Invoice.mock(charge: .left("ch_test"))
      |> \.subscription .~ nil
      |> \.lines.data .~ [
        .mock
          |> \.subscription .~ nil
    ]
    let event = Event<Either<Invoice, Subscription>>(
      data: .init(object: .left(invoice)),
      id: "evt_test",
      type: .invoicePaymentFailed
    )

    var hook = request(to: .webhooks(.stripe(.knownEvent(event))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=5f4853f7a2c6ffe6497cdabf7ae10fc693d3b1e8caa70ccfeca6b460872040b4",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testPastDueEmail() {
    let doc = pastDueEmailView(unit)

    assertSnapshot(matching: doc, as: .html)
    assertSnapshot(matching: plainText(for: doc), as: .lines)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 800))
      webView.loadHTMLString(render(doc), baseURL: nil)
      assertSnapshot(matching: webView, as: .image)

      webView.frame.size = .init(width: 400, height: 700)
      assertSnapshot(matching: webView, as: .image)
    }
    #endif
  }
}
