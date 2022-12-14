import DecodableRequest
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

public struct Client {
  public var attachPaymentMethod: (PaymentMethod.ID, Customer.ID) -> EitherIO<Error, PaymentMethod>
  public var cancelSubscription:
    (Subscription.ID, _ immediately: Bool) -> EitherIO<Error, Subscription>
  public var confirmPaymentIntent: (PaymentIntent.ID) -> EitherIO<Error, PaymentIntent>
  public var createCoupon:
    (Coupon.Duration?, _ maxRedemptions: Int?, _ name: String?, Coupon.Rate) -> EitherIO<
      Error, Coupon
    >
  public var createCustomer:
    (PaymentMethod.ID?, String?, EmailAddress?, Customer.Vat?, Cents<Int>?) -> EitherIO<Error, Customer>
  public var createPaymentIntent: (CreatePaymentIntentRequest) -> EitherIO<Error, PaymentIntent>
  public var createSubscription:
    (Customer.ID, Plan.ID, Int, Coupon.ID?) -> EitherIO<Error, Subscription>
  public var deleteCoupon: (Coupon.ID) -> EitherIO<Error, Prelude.Unit>
  public var fetchCoupon: (Coupon.ID) -> EitherIO<Error, Coupon>
  public var fetchCustomer: (Customer.ID) -> EitherIO<Error, Customer>
  public var fetchCustomerPaymentMethods: (Customer.ID) -> EitherIO<Error, ListEnvelope<PaymentMethod>>
  public var fetchInvoice: (Invoice.ID) -> EitherIO<Error, Invoice>
  public var fetchInvoices: (Customer.ID) -> EitherIO<Error, ListEnvelope<Invoice>>
  public var fetchPaymentIntent: (PaymentIntent.ID) -> EitherIO<Error, PaymentIntent>
  public var fetchPaymentMethod: (PaymentMethod.ID) -> EitherIO<Error, PaymentMethod>
  public var fetchPlans: () -> EitherIO<Error, ListEnvelope<Plan>>
  public var fetchPlan: (Plan.ID) -> EitherIO<Error, Plan>
  public var fetchSubscription: (Subscription.ID) -> EitherIO<Error, Subscription>
  public var fetchUpcomingInvoice: (Customer.ID) -> EitherIO<Error, Invoice>
  public var invoiceCustomer: (Customer.ID) -> EitherIO<Error, Invoice>
  public var updateCustomer: (Customer.ID, PaymentMethod.ID) -> EitherIO<Error, Customer>
  public var updateCustomerBalance: (Customer.ID, Cents<Int>) -> EitherIO<Error, Customer>
  public var updateCustomerExtraInvoiceInfo: (Customer.ID, String) -> EitherIO<Error, Customer>
  public var updateSubscription: (Subscription, Plan.ID, Int) -> EitherIO<Error, Subscription>
  public var js: String

