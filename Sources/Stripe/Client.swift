import DecodableRequest
import Dependencies
import DependenciesMacros
import Either
import EmailAddress
import Foundation
import FoundationPrelude
import Logging
import Prelude
import Tagged
import TaggedMoney
import UrlFormEncoding

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@DependencyClient
public struct Client {
  public var attachPaymentMethod:
    (
      _ methodID: PaymentMethod.ID,
      _ customerID: Customer.ID
    ) async throws -> PaymentMethod
  public var cancelSubscription:
    (
      _ id: Subscription.ID,
      _ immediately: Bool
    ) async throws -> Subscription
  public var confirmPaymentIntent: (_ id: PaymentIntent.ID) async throws -> PaymentIntent
  public var createCoupon:
    (
      _ duration: Coupon.Duration?,
      _ maxRedemptions: Int?,
      _ name: String?,
      _ rate: Coupon.Rate
    ) async throws -> Coupon
  public var createCustomer:
    (
      _ paymentMethodID: PaymentMethod.ID?,
      _ description: String?,
      _ emailAddress: EmailAddress?,
      _ vatNumber: Customer.Vat?,
      _ balance: Cents<Int>?
    ) async throws -> Customer
  public var createPaymentIntent:
    (
      _ amount: Cents<Int>,
      _ currency: Currency,
      _ description: String?,
      _ paymentMethodID: PaymentMethod.ID?,
      _ receiptEmail: String?,
      _ statementDescriptorSuffix: String?
    ) async throws -> PaymentIntent
  public var createSubscription:
    (
      _ customerID: Customer.ID,
      _ planID: Plan.ID,
      _ quantity: Int,
      _ coupon: Coupon.ID?
    ) async throws -> Subscription
  public var deleteCoupon: (_ id: Coupon.ID) async throws -> Void
  public var fetchCoupon: (_ id: Coupon.ID) async throws -> Coupon
  public var fetchCustomer: (_ id: Customer.ID) async throws -> Customer
  public var fetchCustomerPaymentMethods:
    (_ customerID: Customer.ID) async throws -> ListEnvelope<PaymentMethod>
  public var fetchInvoice: (_ id: Invoice.ID) async throws -> Invoice
  public var fetchInvoices:
    (_ customerID: Customer.ID, _ status: Invoice.Status) async throws -> ListEnvelope<Invoice>
  public var fetchPaymentIntent: (_ id: PaymentIntent.ID) async throws -> PaymentIntent
  public var fetchPaymentMethod: (_ id: PaymentMethod.ID) async throws -> PaymentMethod
  public var fetchPlans: () async throws -> ListEnvelope<Plan>
  public var fetchPlan: (_ id: Plan.ID) async throws -> Plan
  public var fetchSubscription: (_ id: Subscription.ID) async throws -> Subscription
  public var fetchUpcomingInvoice: (_ customerID: Customer.ID) async throws -> Invoice
  @DependencyEndpoint(method: "invoice")
  public var invoiceCustomer: (_ customerID: Customer.ID) async throws -> Invoice
  @DependencyEndpoint(method: "pay")
  public var payInvoice: (_ invoiceID: Invoice.ID) async throws -> Invoice
  public var updateCustomer:
    (_ customerID: Customer.ID, _ paymentMethodID: PaymentMethod.ID) async throws -> Customer
  public var updateCustomerBalance:
    (_ customerID: Customer.ID, _ amount: Cents<Int>) async throws -> Customer
  public var updateCustomerExtraInvoiceInfo:
    (_ customerID: Customer.ID, _ info: String) async throws -> Customer
  @DependencyEndpoint(method: "update")
  public var updateSubscription:
    (_ subscription: Subscription, _ planID: Plan.ID, _ quantity: Int) async throws -> Subscription
  public var js: String
}

extension Client {
  public typealias EndpointSecret = Tagged<(Self, endpointSecret: ()), String>
  public typealias PublishableKey = Tagged<(Self, publishableKey: ()), String>
  public typealias SecretKey = Tagged<(Self, secretKey: ()), String>

