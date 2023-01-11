import Dependencies
import Either
import Html
import HtmlPlainTextPrint
import HttpPipeline
import Mailgun
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree
@testable import Stripe

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
#if !os(Linux)
  import WebKit
#endif

@MainActor
final class StripeWebhooksTests: TestCase {
  @Dependency(\.date.now) var now

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testDecoding() async throws {
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

    _ = try Stripe.jsonDecoder.decode(
      Stripe.Event<Stripe.Invoice>.self,
      from: Data(
        #"""
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

  func testValidHook() async throws {
    #if !os(Linux)
      var hook = request(to: .webhooks(.stripe(.subscriptions(.invoice))))
      try self.addStripeSignature(
        to: &hook,
        payload: .init(decoding: Stripe.jsonEncoder.encode(Event.invoice), as: UTF8.self)
      )

      let conn = connection(from: hook)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testStaleHook() async throws {
    #if !os(Linux)
      var hook = request(to: .webhooks(.stripe(.subscriptions(.invoice))))
      try self.addStripeSignature(
        to: &hook,
        timestamp: Int(self.now.addingTimeInterval(-600).timeIntervalSince1970),
        payload: .init(decoding: Stripe.jsonEncoder.encode(Event.invoice), as: UTF8.self)
      )

      let conn = connection(from: hook)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testInvalidHook() async throws {
    #if !os(Linux)
      var hook = request(to: .webhooks(.stripe(.subscriptions(.invoice))))
      try self.addStripeSignature(to: &hook, payload: "deadbeef")

      let conn = connection(from: hook)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testNoInvoiceSubscriptionId() async throws {
    #if !os(Linux)
      var invoice = Invoice.mock(charge: .left("ch_test"))
      invoice.subscription = nil
      let event = Event<Either<Invoice, Subscription>>(
        data: .init(object: .left(invoice)),
        id: "evt_test",
        type: .invoicePaymentFailed
      )

      var hook = request(to: .webhooks(.stripe(.subscriptions(event))))
      try self.addStripeSignature(
        to: &hook,
        payload: .init(decoding: Stripe.jsonEncoder.encode(event), as: UTF8.self)
      )

      let conn = connection(from: hook)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testNoInvoiceSubscriptionId_AndNoLineItemSubscriptionId() async throws {
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

      var hook = request(to: .webhooks(.stripe(.subscriptions(event))))
      try self.addStripeSignature(
        to: &hook,
        payload: .init(decoding: Stripe.jsonEncoder.encode(event), as: UTF8.self)
      )

      let conn = connection(from: hook)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testNoInvoiceNumber() async throws {
    #if !os(Linux)
      var invoice = Invoice.mock(charge: .left("ch_test"))
      invoice.number = nil
      let event = Event<Either<Invoice, Subscription>>(
        data: .init(object: .left(invoice)),
        id: "evt_test",
        type: .invoicePaymentFailed
      )

      var hook = request(to: .webhooks(.stripe(.subscriptions(event))))
      try self.addStripeSignature(
        to: &hook,
        payload: .init(decoding: Stripe.jsonEncoder.encode(event), as: UTF8.self)
      )

      let conn = connection(from: hook)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    #endif
  }

  func testPastDueEmail() async throws {
    let doc = pastDueEmailView(unit)

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

  func testPaymentIntent_Gift() async throws {
    var delivered = false
    var didSendEmail = false
    try await withDependencies {
      $0.date.now = .mock
      $0.database.fetchGiftByStripePaymentIntentId = { _ in .unfulfilled }
      $0.database.updateGiftStatus = {
        delivered = $2
        return .unfulfilled
      }
      $0.mailgun.sendEmail = { _ in
        didSendEmail = true
        return SendEmailResponse(id: "", message: "")
      }
    } operation: {
      let event = Event(
        data: .init(object: PaymentIntent.succeeded),
        id: "evt_test",
        type: .paymentIntentSucceeded
      )

      var hook = request(to: .webhooks(.stripe(.paymentIntents(event))))
      try self.addStripeSignature(
        to: &hook,
        payload: .init(decoding: Stripe.jsonEncoder.encode(event), as: UTF8.self)
      )

      let conn = connection(from: hook)
      await _assertInlineSnapshot(
        matching: conn |> siteMiddleware, as: .ioConn,
        with: """
          POST http://localhost:8080/webhooks/stripe
          Cookie: pf_session={}
          Stripe-Signature: t=1517356800,v1=56e9dda4effc9b385ee914757ab7b6c6b2ae8acc6d7d037e73870c0c27589988

          {
            "data" : {
              "object" : {
                "amount" : 5400,
                "client_secret" : "pi_test_secret_test",
                "currency" : "usd",
                "id" : "pi_test",
                "status" : "succeeded"
              }
            },
            "id" : "evt_test",
            "type" : "payment_intent.succeeded"
          }

          200 OK
          Content-Length: 2
          Content-Type: text/plain
          Referrer-Policy: strict-origin-when-cross-origin
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block

          OK
          """)

      XCTAssertEqual(delivered, true)
      XCTAssertEqual(didSendEmail, true)
    }
  }

  func testPaymentIntent_NoGift() async throws {
    try await withDependencies {
      $0.date.now = .mock
      $0.database.fetchGiftByStripePaymentIntentId = { _ in throw unit }
    } operation: {
      let event = Event(
        data: .init(object: PaymentIntent.succeeded),
        id: "evt_test",
        type: .paymentIntentSucceeded
      )

      var hook = request(to: .webhooks(.stripe(.paymentIntents(event))))
      try self.addStripeSignature(
        to: &hook,
        payload: .init(decoding: Stripe.jsonEncoder.encode(event), as: UTF8.self)
      )

      let conn = connection(from: hook)
      await _assertInlineSnapshot(
        matching: conn |> siteMiddleware, as: .ioConn,
        with: """
          POST http://localhost:8080/webhooks/stripe
          Cookie: pf_session={}
          Stripe-Signature: t=1517356800,v1=56e9dda4effc9b385ee914757ab7b6c6b2ae8acc6d7d037e73870c0c27589988

          {
            "data" : {
              "object" : {
                "amount" : 5400,
                "client_secret" : "pi_test_secret_test",
                "currency" : "usd",
                "id" : "pi_test",
                "status" : "succeeded"
              }
            },
            "id" : "evt_test",
            "type" : "payment_intent.succeeded"
          }

          200 OK
          Content-Length: 2
          Content-Type: text/plain
          Referrer-Policy: strict-origin-when-cross-origin
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block

          OK
          """)
    }
  }

  func testFailedPaymentIntent() async throws {
    try await withDependencies {
      $0.date.now = .mock
      $0.database.fetchGiftByStripePaymentIntentId = { _ in throw unit }
    } operation: {
      let event = Event(
        data: .init(object: PaymentIntent.requiresConfirmation),
        id: "evt_test",
        type: .paymentIntentPaymentFailed
      )

      var hook = request(to: .webhooks(.stripe(.paymentIntents(event))))
      try self.addStripeSignature(
        to: &hook,
        payload: .init(decoding: Stripe.jsonEncoder.encode(event), as: UTF8.self)
      )

      let conn = connection(from: hook)
      await _assertInlineSnapshot(
        matching: conn |> siteMiddleware, as: .ioConn,
        with: """
          POST http://localhost:8080/webhooks/stripe
          Cookie: pf_session={}
          Stripe-Signature: t=1517356800,v1=0abe38e2637c25a8e99ea0cb9028534c41e240a3ca48fe7347ba23dd31f805a4

          {
            "data" : {
              "object" : {
                "amount" : 5400,
                "client_secret" : "pi_test_secret_test",
                "currency" : "usd",
                "id" : "pi_test",
                "status" : "requires_confirmation"
              }
            },
            "id" : "evt_test",
            "type" : "payment_intent.payment_failed"
          }

          200 OK
          Content-Length: 2
          Content-Type: text/plain
          Referrer-Policy: strict-origin-when-cross-origin
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block

          OK
          """)
    }
  }

  private func addStripeSignature(
    to request: inout URLRequest,
    timestamp: Int? = nil,
    payload: String
  ) throws {
    let signature = try XCTUnwrap(
      generateStripeSignature(
        timestamp: timestamp ?? Int(self.now.timeIntervalSince1970),
        payload: payload
      )
    )

    request.addValue(
      "t=\(Int(self.now.timeIntervalSince1970)),v1=\(signature)",
      forHTTPHeaderField: "Stripe-Signature"
    )
  }
}
