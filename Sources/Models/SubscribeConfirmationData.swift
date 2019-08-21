import PointFreePrelude
import Stripe

public struct SubscribeConfirmationData: Equatable {
  public var billing: Pricing.Billing
  public var teammates: [EmailAddress]

  public init(
    billing: Pricing.Billing,
    teammates: [EmailAddress]
  ) {
    self.billing = billing
    self.teammates = teammates
  }
}
