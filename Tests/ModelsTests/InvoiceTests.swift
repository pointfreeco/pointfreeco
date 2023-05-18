import Foundation
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import Models
@testable import Stripe

@MainActor
final class InvoiceTests: TestCase {
  func testDecoding() async throws {
    _ = try Stripe.jsonDecoder.decode(ListEnvelope<Invoice>.self, from: Data(invoicesJSON.utf8))
  }

  func testSub() throws {
    let json = """
{
  "id": "sub_1N8niGD0Nyli3dRg8Owy7R3j",
  "object": "subscription",
  "application": null,
  "application_fee_percent": null,
  "automatic_tax": {
    "enabled": false
  },
  "billing_cycle_anchor": 1684342832,
  "billing_thresholds": null,
  "cancel_at": null,
  "cancel_at_period_end": false,
  "canceled_at": null,
  "cancellation_details": {
    "comment": null,
    "feedback": null,
    "reason": null
  },
  "collection_method": "charge_automatically",
  "created": 1684342832,
  "currency": "usd",
  "current_period_end": 1715965232,
  "current_period_start": 1684342832,
  "customer": {
    "id": "cus_Nucy2iJeyGusvd",
    "object": "customer",
    "address": null,
    "balance": 0,
    "created": 1684342831,
    "currency": "usd",
    "default_currency": "usd",
    "default_source": {
      "id": "src_1N91LfD0Nyli3dRgUhSVe0i8",
      "object": "source",
      "amount": null,
      "card": {
        "address_line1_check": null,
        "address_zip_check": null,
        "brand": "MasterCard",
        "country": "PL",
        "cvc_check": "unavailable",
        "dynamic_last4": null,
        "exp_month": 3,
        "exp_year": 2026,
        "fingerprint": "v5FhMBk4ghf0wRhc",
        "funding": "debit",
        "last4": "7472",
        "name": null,
        "three_d_secure": "optional",
        "tokenization_method": null
      },
      "client_secret": "src_client_secret_gFO8DoosACWxKp5fioWKp1Jr",
      "created": 1684395247,
      "currency": null,
      "customer": "cus_Nucy2iJeyGusvd",
      "flow": "none",
      "livemode": true,
      "metadata": {},
      "owner": {
        "address": null,
        "email": null,
        "name": null,
        "phone": null,
        "verified_address": null,
        "verified_email": null,
        "verified_name": null,
        "verified_phone": null
      },
      "statement_descriptor": null,
      "status": "chargeable",
      "type": "card",
      "usage": "reusable"
    },
    "delinquent": false,
    "description": "34A2347E-EF15-11ED-AF58-CF2B6076599C",
    "discount": null,
    "email": "pawelmichalak@icloud.com",
    "invoice_prefix": "0E3F127F",
    "invoice_settings": {
      "custom_fields": null,
      "default_payment_method": "pm_1N8nk0D0Nyli3dRgO3u0yMyh",
      "footer": null,
      "rendering_options": null
    },
    "livemode": true,
    "metadata": {},
    "name": null,
    "next_invoice_sequence": 2,
    "phone": null,
    "preferred_locales": [],
    "shipping": null,
    "tax_exempt": "none",
    "test_clock": null
  },
  "days_until_due": null,
  "default_payment_method": null,
  "default_source": null,
  "default_tax_rates": [],
  "description": null,
  "discount": null,
  "ended_at": null,
  "items": {
    "object": "list",
    "data": [
      {
        "id": "si_NucyDlcN3mti6h",
        "object": "subscription_item",
        "billing_thresholds": null,
        "created": 1684342832,
        "metadata": {},
        "plan": {
          "id": "yearly-2019",
          "object": "plan",
          "active": true,
          "aggregate_usage": null,
          "amount": null,
          "amount_decimal": null,
          "billing_scheme": "tiered",
          "created": 1566052279,
          "currency": "usd",
          "interval": "year",
          "interval_count": 1,
          "livemode": true,
          "metadata": {},
          "nickname": "Point-Free Yearly",
          "product": "prod_FdkPPCkrt1F1P2",
          "tiers_mode": "volume",
          "transform_usage": null,
          "trial_period_days": null,
          "usage_type": "licensed"
        },
        "price": {
          "id": "yearly-2019",
          "object": "price",
          "active": true,
          "billing_scheme": "tiered",
          "created": 1566052279,
          "currency": "usd",
          "custom_unit_amount": null,
          "livemode": true,
          "lookup_key": null,
          "metadata": {},
          "nickname": "Point-Free Yearly",
          "product": "prod_FdkPPCkrt1F1P2",
          "recurring": {
            "aggregate_usage": null,
            "interval": "year",
            "interval_count": 1,
            "trial_period_days": null,
            "usage_type": "licensed"
          },
          "tax_behavior": "unspecified",
          "tiers_mode": "volume",
          "transform_quantity": null,
          "type": "recurring",
          "unit_amount": null,
          "unit_amount_decimal": null
        },
        "quantity": 1,
        "subscription": "sub_1N8niGD0Nyli3dRg8Owy7R3j",
        "tax_rates": []
      }
    ],
    "has_more": false,
    "total_count": 1,
    "url": "/v1/subscription_items?subscription=sub_1N8niGD0Nyli3dRg8Owy7R3j"
  },
  "latest_invoice": "in_1N8niGD0Nyli3dRgBmhtMHu9",
  "livemode": true,
  "metadata": {},
  "next_pending_invoice_item_invoice": null,
  "on_behalf_of": null,
  "pause_collection": null,
  "payment_settings": {
    "payment_method_options": null,
    "payment_method_types": null,
    "save_default_payment_method": "off"
  },
  "pending_invoice_item_interval": null,
  "pending_setup_intent": null,
  "pending_update": null,
  "plan": {
    "id": "yearly-2019",
    "object": "plan",
    "active": true,
    "aggregate_usage": null,
    "amount": null,
    "amount_decimal": null,
    "billing_scheme": "tiered",
    "created": 1566052279,
    "currency": "usd",
    "interval": "year",
    "interval_count": 1,
    "livemode": true,
    "metadata": {},
    "nickname": "Point-Free Yearly",
    "product": "prod_FdkPPCkrt1F1P2",
    "tiers_mode": "volume",
    "transform_usage": null,
    "trial_period_days": null,
    "usage_type": "licensed"
  },
  "quantity": 1,
  "schedule": null,
  "start_date": 1684342832,
  "status": "active",
  "test_clock": null,
  "transfer_data": null,
  "trial_end": null,
  "trial_settings": {
    "end_behavior": {
      "missing_payment_method": "create_invoice"
    }
  },
  "trial_start": null
}
"""

    let subscription = try Stripe.jsonDecoder.decode(Stripe.Subscription.self, from: Data(json.utf8))
  }

