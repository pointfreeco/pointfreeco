import Either
import Foundation
import Logger
import Optics
import Prelude
import PointFreePrelude
import Tagged
import UrlFormEncoding

public struct Client {
  public var cancelSubscription: (Subscription.Id) -> EitherIO<Error, Subscription>
  public var createCustomer: (Token.Id, String?, EmailAddress?, Customer.Vat?) -> EitherIO<Error, Customer>
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
  public var updateCustomerExtraInvoiceInfo: (Customer.Id, String) -> EitherIO<Error, Customer>
  public var updateSubscription: (Subscription, Plan.Id, Int, Bool?) -> EitherIO<Error, Subscription>
  public var js: String

  public init(
    cancelSubscription: @escaping (Subscription.Id) -> EitherIO<Error, Subscription>,
    createCustomer: @escaping (Token.Id, String?, EmailAddress?, Customer.Vat?) -> EitherIO<Error, Customer>,
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
    updateCustomerExtraInvoiceInfo: @escaping (Customer.Id, String) -> EitherIO<Error, Customer>,
    updateSubscription: @escaping (Subscription, Plan.Id, Int, Bool?) -> EitherIO<Error, Subscription>,
    js: String
    ) {
    self.cancelSubscription = cancelSubscription
    self.createCustomer = createCustomer
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
    self.updateCustomerExtraInvoiceInfo = updateCustomerExtraInvoiceInfo
    self.updateSubscription = updateSubscription
    self.js = js
  }
}

extension Client {
  public typealias EndpointSecret = Tagged<(Client, endpointSecret: ()), String>
  public typealias PublishableKey = Tagged<(Client, publishableKey: ()), String>
  public typealias SecretKey = Tagged<(Client, secretKey: ()), String>

  public init(logger: Logger?, secretKey: SecretKey) {
    self.init(
      cancelSubscription: Stripe.cancelSubscription >>> runStripe(secretKey, logger),
      createCustomer: { Stripe.createCustomer(token: $0, description: $1, email: $2, vatNumber: $3) |> runStripe(secretKey, logger) },
      createSubscription: { Stripe.createSubscription(customer: $0, plan: $1, quantity: $2, coupon: $3) |> runStripe(secretKey, logger) },
      fetchCoupon: Stripe.fetchCoupon >>> runStripe(secretKey, logger),
      fetchCustomer: Stripe.fetchCustomer >>> runStripe(secretKey, logger),
      fetchInvoice: Stripe.fetchInvoice >>> runStripe(secretKey, logger),
      fetchInvoices: Stripe.fetchInvoices >>> runStripe(secretKey, logger),
      fetchPlans: { Stripe.fetchPlans() |> runStripe(secretKey, logger) },
      fetchPlan: Stripe.fetchPlan >>> runStripe(secretKey, logger),
      fetchSubscription: Stripe.fetchSubscription >>> runStripe(secretKey, logger),
      fetchUpcomingInvoice: Stripe.fetchUpcomingInvoice >>> runStripe(secretKey, logger),
      invoiceCustomer: Stripe.invoiceCustomer >>> runStripe(secretKey, logger),
      updateCustomer: { Stripe.updateCustomer(id: $0, token: $1) |> runStripe(secretKey, logger) },
      updateCustomerExtraInvoiceInfo: { Stripe.updateCustomer(id: $0, extraInvoiceInfo: $1) |> runStripe(secretKey, logger) },
      updateSubscription: { Stripe.updateSubscription($0, $1, $2, $3) |> runStripe(secretKey, logger) },
      js: "https://js.stripe.com/v3/"
    )
  }
}

func cancelSubscription(id: Subscription.Id) -> DecodableRequest<Subscription> {
  return stripeRequest(
    "subscriptions/" + id.rawValue + "?expand[]=customer", .delete(["at_period_end": "true"])
  )
}

func createCustomer(
  token: Token.Id,
  description: String?,
  email: EmailAddress?,
  vatNumber: Customer.Vat?
  )
  -> DecodableRequest<Customer> {

    return stripeRequest("customers", .post(filteredValues <| [
      "business_vat_id": vatNumber?.rawValue,
      "description": description,
      "email": email?.rawValue,
      "source": token.rawValue,
      ]))
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
  return stripeRequest("coupons/" + id.rawValue)
}