  public init(
    attachPaymentMethod: @escaping (PaymentMethod.ID, Customer.ID) -> EitherIO<Error, PaymentMethod>,
    cancelSubscription: @escaping (Subscription.ID, _ immediately: Bool) -> EitherIO<
      Error, Subscription
    >,
    confirmPaymentIntent: @escaping (PaymentIntent.ID) -> EitherIO<Error, PaymentIntent>,
    createCoupon: @escaping (Coupon.Duration?, _ maxRedemptions: Int?, _ name: String?, Coupon.Rate)
      -> EitherIO<Error, Coupon>,
    createCustomer: @escaping (PaymentMethod.ID?, String?, EmailAddress?, Customer.Vat?, Cents<Int>?) ->
      EitherIO<Error, Customer>,
    createPaymentIntent: @escaping (CreatePaymentIntentRequest) -> EitherIO<Error, PaymentIntent>,
    createSubscription: @escaping (Customer.ID, Plan.ID, Int, Coupon.ID?) -> EitherIO<
      Error, Subscription
    >,
    deleteCoupon: @escaping (Coupon.ID) -> EitherIO<Error, Prelude.Unit>,
    fetchCoupon: @escaping (Coupon.ID) -> EitherIO<Error, Coupon>,
    fetchCustomer: @escaping (Customer.ID) -> EitherIO<Error, Customer>,
    fetchCustomerPaymentMethods: @escaping (Customer.ID) -> EitherIO<Error, ListEnvelope<PaymentMethod>>,
    fetchInvoice: @escaping (Invoice.ID) -> EitherIO<Error, Invoice>,
    fetchInvoices: @escaping (Customer.ID) -> EitherIO<Error, ListEnvelope<Invoice>>,
    fetchPaymentIntent: @escaping (PaymentIntent.ID) -> EitherIO<Error, PaymentIntent>,
    fetchPaymentMethod: @escaping (PaymentMethod.ID) -> EitherIO<Error, PaymentMethod>,
    fetchPlans: @escaping () -> EitherIO<Error, ListEnvelope<Plan>>,
    fetchPlan: @escaping (Plan.ID) -> EitherIO<Error, Plan>,
    fetchSubscription: @escaping (Subscription.ID) -> EitherIO<Error, Subscription>,
    fetchUpcomingInvoice: @escaping (Customer.ID) -> EitherIO<Error, Invoice>,
    invoiceCustomer: @escaping (Customer.ID) -> EitherIO<Error, Invoice>,
    updateCustomer: @escaping (Customer.ID, PaymentMethod.ID) -> EitherIO<Error, Customer>,
    updateCustomerBalance: @escaping (Customer.ID, Cents<Int>) -> EitherIO<Error, Customer>,
    updateCustomerExtraInvoiceInfo: @escaping (Customer.ID, String) -> EitherIO<Error, Customer>,
    updateSubscription: @escaping (Subscription, Plan.ID, Int) -> EitherIO<Error, Subscription>,
    js: String
  ) {
    self.attachPaymentMethod = attachPaymentMethod
    self.cancelSubscription = cancelSubscription
    self.confirmPaymentIntent = confirmPaymentIntent
    self.createCoupon = createCoupon
    self.createCustomer = createCustomer
    self.createPaymentIntent = createPaymentIntent
    self.createSubscription = createSubscription
    self.deleteCoupon = deleteCoupon
    self.fetchCoupon = fetchCoupon
    self.fetchCustomer = fetchCustomer
    self.fetchCustomerPaymentMethods = fetchCustomerPaymentMethods
    self.fetchInvoice = fetchInvoice
    self.fetchInvoices = fetchInvoices
    self.fetchPaymentIntent = fetchPaymentIntent
    self.fetchPaymentMethod = fetchPaymentMethod
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
    public var paymentMethodID: PaymentMethod.ID?
    public var receiptEmail: String?
    public var statementDescriptorSuffix: String?

    public init(
      amount: Cents<Int>,
      currency: Currency,
      description: String?,
      paymentMethodID: PaymentMethod.ID? = nil,
      receiptEmail: String?,
      statementDescriptorSuffix: String?
    ) {
      self.amount = amount
      self.currency = currency
      self.description = description
      self.paymentMethodID = paymentMethodID
      self.receiptEmail = receiptEmail
      self.statementDescriptorSuffix = statementDescriptorSuffix
    }
  }
}

extension Client {
  public typealias EndpointSecret = Tagged<(Self, endpointSecret: ()), String>
  public typealias PublishableKey = Tagged<(Self, publishableKey: ()), String>
  public typealias SecretKey = Tagged<(Self, secretKey: ()), String>

