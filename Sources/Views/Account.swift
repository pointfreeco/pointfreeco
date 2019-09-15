import Css
import FunctionalCss
import HtmlUpgrade
import Models
import PointFreeRouter
import Prelude
import Stripe
import Styleguide

public func _accountView(data: AccountData) -> Node {
  return [
//    gridRow(
//      [`class`([moduleRowClass])],
//      [
//        gridColumn(
//          sizes: [.mobile: 12],
//          [h1([`class`([Class.pf.type.responsiveTitle2])], ["Account"])]
//        ),
//        gridColumn(
//          sizes: [:],
//          [`class`([Class.grid.start(.mobile)])],
//          [
//            "You selected the Team plan"
//          ]
//        ),
//        gridColumn(
//          sizes: [:],
//          [`class`([Class.grid.end(.mobile)])],
//          [
//            a(
//              [
//                `class`([
//                  Class.pf.colors.link.gray650,
//                  Class.pf.type.underlineLink
//                  ]),
//                href(url(to: .pricingLanding))
//              ],
//              ["Change plan"]
//            )
//          ]
//        )
//      ]
//    )
  ]
}

public struct AccountData {
  public let currentUser: User
  public let emailSettings: [EmailSetting]
  public let episodeCredits: [EpisodeCredit]
  public let stripeSubscription: Stripe.Subscription?
  public let subscriberState: SubscriberState
  public let subscription: Models.Subscription?
  public let subscriptionOwner: User?
  public let teamInvites: [TeamInvite]
  public let teammates: [User]
  public let upcomingInvoice: Stripe.Invoice?

  public init(
    currentUser: User,
    emailSettings: [EmailSetting],
    episodeCredits: [EpisodeCredit],
    stripeSubscription: Stripe.Subscription?,
    subscriberState: SubscriberState,
    subscription: Models.Subscription?,
    subscriptionOwner: User?,
    teamInvites: [TeamInvite],
    teammates: [User],
    upcomingInvoice: Stripe.Invoice?
    ) {
    self.currentUser = currentUser
    self.emailSettings = emailSettings
    self.episodeCredits = episodeCredits
    self.stripeSubscription = stripeSubscription
    self.subscriberState = subscriberState
    self.subscription = subscription
    self.subscriptionOwner = subscriptionOwner
    self.teamInvites = teamInvites
    self.teammates = teammates
    self.upcomingInvoice = upcomingInvoice
  }

  public var isSubscriptionOwner: Bool {
    return self.currentUser.id == self.subscriptionOwner?.id
  }

  public var isTeamSubscription: Bool {
    return (self.stripeSubscription?.quantity ?? 0) > 1
  }
}
