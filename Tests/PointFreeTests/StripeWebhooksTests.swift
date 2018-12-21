import Either
import Html
import HtmlPlainTextPrint
import HtmlPrettyPrint
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
      "id": "in_1DjxROD0Nyli3dRgq1vs0OHQ",
      "object": "invoice",
      "amount_due": 1275,
      "amount_paid": 1275,
      "amount_remaining": 0,
      "application_fee": null,
      "attempt_count": 1,
      "attempted": true,
      "auto_advance": false,
      "billing": "charge_automatically",
      "billing_reason": "subscription_create",
      "charge": {
        "id": "ch_1DjxROD0Nyli3dRgJIgfkdLq",
        "object": "charge",
        "amount": 1275,
        "amount_refunded": 0,
        "application": null,
        "application_fee": null,
        "balance_transaction": "txn_1DjxROD0Nyli3dRgwaA8dHvT",
        "captured": true,
        "created": 1545435002,
        "currency": "usd",
        "customer": "cus_ECM94AarJHEcsW",
        "description": null,
        "destination": null,
        "dispute": null,
        "failure_code": null,
        "failure_message": null,
        "fraud_details": {
        },
        "invoice": "in_1DjxROD0Nyli3dRgq1vs0OHQ",
        "livemode": false,
        "metadata": {
        },
        "on_behalf_of": null,
        "order": null,
        "outcome": {
          "network_status": "approved_by_network",
          "reason": null,
          "risk_level": "normal",
          "risk_score": 1,
          "seller_message": "Payment complete.",
          "type": "authorized"
        },
        "paid": true,
        "payment_intent": null,
        "receipt_email": null,
        "receipt_number": null,
        "refunded": false,
        "refunds": {
          "object": "list",
          "data": [

          ],
          "has_more": false,
          "total_count": 0,
          "url": "/v1/charges/ch_1DjxROD0Nyli3dRgJIgfkdLq/refunds"
        },
        "review": null,
        "shipping": null,
        "source": {
          "id": "card_1DjxRMD0Nyli3dRgAWNJI1Ys",
          "object": "card",
          "address_city": "",
          "address_country": "",
          "address_line1": "",
          "address_line1_check": null,
          "address_line2": null,
          "address_state": "",
          "address_zip": "42424",
          "address_zip_check": "pass",
          "brand": "Visa",
          "country": "US",
          "customer": "cus_ECM94AarJHEcsW",
          "cvc_check": null,
          "dynamic_last4": null,
          "exp_month": 4,
          "exp_year": 2024,
          "fingerprint": "oXX2ywFlilbt08Hu",
          "funding": "credit",
          "last4": "4242",
          "metadata": {
          },
          "name": "",
          "tokenization_method": null
        },
        "source_transfer": null,
        "statement_descriptor": null,
        "status": "succeeded",
        "transfer_group": null
      },
      "currency": "usd",
      "customer": "cus_ECM94AarJHEcsW",
      "date": 1545435002,
      "default_source": null,
      "description": null,
      "discount": {
        "object": "discount",
        "coupon": {
          "id": "WIZagOd4",
          "object": "coupon",
          "amount_off": null,
          "created": 1534642706,
          "currency": null,
          "duration": "forever",
          "duration_in_months": null,
          "livemode": false,
          "max_redemptions": null,
          "metadata": {
          },
          "name": "SWIFT-FIKA-2018",
          "percent_off": 25.0,
          "redeem_by": null,
          "times_redeemed": 1,
          "valid": true
        },
        "customer": "cus_ECM94AarJHEcsW",
        "end": null,
        "start": 1545435002,
        "subscription": "sub_ECM9mhcaGwDgMJ"
      },
      "due_date": null,
      "ending_balance": 0,
      "finalized_at": 1545435002,
      "hosted_invoice_url": "https://pay.stripe.com/invoice/invst_6OSZ2vw7t4fQ1R0Ajjip4i3uRv",
      "invoice_pdf": "https://pay.stripe.com/invoice/invst_6OSZ2vw7t4fQ1R0Ajjip4i3uRv/pdf",
      "lines": {
        "object": "list",
        "data": [
          {
            "id": "sli_35ef4d1bf4c81d",
            "object": "line_item",
            "amount": 1700,
            "currency": "usd",
            "description": "1 × Individual Monthly (at $17.00 / month)",
            "discountable": true,
            "livemode": false,
            "metadata": {
            },
            "period": {
              "end": 1548113402,
              "start": 1545435002
            },
            "plan": {
              "id": "individual-monthly",
              "object": "plan",
              "active": true,
              "aggregate_usage": null,
              "amount": 1700,
              "billing_scheme": "per_unit",
              "created": 1513818719,
              "currency": "usd",
              "interval": "month",
              "interval_count": 1,
              "livemode": false,
              "metadata": {
              },
              "nickname": "Individual Monthly",
              "product": "prod_BzH9x8QMPSEtMQ",
              "tiers": null,
              "tiers_mode": null,
              "transform_usage": null,
              "trial_period_days": null,
              "usage_type": "licensed"
            },
            "proration": false,
            "quantity": 1,
            "subscription": "sub_ECM9mhcaGwDgMJ",
            "subscription_item": "si_ECM9A1tGQcqXos",
            "type": "subscription"
          }
        ],
        "has_more": false,
        "total_count": 1,
        "url": "/v1/invoices/in_1DjxROD0Nyli3dRgq1vs0OHQ/lines"
      },
      "livemode": false,
      "metadata": {
      },
      "next_payment_attempt": null,
      "number": "FD447C4-0001",
      "paid": true,
      "period_end": 1545435002,
      "period_start": 1545435002,
      "receipt_number": null,
      "starting_balance": 0,
      "statement_descriptor": null,
      "status": "paid",
      "subscription": "sub_ECM9mhcaGwDgMJ",
      "subtotal": 1700,
      "tax": 0,
      "tax_percent": null,
      "total": 1275,
      "webhooks_delivered_at": 1545435002
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
      "t=\(Int(Current.date().timeIntervalSince1970)),v1=ff6889fe2026eba03829e44f16a95c4e91867b7bceb72deb6ec1fe67e8b1ecc0",
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
      "t=\(Int(Current.date().addingTimeInterval(-600).timeIntervalSince1970)),v1=9a958df6326b3ccedf54bb9009ace87fd46c44513d4ce3ec31041c18ad3eb7d9",
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
