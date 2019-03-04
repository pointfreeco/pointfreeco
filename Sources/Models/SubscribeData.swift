import Stripe

public struct SubscribeData: Codable, Equatable {
  public private(set) var coupon: Stripe.Coupon.Id?
  public private(set) var pricing: Pricing
  public private(set) var token: Stripe.Token.Id
  public private(set) var vatNumber: Stripe.Customer.Vat?
  
  public init(
    coupon: Stripe.Coupon.Id?,
    pricing: Pricing,
    token: Stripe.Token.Id,
    vatNumber: Stripe.Customer.Vat?) {
    self.coupon = coupon
    self.pricing = pricing
    self.token = token
    self.vatNumber = vatNumber
  }
}
