import Css
import Foundation
import FunctionalCss
import HtmlUpgrade
import Models
import Optics
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import TaggedMoney

public func _accountView(data: AccountData) -> Node {
  return [
    accountRow(for: data),
    teamRow(for: data),
  ]
}

private func accountRow(for data: AccountData) -> Node {
  return .gridRow(
    attributes: [.class([moduleRowClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      .h1(attributes: [.class([Class.pf.type.responsiveTitle2])], "Account")
    ),
    .gridColumn(
      sizes: [:],
      attributes: [.class([Class.grid.start(.mobile)])],
      data.stripeSubscription?.isCanceling == .some(true)
        ? ["Your ", .strong([.text(data.planName)]), " subscription is set to cancel"]
        : ["You are on the ", .strong([.text(data.planName)]), " plan"]
    ),
    .gridColumn(
      sizes: [:],
      attributes: [.class([Class.grid.end(.mobile)])],
      planCallToAction(data.stripeSubscription)
    ),
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
      .div(
        attributes: [
          .class([
            Class.pf.type.body.small,
            Class.pf.colors.fg.gray400
            ]),
        ],
        couponDetail(for: data),
        subscriptionDetail(for: data)
      )
    )
  )
}

private func teamRow(for data: AccountData) -> Node {
  guard let subscription = data.stripeSubscription else { return [] }

  return .gridRow(
    attributes: [.class([moduleRowClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      .h1(
        attributes: [.class([moduleTitleColumnClass])],
        subscription.quantity > 1
          ? "Your team"
          : "Invite your team"
      )
    ),
    teamOwner(for: data),
    teamMemberTemplate("", withRemoveButton: false),
    .gridColumn(
      sizes: [.mobile: 6],
      attributes: [.class([Class.padding([.mobile: [.top: 3]])])],
//      attributes: [.class([Class.grid.start(.mobile)])],
      .div(
        .a(
          attributes: [
            .class([
              Class.type.medium,
              Class.cursor.pointer,
              Class.type.nowrap,
              Class.pf.colors.link.black,
              Class.pf.colors.fg.black,
              Class.pf.colors.bg.white,
              Class.h5,
              Class.padding([.mobile: [.leftRight: 2, .topBottom: 2]]),
              Class.border.all,
              Class.pf.colors.border.gray850,
              ]),
          ],
          "Add another team member"
        )
      )
    ),
    .gridColumn(
      sizes: [.mobile: 6],
      attributes: [
        .class([
          Class.grid.end(.mobile),
          Class.padding([.mobile: [.top: 3]]),
          ])
      ],
      .div(
        .a(
          attributes: [
            .class([
              Class.border.none,
              Class.type.textDecorationNone,
              Class.cursor.pointer,
              Class.type.bold,
              Class.typeScale([.mobile: .r1, .desktop: .r1]),
              Class.padding([.mobile: [.topBottom: 2, .leftRight: 2]]),
              Class.type.align.center,
              Class.pf.colors.bg.black,
              Class.pf.colors.fg.white,
              Class.pf.colors.link.white,
              ]),
          ],
          "Update team"
        )
      )
    )
  )
}

private func teamOwner(for data: AccountData) -> Node {
  guard
    let owner = data.subscriptionOwner
    else { return [] }

  return .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .id("team-owner"),
      .class([
        Class.border.all,
        Class.pf.colors.border.gray850,
        Class.padding([.mobile: [.all: 2]]),
        Class.margin([.mobile: [.top: 1]]),
        ]),
      .style(lineHeight(0))
    ],
    .div(
      attributes: [
        .class([
          Class.flex.flex,
          Class.grid.middle(.mobile)
          ])
      ],
      .input(
        attributes: [
          .name(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue),
          .type(.hidden),
          .value("true")
        ]
      ),
      .img(
        src: owner.gitHubAvatarUrl.absoluteString,
        alt: "",
        attributes: [
          .class([
            Class.pf.colors.bg.green,
            Class.border.circle,
            Class.margin([.mobile: [.right: 1]])
            ]),
          .style(width(.px(24)) <> height(.px(24)))
        ]
      ),
      .span(
        attributes: [.class([Class.size.width100pct])],
        .text(owner.displayName)
      ),
      data.isTeamSubscription
        && data.isSubscriptionOwner
        && data.subscriberState.isTeammate
        ? .a(
          attributes: [
            .id("remove-yourself-button"),
            .class([
              Class.cursor.pointer,
              Class.pf.colors.fg.red,
              Class.pf.colors.link.red,
              Class.type.light,
              Class.pf.type.body.small,
              Class.pf.type.underlineLink
              ]),
          ],
          .raw("Remove&nbsp;yourself")
          )
        : []
    )
  )
}

private func teamMemberTemplate(_ email: EmailAddress, withRemoveButton: Bool) -> Node {
  return .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .class([
        Class.border.all,
        Class.pf.colors.border.gray850,
        Class.padding([.mobile: [.all: 2]]),
        Class.margin([.mobile: [.top: 1]])
        ]),
      .style(lineHeight(0))
    ],
    .div(
      attributes: [
        .class([
          Class.flex.flex,
          Class.grid.middle(.mobile)
          ])
      ],
      .img(
        base64: mailIconSvg,
        type: .image(.svg),
        alt: "",
        attributes: [
          .class([
            Class.margin([.mobile: [.right: 1]])
            ]),
          .style(width(.px(24)) <> height(.px(24)))
        ]
      ),
      .input(attributes: [
        .type(.email),
        .placeholder("blob@pointfree.co"),
        .class([Class.size.width100pct]),
        .name("teammates[]"),
        .style(
          borderWidth(all: 0)
            <> key("outline", "none")
        ),
        .value(email.rawValue),
        ]),
      withRemoveButton
        ? .a(attributes: [
          .class([
            Class.cursor.pointer,
            Class.pf.colors.fg.red,
            Class.pf.colors.link.red,
            Class.type.light,
            Class.pf.type.body.small,
            Class.pf.type.underlineLink
            ]),
          .onclick(safe: """
var teamMemberRow = this.parentNode.parentNode
teamMemberRow.parentNode.removeChild(teamMemberRow)
updateSeats()
""")
          ], "Remove")
        : []
    )
  )
}

