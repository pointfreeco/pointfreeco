import Either
import Html
import HttpPipeline
@testable import PointFree
import Optics
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

final class StripeTests: TestCase {

  func testDecodingCustomer() throws {
    let jsonString = """
{
  "id": "cus_D5ERuFUxGA3Rsy",
  "object": "customer",
  "account_balance": 0,
  "created": 1529492122,
  "currency": "usd",
  "default_source": null,
  "delinquent": false,
  "description": null,
  "discount": null,
  "email": null,
  "invoice_prefix": "E2EC1F7",
  "livemode": false,
  "metadata": {
  },
  "shipping": null,
  "sources": {
    "object": "list",
    "data": [

    ],
    "has_more": false,
    "total_count": 0,
    "url": "/v1/customers/cus_D5ERuFUxGA3Rsy/sources"
  },
  "subscriptions": {
    "object": "list",
    "data": [

    ],
    "has_more": false,
    "total_count": 0,
    "url": "/v1/customers/cus_D5ERuFUxGA3Rsy/subscriptions"
  }
}
"""

    let customer = try JSONDecoder().decode(Stripe.Customer.self, from: Data(jsonString.utf8))

    XCTAssertEqual(nil, customer.businessVatId)
    XCTAssertEqual(nil, customer.defaultSource)
    XCTAssertEqual("cus_D5ERuFUxGA3Rsy", customer.id)
    XCTAssertEqual([:], customer.metadata)
    XCTAssertEqual(Stripe.ListEnvelope<Stripe.Card>(data: [], hasMore: false), customer.sources)
  }

  func testDecodingCustomer_Metadata() throws {
    let jsonString = """
{
  "id": "cus_D5ERuFUxGA3Rsy",
  "object": "customer",
  "account_balance": 0,
  "created": 1529492122,
  "currency": "usd",
  "default_source": null,
  "delinquent": false,
  "description": null,
  "discount": null,
  "email": null,
  "invoice_prefix": "E2EC1F7",
  "livemode": false,
  "metadata": {
    "extraInvoiceInfo": "VAT: 123456789"
  },
  "shipping": null,
  "sources": {
    "object": "list",
    "data": [

    ],
    "has_more": false,
    "total_count": 0,
    "url": "/v1/customers/cus_D5ERuFUxGA3Rsy/sources"
  },
  "subscriptions": {
    "object": "list",
    "data": [

    ],
    "has_more": false,
    "total_count": 0,
    "url": "/v1/customers/cus_D5ERuFUxGA3Rsy/subscriptions"
  }
}
"""

    let customer = try JSONDecoder().decode(Stripe.Customer.self, from: Data(jsonString.utf8))

    XCTAssertEqual(nil, customer.businessVatId)
    XCTAssertEqual(nil, customer.defaultSource)
    XCTAssertEqual("cus_D5ERuFUxGA3Rsy", customer.id)
    XCTAssertEqual(["extraInvoiceInfo": "VAT: 123456789"], customer.metadata)
    XCTAssertEqual("VAT: 123456789", customer.extraInvoiceInfo)
    XCTAssertEqual(Stripe.ListEnvelope<Stripe.Card>(data: [], hasMore: false), customer.sources)
  }

