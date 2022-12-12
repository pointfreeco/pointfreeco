import EmailAddress
import Stripe

public struct SubscribeData: Codable, Equatable {
  public var coupon: Stripe.Coupon.Id?
  public var isOwnerTakingSeat: Bool
  public var paymentType: PaymentType
  public var pricing: Pricing
  public var referralCode: User.ReferralCode?
  public var teammates: [EmailAddress]
  public var useRegionalDiscount: Bool

  public enum PaymentType: Codable, Equatable {
    case paymentMethodID(PaymentMethod.ID)
    case token(Stripe.Token.Id)
  }

  @available(*, deprecated)
  public var token: Stripe.Token.Id? {
    guard case let .token(tokenID) = self.paymentType
    else { return nil }
    return tokenID
  }
  @available(*, deprecated)
  public var paymentMethodID: PaymentMethod.ID? {
    guard case let .paymentMethodID(paymentMethodID) = self.paymentType
    else { return nil }
    return paymentMethodID
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.coupon = try container.decodeIfPresent(Coupon.Id.self, forKey: .coupon)
    self.isOwnerTakingSeat = try container.decode(Bool.self, forKey: .isOwnerTakingSeat)
    self.pricing = try container.decode(Pricing.self, forKey: .pricing)
    self.referralCode = try container.decodeIfPresent(User.ReferralCode.self, forKey: .referralCode)
    self.teammates = try container.decode([EmailAddress].self, forKey: .teammates)
    self.useRegionalDiscount = try container.decode(Bool.self, forKey: .useRegionalDiscount)

    do {
      self.paymentType = try .paymentMethodID(container.decode(PaymentMethod.ID.self, forKey: .paymentMethodID))
    } catch {
      self.paymentType = try .token(container.decode(Stripe.Token.Id.self, forKey: .token))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(self.coupon, forKey: .coupon)
    try container.encode(self.isOwnerTakingSeat, forKey: .isOwnerTakingSeat)
    try container.encode(self.pricing, forKey: .pricing)
    try container.encodeIfPresent(self.referralCode, forKey: .referralCode)
    try container.encode(self.teammates, forKey: .teammates)
    try container.encode(self.useRegionalDiscount, forKey: .useRegionalDiscount)
    switch self.paymentType {
    case let .paymentMethodID(paymentMethodID):
      try container.encode(paymentMethodID, forKey: .paymentMethodID)
    case let .token(token):
      try container.encode(token, forKey: .token)
    }
  }

  public init(
    coupon: Stripe.Coupon.Id?,
    isOwnerTakingSeat: Bool,
    paymentType: PaymentType,
    pricing: Pricing,
    referralCode: User.ReferralCode?,
    teammates: [EmailAddress],
    useRegionalDiscount: Bool
  ) {
    self.coupon = coupon
    self.isOwnerTakingSeat = isOwnerTakingSeat
    self.paymentType = paymentType
    self.pricing = pricing
    self.referralCode = referralCode
    self.teammates = teammates
    self.useRegionalDiscount = useRegionalDiscount
  }

  public enum CodingKeys: String, CodingKey {
    case coupon
    case isOwnerTakingSeat
    case paymentMethodID
    case pricing
    case referralCode = "ref"
    case teammates
    case token
    case useRegionalDiscount
  }
}