  public init(secretKey: SecretKey) {
    self.init(
      attachPaymentMethod: {
        try await runStripe(secretKey)(Stripe.attach(paymentMethod: $0, customer: $1))
      },
      cancelSubscription: {
        try await runStripe(secretKey)(Stripe.cancelSubscription(id: $0, immediately: $1))
      },
      confirmPaymentIntent: {
        try await runStripe(secretKey)(Stripe.confirmPaymentIntent(id: $0))
      },
      createCoupon: {
        try await runStripe(secretKey)(
          Stripe.createCoupon(duration: $0, maxRedemptions: $1, name: $2, rate: $3)
        )
      },
      createCustomer: {
        try await runStripe(secretKey)(
          Stripe.createCustomer(
            paymentMethodID: $0, description: $1, email: $2, vatNumber: $3, balance: $4
          )
        )
      },
      createPaymentIntent: {
        try await runStripe(secretKey)(
          Stripe.createPaymentIntent(
            amount: $0,
            currency: $1,
            description: $2,
            paymentMethodID: $3,
            receiptEmail: $4,
            statementDescriptorSuffix: $5
          )
        )
      },
      createSubscription: {
        try await runStripe(secretKey)(
          Stripe.createSubscription(customer: $0, plan: $1, quantity: $2, coupon: $3)
        )
      },
      deleteCoupon: {
        _ = try await runStripe(secretKey)(Stripe.deleteCoupon(id: $0))
      },
      fetchCoupon: {
        try await runStripe(secretKey)(Stripe.fetchCoupon(id: $0))
      },
      fetchCustomer: {
        try await runStripe(secretKey)(Stripe.fetchCustomer(id: $0))
      },
      fetchCustomerPaymentMethods: {
        try await runStripe(secretKey)(Stripe.fetchCustomerPaymentMethods(id: $0))
      },
      fetchInvoice: {
        try await runStripe(secretKey)(Stripe.fetchInvoice(id: $0))
      },
      fetchInvoices: {
        try await runStripe(secretKey)(Stripe.fetchInvoices(for: $0, status: $1))
      },
      fetchPaymentIntent: {
        try await runStripe(secretKey)(Stripe.fetchPaymentIntent(id: $0))
      },
      fetchPaymentMethod: {
        try await runStripe(secretKey)(Stripe.fetchPaymentMethod(id: $0))
      },
      fetchPlans: {
        try await runStripe(secretKey)(Stripe.fetchPlans())
      },
      fetchPlan: {
        try await runStripe(secretKey)(Stripe.fetchPlan(id: $0))
      },
      fetchSubscription: {
        try await runStripe(secretKey)(Stripe.fetchSubscription(id: $0))
      },
      fetchUpcomingInvoice: {
        try await runStripe(secretKey)(Stripe.fetchUpcomingInvoice($0))
      },
      invoiceCustomer: {
        try await runStripe(secretKey)(Stripe.invoiceCustomer($0))
      },
      payInvoice: {
        try await runStripe(secretKey)(Stripe.payInvoice($0))
      },
      updateCustomer: {
        try await runStripe(secretKey)(Stripe.updateCustomer(id: $0, paymentMethodID: $1))
      },
      updateCustomerBalance: {
        try await runStripe(secretKey)(Stripe.updateCustomer(id: $0, balance: $1))
      },
      updateCustomerExtraInvoiceInfo: {
        try await runStripe(secretKey)(
          Stripe.updateCustomer(id: $0, extraInvoiceInfo: $1)
        )
      },
      updateSubscription: {
        try await runStripe(secretKey)(
          Stripe.updateSubscription($0, $1, $2)
        )
      },
      js: "https://js.stripe.com/v3/"
    )
  }
}

func attach(paymentMethod: PaymentMethod.ID, customer: Customer.ID) -> DecodableRequest<
  PaymentMethod
> {
  stripeRequest(
    "payment_methods/" + paymentMethod.rawValue + "/attach",
    .post(["customer": customer])
  )
}

func cancelSubscription(id: Subscription.ID, immediately: Bool) -> DecodableRequest<Subscription> {
  if immediately {
    return stripeRequest(
      "subscriptions/" + id.rawValue + "?expand[]=customer.default_source",
      .delete([:])
    )
  } else {
    return stripeRequest(
      "subscriptions/" + id.rawValue + "?expand[]=customer.default_source",
      .post(["cancel_at_period_end": "true"])
    )
  }
}

func confirmPaymentIntent(
  id: PaymentIntent.ID
) -> DecodableRequest<PaymentIntent> {
  stripeRequest(
    "payment_intents/\(id.rawValue)/confirm",
    .post([:])
  )
}