  func testCustomer() throws {
    let json = """
{
    "id": "cus_Nucy2iJeyGusvd",
    "object": "customer",
    "address": null,
    "balance": 0,
    "created": 1684342831,
    "currency": "usd",
    "default_currency": "usd",
    "default_source": {
      "id": "src_1N91LfD0Nyli3dRgUhSVe0i8",
      "object": "source",
      "amount": null,
      "card": {
        "address_line1_check": null,
        "address_zip_check": null,
        "brand": "MasterCard",
        "country": "PL",
        "cvc_check": "unavailable",
        "dynamic_last4": null,
        "exp_month": 3,
        "exp_year": 2026,
        "fingerprint": "v5FhMBk4ghf0wRhc",
        "funding": "debit",
        "last4": "7472",
        "name": null,
        "three_d_secure": "optional",
        "tokenization_method": null
      },
      "client_secret": "src_client_secret_gFO8DoosACWxKp5fioWKp1Jr",
      "created": 1684395247,
      "currency": null,
      "customer": "cus_Nucy2iJeyGusvd",
      "flow": "none",
      "livemode": true,
      "metadata": {},
      "owner": {
        "address": null,
        "email": null,
        "name": null,
        "phone": null,
        "verified_address": null,
        "verified_email": null,
        "verified_name": null,
        "verified_phone": null
      },
      "statement_descriptor": null,
      "status": "chargeable",
      "type": "card",
      "usage": "reusable"
    },
    "delinquent": false,
    "description": "34A2347E-EF15-11ED-AF58-CF2B6076599C",
    "discount": null,
    "email": "pawelmichalak@icloud.com",
    "invoice_prefix": "0E3F127F",
    "invoice_settings": {
      "custom_fields": null,
      "default_payment_method": "pm_1N8nk0D0Nyli3dRgO3u0yMyh",
      "footer": null,
      "rendering_options": null
    },
    "livemode": true,
    "metadata": {},
    "name": null,
    "next_invoice_sequence": 2,
    "phone": null,
    "preferred_locales": [],
    "shipping": null,
    "tax_exempt": "none",
    "test_clock": null
  }
"""

    let customer = try Stripe.jsonDecoder.decode(Stripe.Customer.self, from: Data(json.utf8))
  }