  func testDecodingSubscriptionWithDiscount() throws {
    let jsonString = """
{
  "id": "sub_DLOCPKtT3ezRQ7",
  "object": "subscription",
  "application_fee_percent": null,
  "billing": "charge_automatically",
  "billing_cycle_anchor": 1533218660,
  "cancel_at_period_end": false,
  "canceled_at": null,
  "created": 1533218660,
  "current_period_end": 1535897060,
  "current_period_start": 1533218660,
  "customer": "cus_DLOB6Ix7b7Xu83",
  "days_until_due": null,
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
    "customer": "cus_DLOB6Ix7b7Xu83",
    "end": null,
    "start": 1533218660,
    "subscription": "sub_DLOCPKtT3ezRQ7"
  },
  "ended_at": null,
  "items": {
    "object": "list",
    "data": [
      {
        "id": "si_DLOCbdDWbIZn1f",
        "object": "subscription_item",
        "created": 1533218660,
        "metadata": {
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
          "name": "Individual Monthly",
          "nickname": null,
          "product": "prod_BzH9x8QMPSEtMQ",
          "statement_descriptor": null,
          "tiers": null,
          "tiers_mode": null,
          "transform_usage": null,
          "trial_period_days": null,
          "usage_type": "licensed"
        },
        "quantity": 1,
        "subscription": "sub_DLOCPKtT3ezRQ7"
      }
    ],
    "has_more": false,
    "total_count": 1,
    "url": "/v1/subscription_items?subscription=sub_DLOCPKtT3ezRQ7"
  },
  "livemode": false,
  "metadata": {
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
    "name": "Individual Monthly",
    "nickname": null,
    "product": "prod_BzH9x8QMPSEtMQ",
    "statement_descriptor": null,
    "tiers": null,
    "tiers_mode": null,
    "transform_usage": null,
    "trial_period_days": null,
    "usage_type": "licensed"
  },
  "quantity": 1,
  "start": 1533218660,
  "status": "active",
  "tax_percent": null,
  "trial_end": null,
  "trial_start": null
}
"""

    let subscription = try JSONDecoder().decode(Stripe.Subscription.self, from: Data(jsonString.utf8))

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

    let discount = try JSONDecoder().decode(Stripe.Discount.self, from: Data(jsonString.utf8))

    XCTAssertEqual("15-percent", discount.coupon.id)
    XCTAssertEqual(.repeating(months: 12), discount.coupon.duration)
  }

  func testRequests() {
    assertSnapshot(
      matching: PointFree.cancelSubscription(id: "sub_test").rawValue,
      as: .raw,
      named: "cancel-subscription"
    )
    assertSnapshot(
      matching: PointFree.createCustomer(user: .mock, token: "tok_test", vatNumber: nil).rawValue,
      as: .raw,
      named: "create-customer"
    )
    assertSnapshot(
      matching: PointFree.createCustomer(user: .mock, token: "tok_test", vatNumber: "1").rawValue,
      as: .raw,
      named: "create-customer-vat"
    )
    assertSnapshot(
      matching: PointFree
        .createSubscription(customer: "cus_test", plan: .teamYearly, quantity: 2, coupon: nil)
        .rawValue,
      as: .raw,
      named: "create-subscription"
    )
    assertSnapshot(
      matching: PointFree
        .createSubscription(customer: "cus_test", plan: .individualMonthly, quantity: 1, coupon: "freebie")
        .rawValue,
      as: .raw,
      named: "create-subscription-coupon"
    )
    assertSnapshot(
      matching: PointFree.fetchCoupon(id: "15-percent").rawValue,
      as: .raw,
      named: "fetch-coupon"
    )
    assertSnapshot(
      matching: PointFree.fetchCustomer(id: "cus_test").rawValue,
      as: .raw,
      named: "fetch-customer"
    )
    assertSnapshot(
      matching: PointFree.fetchInvoice(id: "in_test").rawValue,
      as: .raw,
      named: "fetch-invoice"
    )
    assertSnapshot(
      matching: PointFree.fetchInvoices(for: "cus_test").rawValue,
      as: .raw,
      named: "fetch-invoices"
    )
    assertSnapshot(
      matching: PointFree.fetchPlans().rawValue,
      as: .raw,
      named: "fetch-plans"
    )
    assertSnapshot(
      matching: PointFree.fetchPlan(id: .individualMonthly).rawValue,
      as: .raw,
      named: "fetch-plan"
    )
    assertSnapshot(
      matching: PointFree.fetchSubscription(id: "sub_test").rawValue,
      as: .raw,
      named: "fetch-subscription"
    )
    assertSnapshot(
      matching: PointFree.fetchUpcomingInvoice("cus_test").rawValue,
      as: .raw,
      named: "fetch-upcoming-invoice"
    )
    assertSnapshot(
      matching: PointFree.invoiceCustomer("cus_test").rawValue,
      as: .raw,
      named: "invoice-customer"
    )
    assertSnapshot(
      matching: PointFree.updateCustomer(id: "cus_test", token: "tok_test").rawValue,
      as: .raw,
      named: "update-customer"
    )
    assertSnapshot(
      matching: PointFree.updateSubscription(.mock, .individualYearly, 1, nil)!.rawValue,
      as: .raw,
      named: "update-subscription"
    )
  }
}
