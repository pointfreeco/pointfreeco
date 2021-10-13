import DecodableRequest
import Either
import EmailAddress
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import FoundationPrelude
import Logging
import Tagged
import TaggedMoney
import UrlFormEncoding

public struct Client {
  public var cancelSubscription: (Subscription.Id, _ immediately: Bool) -> EitherIO<Error, Subscription>
  public var createCoupon: (Coupon.Duration?, _ maxRedemptions: Int?, _ name: String?, Coupon.Rate) -> EitherIO<Error, Coupon>
  public var createCustomer: (Token.Id, String?, EmailAddress?, Customer.Vat?, Cents<Int>?) -> EitherIO<Error, Customer>
  public var createPaymentIntent: (CreatePaymentIntentRequest) -> EitherIO<Error, PaymentIntent>
  public var createSubscription: (Customer.Id, Plan.Id, Int, Coupon.Id?) -> EitherIO<Error, Subscription>
  public var fetchCoupon: (Coupon.Id) -> EitherIO<Error, Coupon>
  public var fetchCustomer: (Customer.Id) -> EitherIO<Error, Customer>
  public var fetchInvoice: (Invoice.Id) -> EitherIO<Error, Invoice>
  public var fetchInvoices: (Customer.Id) -> EitherIO<Error, ListEnvelope<Invoice>>
  public var fetchPlans: () -> EitherIO<Error, ListEnvelope<Plan>>
  public var fetchPlan: (Plan.Id) -> EitherIO<Error, Plan>
  public var fetchSubscription: (Subscription.Id) -> EitherIO<Error, Subscription>
  public var fetchUpcomingInvoice: (Customer.Id) -> EitherIO<Error, Invoice>
  public var invoiceCustomer: (Customer.Id) -> EitherIO<Error, Invoice>
  public var updateCustomer: (Customer.Id, Token.Id) -> EitherIO<Error, Customer>
  public var updateCustomerBalance: (Customer.Id, Cents<Int>) -> EitherIO<Error, Customer>
  public var updateCustomerExtraInvoiceInfo: (Customer.Id, String) -> EitherIO<Error, Customer>
  public var updateSubscription: (Subscription, Plan.Id, Int) -> EitherIO<Error, Subscription>
  public var js: String

  public init(
    cancelSubscription: @escaping (Subscription.Id, _ immediately: Bool) -> EitherIO<Error, Subscription>,
    createCoupon: @escaping (Coupon.Duration?, _ maxRedemptions: Int?, _ name: String?, Coupon.Rate) -> EitherIO<Error, Coupon>,
    createCustomer: @escaping (Token.Id, String?, EmailAddress?, Customer.Vat?, Cents<Int>?) -> EitherIO<Error, Customer>,
    createPaymentIntent: @escaping (CreatePaymentIntentRequest) -> EitherIO<Error, PaymentIntent>,
    createSubscription: @escaping (Customer.Id, Plan.Id, Int, Coupon.Id?) -> EitherIO<Error, Subscription>,
    fetchCoupon: @escaping (Coupon.Id) -> EitherIO<Error, Coupon>,
    fetchCustomer: @escaping (Customer.Id) -> EitherIO<Error, Customer>,
    fetchInvoice: @escaping (Invoice.Id) -> EitherIO<Error, Invoice>,
    fetchInvoices: @escaping (Customer.Id) -> EitherIO<Error, ListEnvelope<Invoice>>,
    fetchPlans: @escaping () -> EitherIO<Error, ListEnvelope<Plan>>,
    fetchPlan: @escaping (Plan.Id) -> EitherIO<Error, Plan>,
    fetchSubscription: @escaping (Subscription.Id) -> EitherIO<Error, Subscription>,
    fetchUpcomingInvoice: @escaping (Customer.Id) -> EitherIO<Error, Invoice>,
    invoiceCustomer: @escaping (Customer.Id) -> EitherIO<Error, Invoice>,
    updateCustomer: @escaping (Customer.Id, Token.Id) -> EitherIO<Error, Customer>,
    updateCustomerBalance: @escaping (Customer.Id, Cents<Int>) -> EitherIO<Error, Customer>,
    updateCustomerExtraInvoiceInfo: @escaping (Customer.Id, String) -> EitherIO<Error, Customer>,
    updateSubscription: @escaping (Subscription, Plan.Id, Int) -> EitherIO<Error, Subscription>,
    js: String
  ) {
    self.cancelSubscription = cancelSubscription
    self.createCoupon = createCoupon
    self.createCustomer = createCustomer
    self.createPaymentIntent = createPaymentIntent
    self.createSubscription = createSubscription
    self.fetchCoupon = fetchCoupon
    self.fetchCustomer = fetchCustomer
    self.fetchInvoice = fetchInvoice
    self.fetchInvoices = fetchInvoices
    self.fetchPlans = fetchPlans
    self.fetchPlan = fetchPlan
    self.fetchSubscription = fetchSubscription
    self.fetchUpcomingInvoice = fetchUpcomingInvoice
    self.invoiceCustomer = invoiceCustomer
    self.updateCustomer = updateCustomer
    self.updateCustomerBalance = updateCustomerBalance
    self.updateCustomerExtraInvoiceInfo = updateCustomerExtraInvoiceInfo
    self.updateSubscription = updateSubscription
    self.js = js
  }

