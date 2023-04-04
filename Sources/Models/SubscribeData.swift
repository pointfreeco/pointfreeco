import EmailAddress
import Stripe

public struct SubscribeData: Equatable {
  public var coupon: Coupon.ID?
  public var isOwnerTakingSeat: Bool
  public var paymentMethodID: PaymentMethod.ID
  public var pricing: Pricing
  public var referralCode: User.ReferralCode?
  public var subscriptionID: Stripe.Subscription.ID?
  public var teammates: [EmailAddress]
  public var useRegionalDiscount: Bool

  public init(
    coupon: Coupon.ID?,
    isOwnerTakingSeat: Bool,
    paymentMethodID: PaymentMethod.ID,
    pricing: Pricing,
    referralCode: User.ReferralCode?,
    subscriptionID: Stripe.Subscription.ID?,
    teammates: [EmailAddress],
    useRegionalDiscount: Bool
  ) {
    self.coupon = coupon
    self.isOwnerTakingSeat = isOwnerTakingSeat
    self.paymentMethodID = paymentMethodID
    self.pricing = pricing
    self.referralCode = referralCode
    self.subscriptionID = subscriptionID
    self.teammates = teammates
    self.useRegionalDiscount = useRegionalDiscount
  }

  public enum CodingKeys: String, CodingKey {
    case coupon
    case isOwnerTakingSeat
    case paymentMethodID
    case pricing
    case referralCode = "ref"
    case subscriptionID
    case teammates
    case useRegionalDiscount
  }
}
