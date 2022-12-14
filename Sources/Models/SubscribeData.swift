import EmailAddress
import Stripe

public struct SubscribeData: Equatable {
  public var coupon: Stripe.Coupon.ID?
  public var isOwnerTakingSeat: Bool
  public var paymentMethodID: PaymentMethod.ID
  public var pricing: Pricing
  public var referralCode: User.ReferralCode?
  public var teammates: [EmailAddress]
  public var useRegionalDiscount: Bool

  public init(
    coupon: Stripe.Coupon.ID?,
    isOwnerTakingSeat: Bool,
    paymentMethodID: PaymentMethod.ID,
    pricing: Pricing,
    referralCode: User.ReferralCode?,
    teammates: [EmailAddress],
    useRegionalDiscount: Bool
  ) {
    self.coupon = coupon
    self.isOwnerTakingSeat = isOwnerTakingSeat
    self.paymentMethodID = paymentMethodID
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