  public struct CreatePaymentIntentRequest {
    public var amount: Cents<Int>
    public var currency: Currency
    public var description: String?
    public var receiptEmail: String?
    public var statementDescriptorSuffix: String?

    public init(
      amount: Cents<Int>,
      currency: Currency,
      description: String?,
      receiptEmail: String?,
      statementDescriptorSuffix: String?
    ) {
      self.amount = amount
      self.currency = currency
      self.description = description
      self.receiptEmail = receiptEmail
      self.statementDescriptorSuffix = statementDescriptorSuffix
    }
  }
}

extension Client {
  public typealias EndpointSecret = Tagged<(Client, endpointSecret: ()), String>
  public typealias PublishableKey = Tagged<(Client, publishableKey: ()), String>
  public typealias SecretKey = Tagged<(Client, secretKey: ()), String>

  public init(logger: Logger?, secretKey: SecretKey) {
    self.init(
      cancelSubscription: {
        runStripe(secretKey, logger)(Stripe.cancelSubscription(id: $0, immediately: $1))
      },
      createCoupon: {
        runStripe(secretKey, logger)(
          Stripe.createCoupon(duration: $0, maxRedemptions: $1, name: $2, rate: $3)
        )
      },
      createCustomer: {
        runStripe(secretKey, logger)(
          Stripe.createCustomer(token: $0, description: $1, email: $2, vatNumber: $3, balance: $4)
        )
      },
      createPaymentIntent: {
        runStripe(secretKey, logger)(
          Stripe.createPaymentIntent($0)
        )
      },
      createSubscription: {
        runStripe(secretKey, logger)(
          Stripe.createSubscription(customer: $0, plan: $1, quantity: $2, coupon: $3)
        )
      },
      fetchCoupon: { runStripe(secretKey, logger)(Stripe.fetchCoupon(id: $0)) },
      fetchCustomer: { runStripe(secretKey, logger)(Stripe.fetchCustomer(id: $0)) },
      fetchInvoice: { runStripe(secretKey, logger)(Stripe.fetchInvoice(id: $0)) },
      fetchInvoices: { runStripe(secretKey, logger)(Stripe.fetchInvoices(for: $0)) },
      fetchPlans: { runStripe(secretKey, logger)(Stripe.fetchPlans()) },
      fetchPlan: { runStripe(secretKey, logger)(Stripe.fetchPlan(id: $0)) },
      fetchSubscription: { runStripe(secretKey, logger)(Stripe.fetchSubscription(id: $0)) },
      fetchUpcomingInvoice: { runStripe(secretKey, logger)(Stripe.fetchUpcomingInvoice($0)) },
      invoiceCustomer: { runStripe(secretKey, logger)(Stripe.invoiceCustomer($0)) },
      updateCustomer: { runStripe(secretKey, logger)(Stripe.updateCustomer(id: $0, token: $1)) },
      updateCustomerBalance: { runStripe(secretKey, logger)(Stripe.updateCustomer(id: $0, balance: $1)) },
      updateCustomerExtraInvoiceInfo: {
        runStripe(secretKey, logger)(
          Stripe.updateCustomer(id: $0, extraInvoiceInfo: $1)
        )
      },
      updateSubscription: {
        runStripe(secretKey, logger)(
          Stripe.updateSubscription($0, $1, $2)
        )
      },
      js: "https://js.stripe.com/v3/"
    )
  }
}

func cancelSubscription(id: Subscription.Id, immediately: Bool) -> DecodableRequest<Subscription> {
  if immediately {
    return stripeRequest(
      "subscriptions/" + id.rawValue + "?expand[]=customer",
      .delete([:])
    )
  } else {
    return stripeRequest(
      "subscriptions/" + id.rawValue + "?expand[]=customer",
      .post(["cancel_at_period_end": "true"])
    )
  }
}

func createCoupon(
  duration: Coupon.Duration?,
  maxRedemptions: Int?,
  name: String?,
  rate: Coupon.Rate
)
-> DecodableRequest<Coupon> {

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
  token: Token.Id,
  description: String?,
  email: EmailAddress?,
  vatNumber: Customer.Vat?,
  balance: Cents<Int>?
)
-> DecodableRequest<Customer> {

  stripeRequest(
    "customers",
    .post(
      [
        "balance": balance?.map(String.init).rawValue,
        "business_vat_id": vatNumber?.rawValue,
        "description": description,
        "email": email?.rawValue,
        "source": token.rawValue,
      ]
        .compactMapValues { $0 }
    )
  )
}