  func testDefaultSource() throws {
    let json = """
{
      "id": "src_1N91LfD0Nyli3dRgUhSVe0i8",
      "object": "source",
      "amount": null,
      "card": {
        "address_line1_check": null,
        "address_zip_check": null,
        "brand": "MasterCard",
        "country": "PL",
        "cvc_check": "unavailable",
        "dynamic_last4": null,
        "exp_month": 3,
        "exp_year": 2026,
        "fingerprint": "v5FhMBk4ghf0wRhc",
        "funding": "debit",
        "last4": "7472",
        "name": null,
        "three_d_secure": "optional",
        "tokenization_method": null
      },
      "client_secret": "src_client_secret_gFO8DoosACWxKp5fioWKp1Jr",
      "created": 1684395247,
      "currency": null,
      "customer": "cus_Nucy2iJeyGusvd",
      "flow": "none",
      "livemode": true,
      "metadata": {},
      "owner": {
        "address": null,
        "email": null,
        "name": null,
        "phone": null,
        "verified_address": null,
        "verified_email": null,
        "verified_name": null,
        "verified_phone": null
      },
      "statement_descriptor": null,
      "status": "chargeable",
      "type": "card",
      "usage": "reusable"
    }
"""

    let source = try Stripe.jsonDecoder.decode(Stripe.Source.self, from: Data(json.utf8))
    let card = try Stripe.jsonDecoder.decode(Stripe.Card.self, from: Data(json.utf8))
  }

  func testCard() throws {
    let json = """
{
        "address_line1_check": null,
        "address_zip_check": null,
        "brand": "MasterCard",
        "country": "PL",
        "cvc_check": "unavailable",
        "dynamic_last4": null,
        "exp_month": 3,
        "exp_year": 2026,
        "fingerprint": "v5FhMBk4ghf0wRhc",
        "funding": "debit",
        "last4": "7472",
        "name": null,
        "three_d_secure": "optional",
        "tokenization_method": null
      }
"""
    let card = try Stripe.jsonDecoder.decode(Stripe.PaymentMethod.Card.self, from: Data(json.utf8))

  }
}

