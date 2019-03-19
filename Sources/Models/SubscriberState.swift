import Stripe

public enum SubscriberState {
  case nonSubscriber
  case owner(hasSeat: Bool, status: Stripe.Subscription.Status)
  case teammate(status: Stripe.Subscription.Status)

  public init(user: User?, subscriptionAndEnterpriseAccount: (Models.Subscription, EnterpriseAccount?)?) {
    switch (user, subscriptionAndEnterpriseAccount) {
    case let (.some(user), .some((subscription, enterpriseAccount))):
      if subscription.userId == user.id {
        self = .owner(
          hasSeat: user.subscriptionId != nil,
          status: subscription.stripeSubscriptionStatus
        )
      } else {
        self = .teammate(status: subscription.stripeSubscriptionStatus)
      }

    case (.none, _), (.some, _):
      self = .nonSubscriber
    }
  }

  public var status: Stripe.Subscription.Status? {
    switch self {
    case .nonSubscriber:
      return nil
    case let .owner(_, status):
      return status
    case let .teammate(status):
      return status
    }
  }

  public var isActive: Bool {
    return self.status == .some(.active)
  }

  public var isPastDue: Bool {
    return self.status == .some(.pastDue)
  }

  public var isOwner: Bool {
    if case .owner = self { return true }
    return false
  }

  public var isTeammate: Bool {
    if case .teammate = self { return true }
    return false
  }

  public var isNonSubscriber: Bool {
    if case .nonSubscriber = self { return true }
    return false
  }

  public var isActiveSubscriber: Bool {
    if case .teammate(status: .active) = self { return true }
    if case .owner(hasSeat: true, status: .active) = self { return true }
    return false
  }
}
