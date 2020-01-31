import EmailAddress
import PointFreePrelude
import Stripe

public struct SubscribeConfirmationData: Equatable {
  public var billing: Pricing.Billing
  public var isOwnerTakingSeat: Bool
  public var teammates: [EmailAddress]

  public init(
    billing: Pricing.Billing,
    isOwnerTakingSeat: Bool,
    teammates: [EmailAddress]
  ) {
    self.billing = billing
    self.isOwnerTakingSeat = isOwnerTakingSeat
    self.teammates = teammates
  }
}