  public init(logger: Logger?, secretKey: SecretKey) {
    self.init(
      attachPaymentMethod: {
        runStripe(secretKey, logger)(Stripe.attach(paymentMethod: $0, customer: $1))
      },
      cancelSubscription: {
        runStripe(secretKey, logger)(Stripe.cancelSubscription(id: $0, immediately: $1))
      },
      confirmPaymentIntent: {
        runStripe(secretKey, logger)(
          Stripe.confirmPaymentIntent(id: $0)
        )
      },
      createCoupon: {
        runStripe(secretKey, logger)(
          Stripe.createCoupon(duration: $0, maxRedemptions: $1, name: $2, rate: $3)
        )
      },
      createCustomer: {
        runStripe(secretKey, logger)(
          Stripe.createCustomer(paymentMethodID: $0, description: $1, email: $2, vatNumber: $3, balance: $4)
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
      deleteCoupon: { runStripe(secretKey, logger)(Stripe.deleteCoupon(id: $0)) },
      fetchCoupon: { runStripe(secretKey, logger)(Stripe.fetchCoupon(id: $0)) },
      fetchCustomer: { runStripe(secretKey, logger)(Stripe.fetchCustomer(id: $0)) },
      fetchCustomerPaymentMethods: { runStripe(secretKey, logger)(Stripe.fetchCustomerPaymentMethods(id: $0)) },
      fetchInvoice: { runStripe(secretKey, logger)(Stripe.fetchInvoice(id: $0)) },
      fetchInvoices: { runStripe(secretKey, logger)(Stripe.fetchInvoices(for: $0)) },
      fetchPaymentIntent: { runStripe(secretKey, logger)(Stripe.fetchPaymentIntent(id: $0)) },
      fetchPaymentMethod: { runStripe(secretKey, logger)(Stripe.fetchPaymentMethod(id: $0)) },
      fetchPlans: { runStripe(secretKey, logger)(Stripe.fetchPlans()) },
      fetchPlan: { runStripe(secretKey, logger)(Stripe.fetchPlan(id: $0)) },
      fetchSubscription: { runStripe(secretKey, logger)(Stripe.fetchSubscription(id: $0)) },
      fetchUpcomingInvoice: { runStripe(secretKey, logger)(Stripe.fetchUpcomingInvoice($0)) },
      invoiceCustomer: { runStripe(secretKey, logger)(Stripe.invoiceCustomer($0)) },
      updateCustomer: { runStripe(secretKey, logger)(Stripe.updateCustomer(id: $0, paymentMethodID: $1)) },
      updateCustomerBalance: {
        runStripe(secretKey, logger)(Stripe.updateCustomer(id: $0, balance: $1))
      },
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

func attach(paymentMethod: PaymentMethod.ID, customer: Customer.ID) -> DecodableRequest<PaymentMethod> {
  stripeRequest(
    "payment_methods/" + paymentMethod.rawValue + "/attach",
    .post(["customer": customer])
  )
}

func cancelSubscription(id: Subscription.ID, immediately: Bool) -> DecodableRequest<Subscription> {
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
  if let paymentMethodID {
    params["payment_method"] = paymentMethodID
    params["invoice_settings"] = ["default_payment_method": paymentMethodID]
  }
  return stripeRequest(
    "customers?expand[]=sources",
    .post(params)
  )
}
 
func createPaymentIntent(_ request: Client.CreatePaymentIntentRequest)
  -> DecodableRequest<PaymentIntent>
{

  stripeRequest(
    "payment_intents",
    .post(
      [
        "amount": request.amount.rawValue,
        "currency": request.currency,
        "description": request.description as Any?,
        "payment_method": request.paymentMethodID?.rawValue as Any?,
        "receipt_email": request.receiptEmail,
        "statement_descriptor_suffix": request.statementDescriptorSuffix,
      ].compactMapValues { $0 }))
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

  return stripeRequest("subscriptions?expand[]=customer", .post(params))
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

func fetchInvoices(for customer: Customer.ID) -> DecodableRequest<ListEnvelope<Invoice>> {
  stripeRequest(
    "invoices?customer=" + customer.rawValue + "&expand[]=data.charge&limit=100&status=paid")
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
  stripeRequest("subscriptions/" + id.rawValue + "?expand[]=customer")
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

private func runStripe<A>(_ secretKey: Client.SecretKey, _ logger: Logger?) -> (
  DecodableRequest<A>?
) -> EitherIO<Error, A> {
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
