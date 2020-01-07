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
  }

  func testValidHook() {
    #if !os(Linux)
    var hook = request(to: .webhooks(.stripe(.knownEvent(.invoice))))
    hook.addValue(
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=0a5165bc2b26cc1fa438d7c7cf76d8625104edb05b38993c7af63d74189a0c7a",
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
      "t=\(Int(Current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=0a5165bc2b26cc1fa438d7c7cf76d8625104edb05b38993c7af63d74189a0c7a",
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
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=1c51cbdeb494f239e41b5ed50d816e61c6fa0c1cbf269f245b9ce0659b1eca3c",
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
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=d333002410d8aa50c4426c42d7d2e87d1fcbd4f103326c1bcceb19db85fcff01",
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
