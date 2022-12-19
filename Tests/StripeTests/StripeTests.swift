import Either
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import StripeTestSupport
import XCTest

@testable import Stripe

final class StripeTests: TestCase {

  override func setUp() {
    super.setUp()
    // SnapshotTesting.isRecording=true
  }

  func testDecodingCustomer() throws {
    let jsonString = """
      {
        "id": "cus_GlUzpQx6pl4AIh",
        "object": "customer",
        "address": null,
        "balance": 0,
        "created": 1582139637,
        "currency": "usd",
        "default_source": null,
        "delinquent": false,
        "description": null,
        "discount": null,
        "email": null,
        "invoice_prefix": "038018A",
        "invoice_settings": {
          "custom_fields": null,
          "default_payment_method": null,
          "footer": null
        },
        "livemode": false,
        "metadata": {},
        "name": null,
        "phone": null,
        "preferred_locales": [],
        "shipping": null,
        "sources": {
          "object": "list",
          "data": [],
          "has_more": false,
          "url": "/v1/customers/cus_GlUzpQx6pl4AIh/sources"
        },
        "subscriptions": {
          "object": "list",
          "data": [],
          "has_more": false,
          "url": "/v1/customers/cus_GlUzpQx6pl4AIh/subscriptions"
        },
        "tax_exempt": "none",
        "tax_ids": {
          "object": "list",
          "data": [],
          "has_more": false,
          "url": "/v1/customers/cus_GlUzpQx6pl4AIh/tax_ids"
        }
      }
      """

    do {
      let customer = try Stripe.jsonDecoder.decode(Customer.self, from: Data(jsonString.utf8))

      XCTAssertEqual(nil, customer.businessVatId)
      XCTAssertEqual("cus_GlUzpQx6pl4AIh", customer.id)
      XCTAssertEqual([:], customer.metadata)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  func testDecodingCustomer_Metadata() throws {
    let jsonString = """
      {
        "id": "cus_GlUzpQx6pl4AIh",
        "object": "customer",
        "address": null,
        "balance": 0,
        "created": 1582139637,
        "currency": "usd",
        "default_source": null,
        "delinquent": false,
        "description": null,
        "discount": null,
        "email": null,
        "invoice_prefix": "038018A",
        "invoice_settings": {
          "custom_fields": null,
          "default_payment_method": null,
          "footer": null
        },
        "livemode": false,
        "metadata": {
          "extraInvoiceInfo": "VAT: 123456789"
        },
        "name": null,
        "phone": null,
        "preferred_locales": [],
        "shipping": null,
        "sources": {
          "object": "list",
          "data": [],
          "has_more": false,
          "url": "/v1/customers/cus_GlUzpQx6pl4AIh/sources"
        },
        "subscriptions": {
          "object": "list",
          "data": [],
          "has_more": false,
          "url": "/v1/customers/cus_GlUzpQx6pl4AIh/subscriptions"
        },
        "tax_exempt": "none",
        "tax_ids": {
          "object": "list",
          "data": [],
          "has_more": false,
          "url": "/v1/customers/cus_GlUzpQx6pl4AIh/tax_ids"
        }
      }
      """

    let customer = try Stripe.jsonDecoder.decode(Customer.self, from: Data(jsonString.utf8))

    XCTAssertEqual(nil, customer.businessVatId)
    XCTAssertEqual("cus_GlUzpQx6pl4AIh", customer.id)
    XCTAssertEqual(["extraInvoiceInfo": "VAT: 123456789"], customer.metadata)
    XCTAssertEqual("VAT: 123456789", customer.extraInvoiceInfo)
  }

  func testDecodingPlan_WithNickname() throws {
    let jsonString = """
      {
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
        "statement_descriptor": null,
        "tiers": null,
        "tiers_mode": null,
        "transform_usage": null,
        "trial_period_days": null,
        "usage_type": "licensed"
      }
      """

    let plan = try Stripe.jsonDecoder.decode(Plan.self, from: Data(jsonString.utf8))

    XCTAssertEqual("Individual Monthly", plan.nickname)
  }

  func testDecodingSubscriptionWithDiscount() throws {
    let jsonString = """
      {
        "id": "sub_GVRtJttAzOiMPg",
        "object": "subscription",
        "application_fee_percent": null,
        "billing_cycle_anchor": 1578437899,
        "billing_thresholds": null,
        "cancel_at": null,
        "cancel_at_period_end": false,
        "canceled_at": null,
        "collection_method": "charge_automatically",
        "created": 1578437899,
        "current_period_end": 1581116299,
        "current_period_start": 1578437899,
        "customer": "cus_GVRtJN8LjWXJdL",
        "days_until_due": null,
        "default_payment_method": null,
        "default_source": null,
        "default_tax_rates": [

        ],
        "discount": {
          "object": "discount",
          "coupon": {
            "id": "15-percent",
            "object": "coupon",
            "amount_off": null,
            "created": 1515346678,
            "currency": null,
            "duration": "forever",
            "duration_in_months": null,
            "livemode": false,
            "max_redemptions": null,
            "metadata": {
            },
            "name": "15% Off",
            "percent_off": 15,
            "percent_off_precise": 15.0,
            "redeem_by": null,
            "times_redeemed": 2,
            "valid": true
          },
          "customer": "cus_GVRtJN8LjWXJdL",
          "end": null,
          "start": 1533218660,
          "subscription": "sub_GVRtJttAzOiMPg"
        },
        "ended_at": null,
        "items": {
          "object": "list",
          "data": [
            {
              "id": "si_GVRt0uvjMxAoVV",
              "object": "subscription_item",
              "billing_thresholds": null,
              "created": 1578437899,
              "metadata": {
              },
              "plan": {
                "id": "plan_GVRtPfU0wnWPC5",
                "object": "plan",
                "active": true,
                "aggregate_usage": null,
                "amount": 2000,
                "amount_decimal": "2000",
                "billing_scheme": "per_unit",
                "created": 1578437898,
                "currency": "usd",
                "interval": "month",
                "interval_count": 1,
                "livemode": false,
                "metadata": {
                },
                "nickname": "Point-Free Monthly",
                "product": "prod_GVRtIVoEidgAjD",
                "tiers": null,
                "tiers_mode": null,
                "transform_usage": null,
                "trial_period_days": null,
                "usage_type": "licensed"
              },
              "quantity": 1,
              "subscription": "sub_GVRtJttAzOiMPg",
              "tax_rates": [

              ]
            }
          ],
          "has_more": false,
          "total_count": 1,
          "url": "/v1/subscription_items?subscription=sub_GVRtJttAzOiMPg"
        },
        "latest_invoice": "in_1FyR0BD0Nyli3dRgBzTjLMSa",
        "livemode": false,
        "metadata": {
        },
        "next_pending_invoice_item_invoice": null,
        "pending_invoice_item_interval": null,
        "pending_setup_intent": null,
        "plan": {
          "id": "plan_GVRtPfU0wnWPC5",
          "object": "plan",
          "active": true,
          "aggregate_usage": null,
          "amount": 2000,
          "amount_decimal": "2000",
          "billing_scheme": "per_unit",
          "created": 1578437898,
          "currency": "usd",
          "interval": "month",
          "interval_count": 1,
          "livemode": false,
          "metadata": {
          },
          "nickname": "Point-Free Monthly",
          "product": "prod_GVRtIVoEidgAjD",
          "tiers": null,
          "tiers_mode": null,
          "transform_usage": null,
          "trial_period_days": null,
          "usage_type": "licensed"
        },
        "quantity": 1,
        "schedule": null,
        "start_date": 1578437899,
        "status": "active",
        "tax_percent": null,
        "trial_end": null,
        "trial_start": null
      }
      """

    let subscription = try Stripe.jsonDecoder.decode(Subscription.self, from: Data(jsonString.utf8))

    XCTAssertEqual("15-percent", subscription.discount?.coupon.id)
  }

  func testDecodingDiscountJson() throws {
    let jsonString = """
        {
          "object": "discount",
          "coupon": {
            "id": "15-percent",
            "object": "coupon",
            "amount_off": null,
            "created": 1515346678,
            "currency": null,
            "duration": "repeating",
            "duration_in_months": 12,
            "livemode": false,
            "max_redemptions": null,
            "metadata": {
            },
            "name": "15% Off",
            "percent_off": 15,
            "percent_off_precise": 15.0,
            "redeem_by": null,
            "times_redeemed": 2,
            "valid": true
          },
          "customer": "cus_DLOB6Ix7b7Xu83",
          "end": null,
          "start": 1533218660,
          "subscription": "sub_DLOCPKtT3ezRQ7"
        }
      """

    let discount = try Stripe.jsonDecoder.decode(Discount.self, from: Data(jsonString.utf8))

    XCTAssertEqual("15-percent", discount.coupon.id)
    XCTAssertEqual(.repeating(months: 12), discount.coupon.duration)
  }

  func testDecodingPaymentIntentJson() throws {
    let jsonString = """
      {
        "id": "pi_3JkDUdD0Nyli3dRg1caHB2LB",
        "object": "payment_intent",
        "last_payment_error": null,
        "livemode": false,
        "next_action": null,
        "status": "requires_payment_method",
        "amount": 16800,
        "amount_capturable": 0,
        "amount_received": 0,
        "application": null,
        "application_fee_amount": null,
        "canceled_at": null,
        "cancellation_reason": null,
        "capture_method": "automatic",
        "charges": {
          "object": "list",
          "data": [
          ],
          "has_more": false,
          "total_count": 0,
          "url": "/v1/charges?payment_intent=pi_3JkDUdD0Nyli3dRg1caHB2LB"
        },
        "client_secret": "pi_3JkDUdD0Nyli3dRg1caHB2LB_secret_K4ufo7OpzkIiy0tN5U5z7FOMg",
        "confirmation_method": "automatic",
        "created": 1634154723,
        "currency": "usd",
        "customer": null,
        "description": "Gift subscription: 12 months",
        "invoice": null,
        "metadata": {
        },
        "on_behalf_of": null,
        "payment_method": null,
        "payment_method_options": {
          "card": {
            "installments": null,
            "network": null,
            "request_three_d_secure": "automatic"
          }
        },
        "payment_method_types": [
          "card"
        ],
        "receipt_email": "stephen.celis@gmail.com",
        "review": null,
        "setup_future_usage": null,
        "shipping": null,
        "source": null,
        "statement_descriptor": null,
        "statement_descriptor_suffix": "Gift Subscription",
        "transfer_data": null,
        "transfer_group": null
      }
      """

    _ = try Stripe.jsonDecoder.decode(PaymentIntent.self, from: Data(jsonString.utf8))
  }

  func testRequests() {
    // SnapshotTesting.isRecording = true
    assertSnapshot(
      matching: Stripe.cancelSubscription(id: "sub_test", immediately: false).rawValue,
      as: .raw,
      named: "cancel-subscription"
    )
    assertSnapshot(
      matching: Stripe.cancelSubscription(id: "sub_test", immediately: true).rawValue,
      as: .raw,
      named: "cancel-subscription-immediately"
    )
    assertSnapshot(
      matching: Stripe.createCoupon(
        duration: .once,
        maxRedemptions: 1,
        name: "3 Months of Point-Free",
        rate: .amountOff(54_00)
      )
      .rawValue,
      as: .raw,
      named: "create-coupon"
    )
    assertSnapshot(
      matching: Stripe.createCustomer(
        paymentMethodID: "pm_tok_test", description: "blob", email: "blob@pointfree.co",
        vatNumber: nil,
        balance: nil
      ).rawValue,
      as: .raw,
      named: "create-customer"
    )
    assertSnapshot(
      matching: Stripe.createCustomer(
        paymentMethodID: "pm_tok_test", description: "blob", email: "blob@pointfree.co",
        vatNumber: "1",
        balance: -18_00
      ).rawValue,
      as: .raw,
      named: "create-customer-vat"
    )
    assertSnapshot(
      matching:
        Stripe
        .createPaymentIntent(
          .init(
            amount: 54_00,
            currency: .usd,
            description: "3 Months of Point-Free",
            receiptEmail: "generous.blob@pointfree.co",
            statementDescriptorSuffix: "3 Months Gift"
          )
        )
        .rawValue,
      as: .raw,
      named: "create-payment-intent"
    )
    assertSnapshot(
      matching:
        Stripe
        .createSubscription(customer: "cus_test", plan: .yearly, quantity: 2, coupon: nil)
        .rawValue,
      as: .raw,
      named: "create-subscription"
    )
    assertSnapshot(
      matching:
        Stripe
        .createSubscription(customer: "cus_test", plan: .monthly, quantity: 1, coupon: "freebie")
        .rawValue,
      as: .raw,
      named: "create-subscription-coupon"
    )
    assertSnapshot(
      matching: Stripe.deleteCoupon(id: "deadbeef").rawValue,
      as: .raw,
      named: "delete-coupon"
    )
    assertSnapshot(
      matching: Stripe.fetchCoupon(id: "15-percent").rawValue,
      as: .raw,
      named: "fetch-coupon"
    )
    assertSnapshot(
      matching: Stripe.fetchCoupon(id: "give me free subscription").rawValue,
      as: .raw,
      named: "fetch-coupon-bad-data"
    )
    assertSnapshot(
      matching: Stripe.fetchCustomer(id: "cus_test").rawValue,
      as: .raw,
      named: "fetch-customer"
    )
    assertSnapshot(
      matching: Stripe.fetchInvoice(id: "in_test").rawValue,
      as: .raw,
      named: "fetch-invoice"
    )
    assertSnapshot(
      matching: Stripe.fetchInvoices(for: "cus_test").rawValue,
      as: .raw,
      named: "fetch-invoices"
    )
    assertSnapshot(
      matching: Stripe.fetchPaymentIntent(id: "pi_test").rawValue,
      as: .raw,
      named: "fetch-payment-intent"
    )
    assertSnapshot(
      matching: Stripe.fetchPlans().rawValue,
      as: .raw,
      named: "fetch-plans"
    )
    assertSnapshot(
      matching: Stripe.fetchPlan(id: .monthly).rawValue,
      as: .raw,
      named: "fetch-plan"
    )
    assertSnapshot(
      matching: Stripe.fetchSubscription(id: "sub_test").rawValue,
      as: .raw,
      named: "fetch-subscription"
    )
    assertSnapshot(
      matching: Stripe.fetchUpcomingInvoice("cus_test").rawValue,
      as: .raw,
      named: "fetch-upcoming-invoice"
    )
    assertSnapshot(
      matching: Stripe.invoiceCustomer("cus_test").rawValue,
      as: .raw,
      named: "invoice-customer"
    )
    assertSnapshot(
      matching: Stripe.updateCustomer(id: "cus_test", paymentMethodID: "pm_tok_test").rawValue,
      as: .raw,
      named: "update-customer"
    )
    assertSnapshot(
      matching: Stripe.updateSubscription(.mock, .yearly, 1)!.rawValue,
      as: .raw,
      named: "update-subscription"
    )
    assertSnapshot(
      matching: Stripe.updateSubscription(.discounted, .monthly, 1)!.rawValue,
      as: .raw,
      named: "update-subscription-discount-preserved"
    )
    assertSnapshot(
      matching: Stripe.updateSubscription(.discounted, .monthly, 2)!.rawValue,
      as: .raw,
      named: "update-subscription-discount-removed"
    )
  }
}
