import PointFreePrelude
import Stripe

public struct SubscribeData: Codable, Equatable {
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

  public init(decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.coupon = try container.decodeIfPresent(Stripe.Coupon.Id.self, forKey: .coupon)
    self.pricing = try container.decode(Pricing.self, forKey: .pricing)
    self.teammates = [] // try container.decodeIfPresent([EmailAddress].self, forKey: .teammates)
      ?? []
    self.token = try container.decode(Stripe.Token.Id.self, forKey: .token)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.coupon, forKey: .coupon)
    try container.encode(self.pricing, forKey: .pricing)
    try container.encodeIfPresent(self.teammates.isEmpty ? nil : self.teammates, forKey: .teammates)
    try container.encode(self.token, forKey: .token)
  }

  private enum CodingKeys: String, CodingKey {
    case coupon
    case pricing
    case teammates
    case token
  }
}
