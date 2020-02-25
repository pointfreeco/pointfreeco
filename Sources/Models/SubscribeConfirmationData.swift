import EmailAddress
import Stripe

public struct SubscribeConfirmationData: Equatable {
  public var billing: Pricing.Billing
  public var isOwnerTakingSeat: Bool
  public var referralCode: User.ReferralCode?
  public var teammates: [EmailAddress]

  public init(
    billing: Pricing.Billing,
    isOwnerTakingSeat: Bool,
    referralCode: User.ReferralCode?,
    teammates: [EmailAddress]
  ) {
    self.billing = billing
    self.isOwnerTakingSeat = isOwnerTakingSeat
    self.referralCode = referralCode
    self.teammates = teammates
  }
}