private func couponDetail(for data: AccountData) -> Node {
  guard let coupon = data.stripeSubscription?.discount?.coupon else { return [] }
  return [
    coupon.name
      .map { [" You are using the coupon ", .strong(.text($0))] }
      ?? " You are using a coupon",
      ", which gives you ", .strong(.text(coupon.formattedDescription)), ". "
  ]
}

private func subscriptionDetail(for data: AccountData) -> Node {
  guard let subscription = data.stripeSubscription else { return [] }

  if let upcomingInvoice = data.upcomingInvoice, subscription.isRenewing {
    return .form(
      attributes: [
        .action(path(to: .account(.subscription(.cancel)))),
        .class([Class.display.inline]),
        .method(.post),
        .onsubmit(unsafe: """
if (!confirm("Cancel your subscription? You will lose access to Point-Free at the end of the current billing period. Should you change your mind, you can reactivate your subscription at any time before this period ends.")) {
  return false
}
"""),
      ],
      "Your subscription is currently ",
      .strong("active"),
      " and will automatically renew on ",
      .strong(.text(dateFormatter.string(from: subscription.currentPeriodEnd))),
      " for ",
      .strong(.text(prettyFormat(upcomingInvoice.amountDue))),
      ". You may ",
      .button(
        attributes: [
          .class([
            Class.border.none,
            Class.cursor.pointer,
            Class.display.inline,
            Class.padding([.mobile: [.all: 0]]),
            Class.pf.colors.bg.white,
            Class.pf.colors.fg.gray300,
            Class.type.underline,
            ])
        ],
        "cancel"
      ),
      " at any time."
    )
  }

  return []
}

