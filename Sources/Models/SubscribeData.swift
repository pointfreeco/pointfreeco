import PointFreePrelude
import Stripe

public struct SubscribeData: Equatable {
  public var coupon: Stripe.Coupon.Id?
  public var pricing: Pricing
  public var teammates: [EmailAddress]
  public var token: Stripe.Token.Id

  public init(
    coupon: Stripe.Coupon.Id?,
    pricing: Pricing,
    teammates: [EmailAddress],
    token: Stripe.Token.Id
  ) {
    self.coupon = coupon
    self.pricing = pricing
    self.teammates = teammates
    self.token = token
  }

  private enum CodingKeys: String, CodingKey {
    case coupon
    case pricing
    case teammates
    case token
  }
}
