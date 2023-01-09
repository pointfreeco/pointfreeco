import Stripe

public enum SubscriberState {
  case nonSubscriber
  case owner(
    hasSeat: Bool, status: Stripe.Subscription.Status, enterpriseAccount: EnterpriseAccount?,
    deactivated: Bool)
  case teammate(
    status: Stripe.Subscription.Status, enterpriseAccount: EnterpriseAccount?, deactivated: Bool)

  public init(
    user: User?,
    subscription: Models.Subscription?,
    enterpriseAccount: EnterpriseAccount?
  ) {
    switch (user, subscription) {
    case let (.some(user), .some(subscription)):
      if subscription.userId == user.id {
        self = .owner(
          hasSeat: user.subscriptionId != nil,
          status: subscription.stripeSubscriptionStatus,
          enterpriseAccount: enterpriseAccount,
          deactivated: subscription.deactivated
        )
      } else {
        self = .teammate(
          status: subscription.stripeSubscriptionStatus,
          enterpriseAccount: enterpriseAccount,
          deactivated: subscription.deactivated
        )
      }

    case (.none, _), (.some, _):
      self = .nonSubscriber
    }
  }

  public var status: Stripe.Subscription.Status? {
    switch self {
    case .nonSubscriber:
      return nil
    case let .owner(_, status, _, _):
      return status
    case let .teammate(status, _, _):
      return status
    }
  }

  public var deactivated: Bool? {
    switch self {
    case .nonSubscriber:
      return nil
    case let .owner(_, _, _, deactivated),
      let .teammate(_, _, deactivated):
      return deactivated
    }
  }

  public var isActive: Bool {
    return self.deactivated != .some(true) && self.status?.isActive == .some(true)
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
    switch self {
    case .teammate(status: .active, _, _),
      .teammate(status: .trialing, _, _),
      .owner(hasSeat: _, status: .active, _, _),
      .owner(hasSeat: _, status: .trialing, _, _):
      return false
    default:
      return true
    }
  }

  public var isActiveSubscriber: Bool {
    switch self {
    case let .teammate(status: status, _, false),
      let .owner(hasSeat: true, status: status, _, false):
      return status.isActive
    default:
      return false
    }
  }

  public var isEnterpriseSubscriber: Bool {
    switch self {
    case .owner(_, _, enterpriseAccount: .some, _), .teammate(_, enterpriseAccount: .some, _):
      return true
    case .nonSubscriber, .owner, .teammate:
      return false
    }
  }
}