func createCoupon(
  duration: Coupon.Duration?,
  maxRedemptions: Int?,
  name: String?,
  rate: Coupon.Rate
)
  -> DecodableRequest<Coupon>
{

  var params: [String: Any] = [:]

  switch duration {
  case .once:
    params["duration"] = "once"
  case .forever:
    params["duration"] = "forever"
  case let .repeating(months):
    params["duration"] = "repeating"
    params["duration_in_months"] = months
  case .none:
    break
  }

  if let maxRedemptions = maxRedemptions {
    params["max_redemptions"] = maxRedemptions
  }

  if let name = name {
    params["name"] = name
  }

  switch rate {
  case let .amountOff(cents):
    params["amount_off"] = cents
  case let .percentOff(percent):
    params["percent_off"] = percent
  }

  return stripeRequest("coupons", .post(params))
}

func createCustomer(
  paymentMethodID: PaymentMethod.ID?,
  description: String?,
  email: EmailAddress?,
  vatNumber: Customer.Vat?,
  balance: Cents<Int>?
)
  -> DecodableRequest<Customer>
{
  var params: [String: Any] = [:]
  params["balance"] = balance?.map(String.init).rawValue
  params["business_vat_id"] = vatNumber?.rawValue
  params["description"] = description
  params["email"] = email?.rawValue
  if let paymentMethodID = paymentMethodID {
    params["payment_method"] = paymentMethodID
    params["invoice_settings"] = ["default_payment_method": paymentMethodID]
  }
  return stripeRequest("customers", .post(params))
}

func createPaymentIntent(
  amount: Cents<Int>,
  currency: Currency,
  description: String?,
  paymentMethodID: PaymentMethod.ID? = nil,
  receiptEmail: String?,
  statementDescriptorSuffix: String?
)
  -> DecodableRequest<PaymentIntent>
{

  stripeRequest(
    "payment_intents",
    .post(
      [
        "amount": amount.rawValue,
        "currency": currency,
        "description": description as Any?,
        "payment_method": paymentMethodID?.rawValue as Any?,
        "receipt_email": receiptEmail,
        "statement_descriptor_suffix": statementDescriptorSuffix,
      ].compactMapValues { $0 }
    )
  )
}

func createSubscription(
  customer: Customer.ID,
  plan: Plan.ID,
  quantity: Int,
  coupon: Coupon.ID?
)
  -> DecodableRequest<Subscription>
{

  var params: [String: Any] = [:]
  params["customer"] = customer.rawValue
  params["items[0][plan]"] = plan.rawValue
  params["items[0][quantity]"] = String(quantity)
  params["coupon"] = coupon?.rawValue

  return stripeRequest(
    "subscriptions?expand[]=customer.default_source&expand[]=latest_invoice.payment_intent",
    .post(params)
  )
}

func deleteCoupon(id: Coupon.ID) -> DecodableRequest<Prelude.Unit> {
  stripeRequest(
    "coupons/" + (id.rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""),
    .delete([:])
  )
}