private func prettyFormat(_ cents: Cents<Int>) -> String {
  let dollars = cents.map(Double.init(_:)).dollars
  return currencyFormatter.string(from: NSNumber(value: dollars.rawValue))
    .map { $0.replacingOccurrences(of: #"\.00$"#, with: "", options: .regularExpression) }
    ?? ""
}

private let dateFormatter = DateFormatter()
  |> \.dateStyle .~ .full

private func planCallToAction(_ subscription: Stripe.Subscription?) -> Node {
  guard let subscription = subscription else {
    return .a(
      attributes: [
        .class([Class.pf.colors.link.gray650, Class.pf.type.underlineLink]),
        .href(url(to: .pricingLanding))
      ],
      "Upgrade"
    )
  }

  if subscription.isCanceling == .some(true) {
    return .form(
      attributes: [
        .action(path(to: .account(.subscription(.reactivate)))),
        .method(.post),
      ],
      .button(
        attributes: [
          .class([
            Class.pf.components.button(color: .black, size: .regular, style: .underline),
            Class.type.normal,
            Class.pf.colors.fg.gray650,
            ])
        ],
        "Reactivate"
      )
    )
  }

  // TODO: Handle canceled subscriptions?

  switch subscription.plan.interval {
  case .month:
    let discount = subscription.discount?.coupon.discount ?? { $0 }
    let amount = discount(subscription.quantity == 1 ? 168_00 : 144_00)
      .map { $0 * subscription.quantity }
    let formattedAmount = currencyFormatter.string(from: NSNumber(value: Double(amount.rawValue) / 100))
    return .form(
      attributes: [
        .action(path(to: .account(.subscription(.change(.update(nil)))))),
        .method(.post),
        .onsubmit(unsafe: """
          if (!confirm("Upgrade to yearly billing? You will be charged \(formattedAmount ?? "") immediately with a prorated refund for the time remaining in your billing period.")) {
          return false
          }
          """),
      ],
      .input(attributes: [
        .name("billing"),
        .type(.hidden),
        .value("yearly"),
        ]),
      .input(attributes: [
        .name("quantity"),
        .type(.hidden),
        .value(subscription.quantity),
        ]),
      .button(
        attributes: [
          .class([
            Class.pf.components.button(color: .black, size: .regular, style: .underline),
            Class.type.normal,
            Class.pf.colors.fg.gray650,
            ])
        ],
        "Upgrade to yearly billing"
      )
    )
  case .year:
    let discount = subscription.discount?.coupon.discount ?? { $0 }
    let amount = discount(subscription.quantity == 1 ? 18_00 : 16_00)
      .map { $0 * subscription.quantity }
    let formattedAmount = currencyFormatter.string(from: NSNumber(value: Double(amount.rawValue) / 100))
    return .form(
      attributes: [
        .action(path(to: .account(.subscription(.change(.update(nil)))))),
        .method(.post),
        .onsubmit(unsafe: """
          if (!confirm("Switch to monthly billing? You will be charged \(formattedAmount ?? "") on a monthly basis at the end of your current billing period.")) {
          return false
          }
          """),
      ],
      .input(attributes: [
        .name("billing"),
        .type(.hidden),
        .value("monthly"),
        ]),
      .input(attributes: [
        .name("quantity"),
        .type(.hidden),
        .value(subscription.quantity),
        ]),
      .button(
        attributes: [
          .class([
            Class.pf.components.button(color: .black, size: .regular, style: .underline),
            Class.type.normal,
            Class.pf.colors.fg.gray650,
            ])
        ],
        "Switch to monthly billing"
      )
    )
  }
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

  public var planName: String {
    return self.stripeSubscription
      .map {
        (
          $0.quantity > 1
            ? "Team"
            : "Personal"
          )
          + " "
          + ($0.plan.interval == .month ? "Monthly" : "Yearly")
      }
      ?? "Free"
  }
}
