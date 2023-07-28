import Foundation
import Stripe
import Tagged

public struct Subscription: Decodable, Identifiable {
  public var deactivated: Bool
  public var id: Tagged<Self, UUID>
  public var stripeSubscriptionId: Stripe.Subscription.ID
  public var stripeSubscriptionStatus: Stripe.Subscription.Status
  public var teamInviteCode: TeamInviteCode
  public var userId: User.ID

  public init(
    deactivated: Bool,
    id: ID,
    stripeSubscriptionId: Stripe.Subscription.ID,
    stripeSubscriptionStatus: Stripe.Subscription.Status,
    teamInviteCode: TeamInviteCode,
    userId: User.ID
  ) {
    self.deactivated = deactivated
    self.id = id
    self.stripeSubscriptionId = stripeSubscriptionId
    self.stripeSubscriptionStatus = stripeSubscriptionStatus
    self.teamInviteCode = teamInviteCode
    self.userId = userId
  }

  public typealias TeamInviteCode = Tagged<(Self, teamInviteCode: ()), String>
}

extension Tagged where Tag == (Subscription, teamInviteCode: ()), RawValue == String {
  public var isDomain: Bool {
    self.rawValue.contains(".")
  }
}