func fetchCoupon(id: Coupon.ID) -> DecodableRequest<Coupon> {
  stripeRequest(
    "coupons/" + (id.rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
  )
}

func fetchCustomer(id: Customer.ID) -> DecodableRequest<Customer> {
  stripeRequest("customers/" + id.rawValue)
}

func fetchCustomerPaymentMethods(id: Customer.ID) -> DecodableRequest<ListEnvelope<PaymentMethod>> {
  stripeRequest("customers/" + id.rawValue + "/payment_methods")
}

func fetchInvoice(id: Invoice.ID) -> DecodableRequest<Invoice> {
  stripeRequest("invoices/" + id.rawValue + "?expand[]=charge")
}

func fetchInvoices(
  for customer: Customer.ID, status: Invoice.Status
) -> DecodableRequest<ListEnvelope<Invoice>> {
  stripeRequest(
    "invoices?customer="
      + customer.rawValue
      + "&expand[]=data.charge&limit=100&status="
      + status.rawValue
  )
}

func fetchPaymentIntent(id: PaymentIntent.ID) -> DecodableRequest<PaymentIntent> {
  stripeRequest("payment_intents/" + id.rawValue)
}

func fetchPaymentMethod(id: PaymentMethod.ID) -> DecodableRequest<PaymentMethod> {
  stripeRequest("payment_methods/" + id.rawValue)
}

func fetchPlans() -> DecodableRequest<ListEnvelope<Plan>> {
  stripeRequest("plans")
}

func fetchPlan(id: Plan.ID) -> DecodableRequest<Plan> {
  stripeRequest("plans/" + id.rawValue)
}

func fetchSubscription(id: Subscription.ID) -> DecodableRequest<Subscription> {
  stripeRequest(
    "subscriptions/"
      + id.rawValue
      + "?expand[]=customer.default_source"
  )
}

func fetchUpcomingInvoice(_ customer: Customer.ID) -> DecodableRequest<Invoice> {
  stripeRequest("invoices/upcoming?customer=" + customer.rawValue + "&expand[]=charge")
}

func invoiceCustomer(_ customer: Customer.ID)
  -> DecodableRequest<Invoice>
{

  stripeRequest(
    "invoices",
    .post([
      "customer": customer.rawValue
    ]))
}

func payInvoice(_ invoice: Invoice.ID)
  -> DecodableRequest<Invoice>
{

  stripeRequest(
    "invoices/" + invoice.rawValue + "/pay",
    .post([:])
  )
}

func updateCustomer(id: Customer.ID, paymentMethodID: PaymentMethod.ID)
  -> DecodableRequest<Customer>
{

  stripeRequest(
    "customers/" + id.rawValue,
    .post([
      "invoice_settings": ["default_payment_method": paymentMethodID]
    ])
  )
}

func updateCustomer(id: Customer.ID, balance: Cents<Int>) -> DecodableRequest<Customer> {

  stripeRequest(
    "customers/" + id.rawValue,
    .post([
      "balance": balance.rawValue
    ]))
}

func updateCustomer(id: Customer.ID, extraInvoiceInfo: String) -> DecodableRequest<Customer> {

  stripeRequest(
    "customers/" + id.rawValue,
    .post([
      "metadata": ["extraInvoiceInfo": extraInvoiceInfo]
    ]))
}

func updateSubscription(
  _ currentSubscription: Subscription,
  _ plan: Plan.ID,
  _ quantity: Int
)
  -> DecodableRequest<Subscription>?
{

  guard let item = currentSubscription.items.data.first else { return nil }

  return stripeRequest(
    "subscriptions/" + currentSubscription.id.rawValue + "?expand[]=customer.default_source",
    .post(
      [
        "cancel_at_period_end": "false",
        "coupon": quantity > 1 ? "" : nil,
        "items[0][id]": item.id.rawValue,
        "items[0][plan]": plan.rawValue,
        "items[0][quantity]": String(quantity),
        "payment_behavior": "error_if_incomplete",
        "proration_behavior": "always_invoice",
      ]
      .compactMapValues { $0 }
    )
  )
}

public let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()

public let jsonEncoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .secondsSince1970
  encoder.keyEncodingStrategy = .convertToSnakeCase
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  return encoder
}()

func stripeRequest<A>(_ path: String, _ method: FoundationPrelude.Method = .get([:]))
  -> DecodableRequest<A>
{
  var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/" + path)!)
  request.setHeader(name: "Stripe-Version", value: "2020-08-27")
  request.attach(method: method)

  return DecodableRequest(rawValue: request)
}

private func runStripe<A>(_ secretKey: Client.SecretKey) -> (
  DecodableRequest<A>?
) async throws -> A {
  return { stripeRequest in
    guard
      var stripeRequest = stripeRequest?.rawValue
    else { throw StripeError(message: "Stripe request is nil.") }

    stripeRequest.attachBasicAuth(username: secretKey.rawValue)

    let task: EitherIO<Error, A> = pure(stripeRequest)
      .flatMap {
        dataTask(with: $0)
          .map { data, _ in data }
          .flatMap { data in
            EitherIO.wrap {
              do {
                return try jsonDecoder.decode(A.self, from: data)
              } catch {
                throw (try? jsonDecoder.decode(StripeErrorEnvelope.self, from: data))
                  ?? JSONError.error(String(decoding: data, as: UTF8.self), error) as Error
              }
            }
          }
      }

    return try await task.performAsync()
  }
}

extension Client: TestDependencyKey {
  public static let testValue = Client(js: "")
}

extension DependencyValues {
  public var stripe: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}