func fetchCustomer(id: Customer.Id) -> DecodableRequest<Customer> {
  return stripeRequest("customers/" + id.rawValue)
}

func fetchInvoice(id: Invoice.Id) -> DecodableRequest<Invoice> {
  return stripeRequest("invoices/" + id.rawValue + "?expand[]=charge")
}

func fetchInvoices(for customer: Customer.Id) -> DecodableRequest<ListEnvelope<Invoice>> {
  return stripeRequest("invoices?customer=" + customer.rawValue + "&expand[]=data.charge&limit=100")
}

func fetchPlans() -> DecodableRequest<ListEnvelope<Plan>> {
  return stripeRequest("plans")
}

func fetchPlan(id: Plan.Id) -> DecodableRequest<Plan> {
  return stripeRequest("plans/" + id.rawValue)
}

func fetchSubscription(id: Subscription.Id) -> DecodableRequest<Subscription> {
  return stripeRequest("subscriptions/" + id.rawValue + "?expand[]=customer")
}

func fetchUpcomingInvoice(_ customer: Customer.Id) -> DecodableRequest<Invoice> {
  return stripeRequest("invoices/upcoming?customer=" + customer.rawValue + "&expand[]=charge")
}

func invoiceCustomer(_ customer: Customer.Id)
  -> DecodableRequest<Invoice> {

    return stripeRequest("invoices", .post([
      "customer": customer.rawValue,
      ]))
}

func updateCustomer(id: Customer.Id, token: Token.Id)
  -> DecodableRequest<Customer> {

    return stripeRequest("customers/" + id.rawValue, .post([
      "source": token.rawValue,
      ]))
}

func updateCustomer(id: Customer.Id, extraInvoiceInfo: String) -> DecodableRequest<Customer> {

  return stripeRequest("customers/" + id.rawValue, .post([
    "metadata": ["extraInvoiceInfo": extraInvoiceInfo],
    ]))
}

func updateSubscription(
  _ currentSubscription: Subscription,
  _ plan: Plan.Id,
  _ quantity: Int,
  _ prorate: Bool?
  )
  -> DecodableRequest<Subscription>? {

    guard let item = currentSubscription.items.data.first else { return nil }

    return stripeRequest("subscriptions/" + currentSubscription.id.rawValue + "?expand[]=customer", .post(filteredValues <| [
      "coupon": "",
      "items[0][id]": item.id.rawValue,
      "items[0][plan]": plan.rawValue,
      "items[0][quantity]": String(quantity),
      "prorate": prorate.map(String.init(describing:)),
      ]))
}

public let jsonDecoder = JSONDecoder()
  |> \.dateDecodingStrategy .~ .secondsSince1970
//  |> \.keyDecodingStrategy .~ .convertFromSnakeCase

public let jsonEncoder = JSONEncoder()
  |> \.dateEncodingStrategy .~ .secondsSince1970
//  |> \.keyEncodingStrategy .~ .convertToSnakeCase

enum Method {
  case get
  case post([String: Any])
  case delete([String: String])
}

private func attachMethod(_ method: Method) -> (URLRequest) -> URLRequest {
  switch method {
  case .get:
    return \.httpMethod .~ "GET"
  case let .post(params):
    return (\.httpMethod .~ "POST")
      <> attachFormData(params)
  case let .delete(params):
    return (\.httpMethod .~ "DELETE")
      <> attachFormData(params)
  }
}

func stripeRequest<A>(_ path: String, _ method: Method = .get) -> DecodableRequest<A> {
  return DecodableRequest(
    rawValue: URLRequest(url: URL(string: "https://api.stripe.com/v1/" + path)!)
      |> attachMethod(method)
  )
}

private func runStripe<A>(_ secretKey: Client.SecretKey, _ logger: Logger?) -> (DecodableRequest<A>?) -> EitherIO<Error, A> {
  return { stripeRequest in
    guard
      let stripeRequest = stripeRequest?.map(attachBasicAuth(username: secretKey.rawValue))
      else { return throwE(unit) }

    let task: EitherIO<Error, A> = pure(stripeRequest.rawValue)
      .flatMap {
        dataTask(with: $0, logger: logger)
          .map(first)
          .flatMap { data in
            .wrap {
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
