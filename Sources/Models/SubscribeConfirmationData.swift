import EmailAddress
import Stripe

public struct SubscribeConfirmationData: Equatable {
  public var billing: Pricing.Billing
  public var isOwnerTakingSeat: Bool
  public var plan: Pricing.Plan
  public var referralCode: User.ReferralCode?
  public var teammates: [EmailAddress]
  public var useRegionalDiscount: Bool

  public init(
    billing: Pricing.Billing,
    isOwnerTakingSeat: Bool,
    plan: Pricing.Plan,
    referralCode: User.ReferralCode?,
    teammates: [EmailAddress],
    useRegionalDiscount: Bool
  ) {
    self.billing = billing
    self.isOwnerTakingSeat = isOwnerTakingSeat
    self.plan = plan
    self.referralCode = referralCode
    self.teammates = teammates
    self.useRegionalDiscount = useRegionalDiscount
  }
}
