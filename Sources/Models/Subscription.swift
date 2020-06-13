import Foundation
import Stripe
import Tagged

public struct Subscription: Decodable {
  public var deactivated: Bool
  public var id: Id
  public var stripeSubscriptionId: Stripe.Subscription.Id
  public var stripeSubscriptionStatus: Stripe.Subscription.Status
  public var teamInviteCode: TeamInviteCode
  public var userId: User.Id

  public init(
    deactivated: Bool,
    id: Id,
    stripeSubscriptionId: Stripe.Subscription.Id,
    stripeSubscriptionStatus: Stripe.Subscription.Status,
    teamInviteCode: TeamInviteCode,
    userId: User.Id
  ) {
    self.deactivated = deactivated
    self.id = id
    self.stripeSubscriptionId = stripeSubscriptionId
    self.stripeSubscriptionStatus = stripeSubscriptionStatus
    self.teamInviteCode = teamInviteCode
    self.userId = userId
  }

  public typealias Id = Tagged<Subscription, UUID>
  public typealias TeamInviteCode = Tagged<(Subscription, teamInviteCode: ()), String>

  private enum CodingKeys: String, CodingKey {
    case deactivated
    case id
    case stripeSubscriptionId = "stripe_subscription_id"
    case stripeSubscriptionStatus = "stripe_subscription_status"
    case userId = "user_id"
    case teamInviteCode = "team_invite_code"
  }
}