func createPaymentIntent(_ request: Client.CreatePaymentIntentRequest)
-> DecodableRequest<PaymentIntent> {

  stripeRequest("payment_intents", .post([
    "amount": request.amount.rawValue,
    "currency": request.currency,
    "description": request.description as Any?,
    "receipt_email": request.receiptEmail,
    "statement_descriptor_suffix": request.statementDescriptorSuffix,
  ].compactMapValues { $0 }))
}

func createSubscription(
  customer: Customer.Id,
  plan: Plan.Id,
  quantity: Int,
  coupon: Coupon.Id?
)
-> DecodableRequest<Subscription> {

  var params: [String: Any] = [:]
  params["customer"] = customer.rawValue
  params["items[0][plan]"] = plan.rawValue
  params["items[0][quantity]"] = String(quantity)
  params["coupon"] = coupon?.rawValue

  return stripeRequest("subscriptions?expand[]=customer", .post(params))
}

func fetchCoupon(id: Coupon.Id) -> DecodableRequest<Coupon> {
  stripeRequest(
    "coupons/" + (id.rawValue.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")
  )
}

func fetchCustomer(id: Customer.Id) -> DecodableRequest<Customer> {
  stripeRequest("customers/" + id.rawValue)
}

func fetchInvoice(id: Invoice.Id) -> DecodableRequest<Invoice> {
  stripeRequest("invoices/" + id.rawValue + "?expand[]=charge")
}

func fetchInvoices(for customer: Customer.Id) -> DecodableRequest<ListEnvelope<Invoice>> {
  stripeRequest("invoices?customer=" + customer.rawValue + "&expand[]=data.charge&limit=100&status=paid")
}

func fetchPlans() -> DecodableRequest<ListEnvelope<Plan>> {
  stripeRequest("plans")
}

func fetchPlan(id: Plan.Id) -> DecodableRequest<Plan> {
  stripeRequest("plans/" + id.rawValue)
}

func fetchSubscription(id: Subscription.Id) -> DecodableRequest<Subscription> {
  stripeRequest("subscriptions/" + id.rawValue + "?expand[]=customer.sources")
}

func fetchUpcomingInvoice(_ customer: Customer.Id) -> DecodableRequest<Invoice> {
  stripeRequest("invoices/upcoming?customer=" + customer.rawValue + "&expand[]=charge")
}

func invoiceCustomer(_ customer: Customer.Id)
-> DecodableRequest<Invoice> {

  stripeRequest("invoices", .post([
    "customer": customer.rawValue,
  ]))
}

func updateCustomer(id: Customer.Id, token: Token.Id)
-> DecodableRequest<Customer> {

  stripeRequest("customers/" + id.rawValue, .post([
    "source": token.rawValue,
  ]))
}

func updateCustomer(id: Customer.Id, balance: Cents<Int>) -> DecodableRequest<Customer> {

  stripeRequest("customers/" + id.rawValue, .post([
    "balance": balance.rawValue,
  ]))
}

func updateCustomer(id: Customer.Id, extraInvoiceInfo: String) -> DecodableRequest<Customer> {

  stripeRequest("customers/" + id.rawValue, .post([
    "metadata": ["extraInvoiceInfo": extraInvoiceInfo],
  ]))
}

func updateSubscription(
  _ currentSubscription: Subscription,
  _ plan: Plan.Id,
  _ quantity: Int
)
-> DecodableRequest<Subscription>? {

  guard let item = currentSubscription.items.data.first else { return nil }

  return stripeRequest(
    "subscriptions/" + currentSubscription.id.rawValue + "?expand[]=customer",
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
  return encoder
}()

func stripeRequest<A>(_ path: String, _ method: FoundationPrelude.Method = .get([:])) -> DecodableRequest<A> {
  var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/" + path)!)
  request.setHeader(name: "Stripe-Version", value: "2020-08-27")
  request.attach(method: method)

  return DecodableRequest(rawValue: request)
}

private func runStripe<A>(_ secretKey: Client.SecretKey, _ logger: Logger?) -> (DecodableRequest<A>?) -> EitherIO<Error, A> {
  return { stripeRequest in
    guard
      var stripeRequest = stripeRequest?.rawValue
    else { return throwE(StripeError(message: "Stripe request is nil.")) }

    stripeRequest.attachBasicAuth(username: secretKey.rawValue)

    let task: EitherIO<Error, A> = pure(stripeRequest)
      .flatMap {
        dataTask(with: $0, logger: logger)
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

    return task
  }
}