private let invoicesJSON = """
  {
    "object": "list",
    "data": [
      {
        "id": "in_1MF0FaD0Nyli3dRgsAUeulh9",
        "object": "invoice",
        "account_country": "US",
        "account_name": "Point-Free, Inc.",
        "account_tax_ids": null,
        "amount_due": 16800,
        "amount_paid": 16800,
        "amount_remaining": 0,
        "application": null,
        "application_fee_amount": null,
        "attempt_count": 1,
        "attempted": true,
        "auto_advance": false,
        "automatic_tax": {
          "enabled": false,
          "status": null
        },
        "billing_reason": "subscription_create",
        "charge": {
          "id": "ch_3MF0FaD0Nyli3dRg0EujgQgc",
          "object": "charge",
          "amount": 16800,
          "amount_captured": 16800,
          "amount_refunded": 0,
          "application": null,
          "application_fee": null,
          "application_fee_amount": null,
          "balance_transaction": "txn_3MF0FaD0Nyli3dRg0dUZt6HU",
          "billing_details": {
            "address": {
              "city": null,
              "country": null,
              "line1": null,
              "line2": null,
              "postal_code": null,
              "state": null
            },
            "email": null,
            "name": null,
            "phone": null
          },
          "calculated_statement_descriptor": "POINT-FREE, INC.",
          "captured": true,
          "created": 1671044659,
          "currency": "usd",
          "customer": "cus_MyyBypSA5QKwGg",
          "description": "Subscription creation",
          "destination": null,
          "dispute": null,
          "disputed": false,
          "failure_balance_transaction": null,
          "failure_code": null,
          "failure_message": null,
          "fraud_details": {},
          "invoice": "in_1MF0FaD0Nyli3dRgsAUeulh9",
          "livemode": false,
          "metadata": {},
          "on_behalf_of": null,
          "order": null,
          "outcome": {
            "network_status": "approved_by_network",
            "reason": null,
            "risk_level": "normal",
            "risk_score": 39,
            "seller_message": "Payment complete.",
            "type": "authorized"
          },
          "paid": true,
          "payment_intent": "pi_3MF0FaD0Nyli3dRg0U0tb6WC",
          "payment_method": "pm_1MF0FZD0Nyli3dRgO8IjsfRn",
          "payment_method_details": {
            "card": {
              "brand": "mastercard",
              "checks": {
                "address_line1_check": null,
                "address_postal_code_check": null,
                "cvc_check": null
              },
              "country": "US",
              "exp_month": 12,
              "exp_year": 2024,
              "fingerprint": "STJNdpIfwh9A2CYF",
              "funding": "credit",
              "installments": null,
              "last4": "8154",
              "mandate": null,
              "network": "mastercard",
              "three_d_secure": null,
              "wallet": {
                "apple_pay": {},
                "dynamic_last4": "8154",
                "type": "apple_pay"
              }
            },
            "type": "card"
          },
          "receipt_email": null,
          "receipt_number": null,
          "receipt_url": "https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xQjhzYXBEME55bGkzZFJnKNG96JwGMgZyr6i5vYg6LBYkO4JMalxRretak0Dke9-XCKt6QEZX8WgfSctU_H7-fEVbsnSSPPHWFGvZ?s=ap",
          "refunded": false,
          "refunds": {
            "object": "list",
            "data": [],
            "has_more": false,
            "total_count": 0,
            "url": "/v1/charges/ch_3MF0FaD0Nyli3dRg0EujgQgc/refunds"
          },
          "review": null,
          "shipping": null,
          "source": null,
          "source_transfer": null,
          "statement_descriptor": null,
          "statement_descriptor_suffix": null,
          "status": "succeeded",
          "transfer_data": null,
          "transfer_group": null
        },
        "collection_method": "charge_automatically",
        "created": 1671044658,
        "currency": "usd",
        "custom_fields": null,
        "customer": "cus_MyyBypSA5QKwGg",
        "customer_address": null,
        "customer_email": "mbrandonw@hey.com",
        "customer_name": null,
        "customer_phone": null,
        "customer_shipping": null,
        "customer_tax_exempt": "none",
        "customer_tax_ids": [],
        "default_payment_method": null,
        "default_source": null,
        "default_tax_rates": [],
        "description": null,
        "discount": null,
        "discounts": [],
        "due_date": null,
        "ending_balance": 0,
        "footer": null,
        "from_invoice": null,
        "hosted_invoice_url": "https://invoice.stripe.com/i/acct_1B8sapD0Nyli3dRg/test_YWNjdF8xQjhzYXBEME55bGkzZFJnLF9NeXlCZm82SHFqZklva255OWVGZExCeGx6M3Bub285LDYxNTg1NjE30200rCo02ajV?s=ap",
        "invoice_pdf": "https://pay.stripe.com/invoice/acct_1B8sapD0Nyli3dRg/test_YWNjdF8xQjhzYXBEME55bGkzZFJnLF9NeXlCZm82SHFqZklva255OWVGZExCeGx6M3Bub285LDYxNTg1NjE30200rCo02ajV/pdf?s=ap",
        "last_finalization_error": null,
        "latest_revision": null,
        "lines": {
          "object": "list",
          "data": [
            {
              "id": "il_1MF0FaD0Nyli3dRgL4k7kGf3",
              "object": "line_item",
              "amount": 16800,
              "amount_excluding_tax": 16800,
              "currency": "usd",
              "description": "1  Yearly (Tier 1 at $168.00 / year)",
              "discount_amounts": [],
              "discountable": true,
              "discounts": [],
              "livemode": false,
              "metadata": {},
              "period": {
                "end": 1702580658,
                "start": 1671044658
              },
              "plan": {
                "id": "yearly-2019",
                "object": "plan",
                "active": true,
                "aggregate_usage": null,
                "amount": null,
                "amount_decimal": null,
                "billing_scheme": "tiered",
                "created": 1566051019,
                "currency": "usd",
                "interval": "year",
                "interval_count": 1,
                "livemode": false,
                "metadata": {},
                "nickname": "Yearly (2019)",
                "product": "prod_Fd5LTyVMtum6UA",
                "tiers_mode": "volume",
                "transform_usage": null,
                "trial_period_days": null,
                "usage_type": "licensed"
              },
              "price": {
                "id": "yearly-2019",
                "object": "price",
                "active": true,
                "billing_scheme": "tiered",
                "created": 1566051019,
                "currency": "usd",
                "custom_unit_amount": null,
                "livemode": false,
                "lookup_key": null,
                "metadata": {},
                "nickname": "Yearly (2019)",
                "product": "prod_Fd5LTyVMtum6UA",
                "recurring": {
                  "aggregate_usage": null,
                  "interval": "year",
                  "interval_count": 1,
                  "trial_period_days": null,
                  "usage_type": "licensed"
                },
                "tax_behavior": "unspecified",
                "tiers_mode": "volume",
                "transform_quantity": null,
                "type": "recurring",
                "unit_amount": null,
                "unit_amount_decimal": null
              },
              "proration": false,
              "proration_details": {
                "credited_items": null
              },
              "quantity": 1,
              "subscription": "sub_1MF0FaD0Nyli3dRgBSWGUQBL",
              "subscription_item": "si_MyyBYs8Mf7E8EM",
              "tax_amounts": [],
              "tax_rates": [],
              "type": "subscription",
              "unit_amount_excluding_tax": "16800"
            }
          ],
          "has_more": false,
          "total_count": 1,
          "url": "/v1/invoices/in_1MF0FaD0Nyli3dRgsAUeulh9/lines"
        },
        "livemode": false,
        "metadata": {},
        "next_payment_attempt": null,
        "number": "9E9B0C01-0001",
        "on_behalf_of": null,
        "paid": true,
        "paid_out_of_band": false,
        "payment_intent": "pi_3MF0FaD0Nyli3dRg0U0tb6WC",
        "payment_settings": {
          "default_mandate": null,
          "payment_method_options": null,
          "payment_method_types": null
        },
        "period_end": 1671044658,
        "period_start": 1671044658,
        "post_payment_credit_notes_amount": 0,
        "pre_payment_credit_notes_amount": 0,
        "quote": null,
        "receipt_number": null,
        "rendering_options": null,
        "starting_balance": 0,
        "statement_descriptor": null,
        "status": "paid",
        "status_transitions": {
          "finalized_at": 1671044658,
          "marked_uncollectible_at": null,
          "paid_at": 1671044658,
          "voided_at": null
        },
        "subscription": "sub_1MF0FaD0Nyli3dRgBSWGUQBL",
        "subtotal": 16800,
        "subtotal_excluding_tax": 16800,
        "tax": null,
        "test_clock": null,
        "total": 16800,
        "total_discount_amounts": [],
        "total_excluding_tax": 16800,
        "total_tax_amounts": [],
        "transfer_data": null,
        "webhooks_delivered_at": 1671044658
      }
    ],
    "has_more": false,
    "url": "/v1/invoices"
  }
  """
