import EmailAddress
import Stripe

public struct SubscribeData: Equatable {
  public var coupon: Stripe.Coupon.Id?
  public var isOwnerTakingSeat: Bool
  public var pricing: Pricing
  public var teammates: [EmailAddress]
  public var token: Stripe.Token.Id

  public init(
    coupon: Stripe.Coupon.Id?,
    isOwnerTakingSeat: Bool,
    pricing: Pricing,
    teammates: [EmailAddress],
    token: Stripe.Token.Id
  ) {
    self.coupon = coupon
    self.isOwnerTakingSeat = isOwnerTakingSeat
    self.pricing = pricing
    self.teammates = teammates
    self.token = token
  }

  public enum CodingKeys: String, CodingKey {
    case coupon
    case isOwnerTakingSeat
    case pricing
    case teammates
    case token
  }
}
