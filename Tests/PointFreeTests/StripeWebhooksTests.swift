import Either
import Html
import HtmlPlainTextPrint
import HttpPipeline
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
//    SnapshotTesting.isRecording = true
  }

  func testDecoding() throws {
    let json = """
{
  "id": "evt_1FyO3MD0Nyli3dRgk47ZGyCo",
  "object": "event",
  "api_version": "2019-12-03",
  "created": 1578426564,
  "data": {
    "object": {
      "id": "in_1FyO1tD0Nyli3dRgJf6GaMHT",
      "object": "invoice",
      "account_country": "US",
      "account_name": "Point-Free, Inc.",
      "amount_due": 2000,
      "amount_paid": 0,
      "amount_remaining": 2000,
      "attempt_count": 1,
      "attempted": true,
      "auto_advance": true,
      "billing_reason": "manual",
      "charge": "ch_1FyO1uD0Nyli3dRg4VrNlXQs",
      "collection_method": "charge_automatically",
      "created": 1578426473,
      "currency": "usd",
      "custom_fields": null,
      "customer": "cus_GVOpkZIBdvM6Kx",
      "customer_address": null,
      "customer_email": null,
      "customer_name": null,
      "customer_phone": null,
      "customer_shipping": null,
      "customer_tax_exempt": "none",
      "customer_tax_ids": [

      ],
      "default_payment_method": null,
      "default_source": null,
      "default_tax_rates": [

      ],
      "description": "(created by Stripe CLI)",
      "discount": null,
      "due_date": null,
      "ending_balance": 0,
      "footer": null,
      "hosted_invoice_url": "https://pay.stripe.com/invoice/invst_W3mOVwMEUH5LlknZ79xMDrV2iy",
      "invoice_pdf": "https://pay.stripe.com/invoice/invst_W3mOVwMEUH5LlknZ79xMDrV2iy/pdf",
      "lines": {
        "object": "list",
        "data": [
          {
            "id": "il_1FyO1sD0Nyli3dRgjmhFXFlT",
            "object": "line_item",
            "amount": 2000,
            "currency": "usd",
            "description": "(created by Stripe CLI)",
            "discountable": true,
            "invoice_item": "ii_1FyO1sD0Nyli3dRgknhHc7Bp",
            "livemode": false,
            "metadata": {
            },
            "period": {
              "end": 1578426472,
              "start": 1578426472
            },
            "plan": null,
            "proration": false,
            "quantity": 1,
            "subscription": null,
            "tax_amounts": [

            ],
            "tax_rates": [

            ],
            "type": "invoiceitem"
          }
        ],
        "has_more": false,
        "total_count": 1,
        "url": "/v1/invoices/in_1FyO1tD0Nyli3dRgJf6GaMHT/lines"
      },
      "livemode": false,
      "metadata": {
      },
      "next_payment_attempt": 1579031274,
      "number": "6371C201-0001",
      "paid": false,
      "payment_intent": "pi_1FyO1uD0Nyli3dRgEsRJums1",
      "period_end": 1578426473,
      "period_start": 1578426473,
      "post_payment_credit_notes_amount": 0,
      "pre_payment_credit_notes_amount": 0,
      "receipt_number": null,
      "starting_balance": 0,
      "statement_descriptor": null,
      "status": "open",
      "status_transitions": {
        "finalized_at": 1578426474,
        "marked_uncollectible_at": null,
        "paid_at": null,
        "voided_at": null
      },
      "subscription": null,
      "subtotal": 2000,
      "tax": null,
      "tax_percent": null,
      "total": 2000,
      "total_tax_amounts": [

      ],
      "webhooks_delivered_at": 1578426475,
      "application_fee_amount": null
    }
  },
  "livemode": false,
  "pending_webhooks": 2,
  "request": {
    "id": null,
    "idempotency_key": null
  },
  "type": "invoice.payment_failed"
}
"""

    _ = try Stripe.jsonDecoder.decode(Stripe.Event<Stripe.Invoice>.self, from: Data(json.utf8))

    _ = try Stripe.jsonDecoder.decode(Stripe.Event<Stripe.Invoice>.self, from: Data(#"""
{
  "id": "evt_test",
  "object": "event",
  "api_version": "2019-12-03",
  "created": 1580021134,
  "data": {
    "object": {
      "id": "in_test",
      "object": "invoice",
      "account_country": "US",
      "account_name": "Point-Free, Inc.",
      "amount_due": 1800,
      "amount_paid": 0,
      "amount_remaining": 1800,
      "application_fee_amount": null,
      "attempt_count": 1,
      "attempted": true,
      "auto_advance": true,
      "billing_reason": "subscription_create",
      "charge": "ch_test",
      "collection_method": "charge_automatically",
      "created": 1580021131,
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
      "default_payment_method": null,
      "default_source": null,
      "default_tax_rates": [
      ],
      "description": null,
      "discount": null,
      "due_date": null,
      "ending_balance": 0,
      "footer": null,
      "hosted_invoice_url": "https://pay.stripe.com/invoice/invst_test",
      "invoice_pdf": "https://pay.stripe.com/invoice/invst_test/pdf",
      "lines": {
        "object": "list",
        "data": [
          {
            "id": "il_test",
            "object": "line_item",
            "amount": 1800,
            "currency": "usd",
            "description": "1 seat × Point-Free Monthly (Tier 1 at $18.00 / month)",
            "discountable": true,
            "livemode": true,
            "metadata": {
            },
            "period": {
              "end": 1582699530,
              "start": 1580021130
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
              "nickname": "Point-Free Monthly",
              "product": "prod_test",
              "tiers": [
                {
                  "flat_amount": null,
                  "flat_amount_decimal": null,
                  "unit_amount": 1800,
                  "unit_amount_decimal": "1800",
                  "up_to": 1
                },
                {
                  "flat_amount": null,
                  "flat_amount_decimal": null,
                  "unit_amount": 1600,
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
            "subscription": "sub_test",
            "subscription_item": "si_test",
            "tax_amounts": [
            ],
            "tax_rates": [
            ],
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
      "number": null,
      "paid": false,
      "payment_intent": "pi_test",
      "period_end": 1580021130,
      "period_start": 1580021130,
      "post_payment_credit_notes_amount": 0,
      "pre_payment_credit_notes_amount": 0,
      "receipt_number": null,
      "starting_balance": 0,
      "statement_descriptor": null,
      "status": "open",
      "status_transitions": {
        "finalized_at": 1580021131,
        "marked_uncollectible_at": null,
        "paid_at": null,
        "voided_at": null
      },
      "subscription": "sub_test",
      "subtotal": 1800,
      "tax": null,
      "tax_percent": null,
      "total": 1800,
      "total_tax_amounts": [
      ],
      "webhooks_delivered_at": null
    }
  },
  "livemode": true,
  "pending_webhooks": 1,
  "request": {
    "id": "req_test",
    "idempotency_key": null
  },
  "type": "invoice.payment_failed"
}
"""#.utf8))
  }

  func testValidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.knownEvent(.invoice))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=a3cd5f0626de9b0a1aa72ae8e7dd4392023aeed8b1a390ce4cb7b7b29b32e814",
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
      "t=\(Int(Current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=a3cd5f0626de9b0a1aa72ae8e7dd4392023aeed8b1a390ce4cb7b7b29b32e814",
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
    var invoice = Invoice.mock(charge: .left("ch_test"))
    invoice.subscription = nil
    let event = Event<Either<Invoice, Subscription>>(
      data: .init(object: .left(invoice)),
      id: "evt_test",
      type: .invoicePaymentFailed
    )

    var hook = request(to: .webhooks(.stripe(.knownEvent(event))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=c2ed25f2feb58213ce60099e2a0e2be3b78e06a5d05c582c83084b739571349d",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testNoInvoiceSubscriptionId_AndNoLineItemSubscriptionId() {
    #if !os(Linux)
    var invoice = Invoice.mock(charge: .left("ch_test"))
    invoice.subscription = nil
    var line = LineItem.mock
    line.subscription = nil
    invoice.lines.data = [line]
    let event = Event<Either<Invoice, Subscription>>(
      data: .init(object: .left(invoice)),
      id: "evt_test",
      type: .invoicePaymentFailed
    )

    var hook = request(to: .webhooks(.stripe(.knownEvent(event))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=29a84de76bc01997e8456be0e39a809e9e207a7768efae7de482f72b21c9dfa8",
      forHTTPHeaderField: "Stripe-Signature"
    )

    let conn = connection(from: hook)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testNoInvoiceNumber() {
    #if !os(Linux)
    var invoice = Invoice.mock(charge: .left("ch_test"))
    invoice.number = nil
    let event = Event<Either<Invoice, Subscription>>(
      data: .init(object: .left(invoice)),
      id: "evt_test",
      type: .invoicePaymentFailed
    )

    var hook = request(to: .webhooks(.stripe(.knownEvent(event))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=fc1d0cfd072a6c126ab8fa52bc8ad956c3337b45a07ce404e028a6dd1c921b5a",
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
