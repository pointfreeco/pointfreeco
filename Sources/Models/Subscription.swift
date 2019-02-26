import Foundation
import Stripe
import Tagged

public struct Subscription: Decodable {
  public var id: Id
  public var stripeSubscriptionId: Stripe.Subscription.Id
  public var stripeSubscriptionStatus: Stripe.Subscription.Status
  public var userId: User.Id

  public typealias Id = Tagged<Subscription, UUID>

  private enum CodingKeys: String, CodingKey {
    case id
    case stripeSubscriptionId = "stripe_subscription_id"
    case stripeSubscriptionStatus = "stripe_subscription_status"
    case userId = "user_id"
  }
}
