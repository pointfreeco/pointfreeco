import Stripe

public struct SubscribeData: Codable, Equatable {
  public var coupon: Stripe.Coupon.Id?
  public var pricing: Pricing
  public var token: Stripe.Token.Id
  public var vatNumber: Stripe.Customer.Vat?
  
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
