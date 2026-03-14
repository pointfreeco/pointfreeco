import Css
import Dependencies
import Either
import Foundation
import FunctionalCss
import Html
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import TaggedMoney

public func accountView(
  accountData: AccountData,
  allEpisodes: [Episode],
  currentDate: Date
) -> Node {
  let content: Node = [
    titleRowView,
    profileRowView(accountData),
    privateRssFeed(accountData: accountData),
    referAFriend(accountData: accountData),
    subscriptionOverview(accountData: accountData, currentDate: currentDate),
    creditsView(accountData: accountData, allEpisodes: allEpisodes),
    logoutView,
  ]

  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        content
      )
    )
  )
}

private func creditsView(accountData: AccountData, allEpisodes: [Episode]) -> Node {
  guard !accountData.subscriberState.isActive else { return [] }
  guard accountData.currentUser.episodeCreditCount > 0 || accountData.episodeCredits.count > 0
  else { return [] }

  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(
          attributes: [.class([Class.pf.type.responsiveTitle4])],
          "Video Credits"
        ),
        .p(
          "Video credits allow you to see members only videos before commiting to a membership. ",
          .text(
            "You currently have \(pluralizedCredits(count: accountData.currentUser.episodeCreditCount)) "
          ),
          "remaining."
        ),
        subscribeCallout(accountData.subscriberState),
        episodeCreditsView(credits: accountData.episodeCredits, allEpisodes: allEpisodes)
      )
    )
  )
}

private func subscribeCallout(_ subscriberState: SubscriberState) -> Node {
  guard !subscriberState.isActiveSubscriber else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  return .p(
    "To get all past and future videos, ",
    .a(
      attributes: [
        .class([Class.pf.colors.link.purple]),
        .href(siteRouter.path(for: .pricingLanding)),
      ],
      "become"
    ),
    " a member today!"
  )
}

private func pluralizedCredits(count: Int) -> String {
  return count == 1
    ? "1 credit"
    : "\(count) credits"
}

private func episodeCreditsView(credits: [EpisodeCredit], allEpisodes: [Episode]) -> Node {
  guard credits.count > 0 else { return [] }

  return [
    .h3(
      attributes: [
        .class(
          [
            Class.pf.type.responsiveTitle5,
            Class.padding([.mobile: [.top: 2]]),
          ]
        )
      ],
      "Chosen videos"
    ),

    .ul(
      .fragment(
        allEpisodes
          .filter { ep in credits.contains(where: { $0.episodeSequence == ep.sequence }) }
          .reversed()
          .map { ep in .li([episodeLinkView(ep)]) }
      )
    ),
  ]
}

private func episodeLinkView(_ episode: Episode) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .a(
    attributes: [
      .href(siteRouter.path(for: .episodes(.show(episode)))),
      .class([Class.pf.colors.link.purple]),
    ],
    .text("#\(episode.sequence): \(episode.fullTitle)")
  )
}

private let titleRowView = Node.gridRow(
  attributes: [.class([Class.padding([.mobile: [.bottom: 2]])])],
  .gridColumn(
    sizes: [.mobile: 12],
    .div(
      .h1(attributes: [.class([Class.pf.type.responsiveTitle2])], "Account")
    )
  )
)

private func profileRowView(_ data: AccountData) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  let nameFields: Node = [
    .label(attributes: [.class([labelClass])], "Name"),
    .input(
      attributes: [
        .class([blockInputClass]),
        .name(ProfileData.CodingKeys.name.stringValue),
        .type(.text),
        .value(data.currentUser.name ?? ""),
      ]
    ),
  ]

  let emailFields: Node = [
    .label(attributes: [.class([labelClass])], "Email"),
    .input(
      attributes: [
        .class([blockInputClass]),
        .name(ProfileData.CodingKeys.email.stringValue),
        .type(.email),
        .value(data.currentUser.email.rawValue),
      ]
    ),
  ]

  let showExtraInvoiceInfo =
    data.isSubscriptionOwner && !data.subscriberState.isEnterpriseSubscriber
  let extraInvoiceInfoFields: Node =
    !showExtraInvoiceInfo
    ? []
    : [
      .label(
        attributes: [
          .class([labelClass])
        ],
        "Extra Invoice Info"
      ),
      .p(
        attributes: [
          .class([
            Class.pf.colors.fg.gray400,
            Class.pf.type.body.small,
          ])
        ],
        "This information will appear on ",
        .a(
          attributes: [
            .class([
              Class.pf.type.underlineLink
            ]),
            .href(siteRouter.path(for: .account(.invoices()))),
          ],
          "all past invoices"
        ),
        "."
      ),
      .textarea(
        attributes: [
          .placeholder("Company name, billing address, VAT number, ..."),
          .class([blockInputClass]),
          .name(ProfileData.CodingKeys.extraInvoiceInfo.stringValue),
        ],
        data.stripeSubscription?.customer.right?.extraInvoiceInfo ?? ""
      ),
    ]

  let submit = Node.input(
    attributes: [
      .type(.submit),
      .class([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])]),
      .value("Update profile"),
    ]
  )

  let formContent: Node = [
    nameFields,
    emailFields,
    extraInvoiceInfoFields,
    emailSettingCheckboxes(data.emailSettings, data.subscriberState),
    submit,
  ]

  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], "Profile"),
        .form(
          attributes: [.action(siteRouter.path(for: .account(.update()))), .method(.post)],
          formContent
        )
      )
    )
  )
}

private func emailSettingCheckboxes(
  _ currentEmailSettings: [EmailSetting],
  _ subscriberState: SubscriberState
) -> Node {
  let newsletters =
    subscriberState.isNonSubscriber
    ? EmailSetting.Newsletter.allNewsletters
    : EmailSetting.Newsletter.subscriberNewsletters

  return [
    // TODO: hide `welcomeEmails` for subscribers?
    .p("Receive email for:"),
    .p(
      attributes: [.class([Class.padding([.mobile: [.left: 1]])])],
      .fragment(
        newsletters.map { newsletter in
          .label(
            attributes: [.class([Class.display.block])],
            .input(
              attributes: [
                .type(.checkbox),
                .name("emailSettings[\(newsletter.rawValue)]"),
                .checked(currentEmailSettings.contains(where: \.newsletter == newsletter)),
                .class([Class.margin([.mobile: [.right: 1]])]),
              ]
            ),
            .text(newsletterDescription(newsletter))
          )
        }
      )
    ),
  ]
}

private func newsletterDescription(_ type: EmailSetting.Newsletter) -> String {
  switch type {
  case .announcements:
    return "New announcements (very infrequently)"
  case .newBlogPost:
    return "New blog posts on Point-Free Pointers (about every two weeks)"
  case .newEpisode:
    return "New video is available (about once a week)"
  case .welcomeEmails:
    return "A short series of emails introducing Point-Free"
  }
}

private func subscriptionOverview(accountData: AccountData, currentDate: Date) -> Node {
  if accountData.isSubscriptionOwner {
    return subscriptionOwnerOverview(accountData: accountData, currentDate: currentDate)
  } else if accountData.stripeSubscription != nil {
    return subscriptionTeammateOverview(accountData)
  } else {
    return []
  }
}

private func privateRssFeed(accountData: AccountData) -> Node {
  guard accountData.subscriberState.isActiveSubscriber else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  let user = accountData.currentUser

  return .gridRow(
    .gridColumn(
      sizes: [.desktop: 10, .mobile: 12],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        attributes: [
          .class(
            [
              Class.margin([.mobile: [.bottom: 4]]),
              Class.padding([.mobile: [.all: 3]]),
              Class.pf.colors.bg.gray900,
            ]
          )
        ],
        .h4(
          attributes: [
            .class(
              [
                Class.pf.type.responsiveTitle4,
                Class.padding([.mobile: [.bottom: 2]]),
              ]
            )
          ],
          "Private RSS Feed"
        ),
        .p(
          """
          Thanks for subscribing to Point-Free and supporting our efforts! We'd like to offer you an alternate way
          to consume our videos: an RSS feed that can be used with most podcast apps!
          """
        ),
        .p(
          "The link below should work with most podcast apps out there today (please ",
          .a(
            attributes: [
              .class([Class.pf.type.underlineLink]),
              .href("mailto:support@pointfree.co"),
            ],
            "email us"
          ),
          " if it doesn't). It is also tied directly to your Point-Free account and regularly ",
          " monitored, so please do not share with others."
        ),
        copyToPasteboard(
          text: siteRouter.url(for: .account(.rss(salt: user.rssSalt))),
          buttonColor: .black
        )
      )
    )
  )
}

// TODO: consolidate with PrivateRss.swift value
private let nonYearlyMaxRssItems = 4

private func rssTerms(stripeSubscription: Stripe.Subscription?) -> Node {
  return stripeSubscription?.plan.interval == .some(.month)
    ? .p(
      attributes: [
        .class([Class.padding([.mobile: [.all: 2]]), Class.margin([.mobile: [.top: 2]])]),
        .style(backgroundColor(.rgb(0xff, 0xff, 0xdd))),
      ],
      "Because you have a monthly membership, you get access to the last ",
      .text("\(nonYearlyMaxRssItems)"),
      " videos in your RSS feed (don't worry, you can watch every past video directly on this site).",
      " To access all videos from the RSS feed, please consider upgrading to a yearly membership."
    )
    : []
}

var currentUserCanReferOthers: Bool {
  @Dependency(\.subscriberState) var subscriberState
  return subscriberState.isActiveSubscriber
    && subscriberState.isOwner
    && !subscriberState.isEnterpriseSubscriber
    && !subscriberState.isTeammate
}

private func referAFriend(
  accountData: AccountData
) -> Node {
  guard currentUserCanReferOthers
  else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  let referralUrl = siteRouter.url(
    for: .subscribeConfirmation(
      lane: .personal,
      referralCode: accountData.currentUser.referralCode
    )
  )

  return .gridRow(
    .gridColumn(
      sizes: [.desktop: 10, .mobile: 12],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        attributes: [
          .class(
            [
              Class.margin([.mobile: [.bottom: 4]]),
              Class.padding([.mobile: [.all: 3]]),
              Class.pf.colors.bg.gray900,
            ]
          )
        ],
        .h4(
          attributes: [
            .class(
              [
                Class.pf.type.responsiveTitle4,
                Class.padding([.mobile: [.bottom: 2]]),
              ]
            )
          ],
          "Refer a Friend"
        ),
        .p(
          """
          Refer Point-Free to a friend! You'll both get one month free (a $24 credit) when they sign up from your personal referral link:
          """
        ),
        copyToPasteboard(text: referralUrl, buttonColor: .black)
      )
    )
  )
}

private func subscriptionOwnerOverview(accountData: AccountData, currentDate: Date) -> Node {
  guard let subscription = accountData.stripeSubscription else { return [] }

  let content: Node =
    accountData.subscriberState.isEnterpriseSubscriber
    ? enterpriseSubscriptionOverview(accountData)
    : [
      subscriptionPlanRows(
        subscription: subscription,
        upcomingInvoice: accountData.upcomingInvoice,
        paymentMethod: accountData.paymentMethod,
        currentDate: currentDate
      ),
      teammatesSection(accountData: accountData),
      subscriptionPaymentInfoView(subscription, paymentMethod: accountData.paymentMethod),
    ]

  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], ["Subscription overview"]),
        .gridColumn(sizes: [.mobile: 12], content)
      )
    )
  )
}

private func teammatesSection(
  accountData: AccountData
) -> Node {
  [
    .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], ["Teammates"]),
    subscriptionTeamRow(accountData),
    subscriptionInviteMoreRowView(accountData),
    addTeammateToSubscriptionRow(accountData),
  ]
}

private func enterpriseSubscriptionOverview(_ data: AccountData) -> Node {
  guard let subscription = data.stripeSubscription else { return [] }
  guard
    case let .owner(_, _, .some(enterpriseAccount), _) = data.subscriberState
  else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  let planRow = Node.gridRow(
    .gridColumn(
      sizes: [.mobile: 3],
      .p(.div("Plan"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p([.text(planName(for: subscription))])
          )
        )
      )
    )
  )

  let statusRow = Node.gridRow(
    .gridColumn(
      sizes: [.mobile: 3],
      .p(.div("Status"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p(.text(status(for: subscription)))
          )
        )
      )
    )
  )

  let shareUrl = siteRouter.url(for: .enterprise(enterpriseAccount.domain))
  let shareRow = Node.gridRow(
    .gridColumn(
      sizes: [.mobile: 3],
      .p(.div("Invite Link"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p(
              .a(
                attributes: [.class([Class.pf.colors.link.purple]), .href(shareUrl)],
                .text(shareUrl)
              )
            )
          )
        )
      )
    )
  )

  let contactUsRow = Node.gridRow(
    .gridColumn(
      sizes: [.mobile: 3],
      .p(.div("Contact Support"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p(
              .a(
                attributes: [
                  .class([Class.pf.colors.link.purple]), .mailto("support@pointfree.co"),
                ],
                "support@pointfree.co"
              )
            )
          )
        )
      )
    )
  )

  return .div(
    attributes: [.class([Class.padding([.mobile: [.top: 1, .bottom: 3]])])],
    planRow,
    statusRow,
    shareRow,
    contactUsRow,
    teammatesSection(accountData: data)
  )
}

private func subscriptionTeammateOverview(_ data: AccountData) -> Node {
  guard data.stripeSubscription != nil else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  var enterpriseShareLink: Node
  if case let .teammate(_, .some(enterpriseAccount), _) = data.subscriberState {
    let shareUrl = siteRouter.url(for: .enterprise(enterpriseAccount.domain))
    enterpriseShareLink = .p(
      "Share Point-Free with your co-workers by sending them this link: ",
      .a(attributes: [.href(shareUrl)], .text(shareUrl))
    )
  } else {
    enterpriseShareLink = []
  }

  return Node.gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
    Node.gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], "Subscription overview"),

        .p(
          "You are currently on a team. Contact ",
          .a(
            attributes: [
              .mailto(data.subscriptionOwner?.email.rawValue ?? ""),
              .class([Class.pf.colors.link.purple]),
            ],
            .text(data.subscriptionOwner?.name ?? "the owner")
          ),
          " for more information."
        ),

        enterpriseShareLink,

        .form(
          attributes: [.action(siteRouter.path(for: .team(.leave))), .method(.post)],
          .input(
            attributes: [
              .class([Class.pf.components.button(color: .red, size: .small)]),
              .type(.submit),
              .value("Leave this team"),
            ]
          )
        )
      )
    )
  )
}

private func planName(for subscription: Stripe.Subscription) -> String {
  let lineItems = planLineItems(for: subscription)
  guard !lineItems.isEmpty else { return subscription.plan.description }

  if lineItems.count == 1 {
    let lineItem = lineItems[0]
    return lineItem.quantity > 1
      ? lineItem.name + " (×" + String(lineItem.quantity) + ")"
      : lineItem.name
  }

  return lineItems
    .map { lineItem in
      lineItem.quantity == 1
        ? lineItem.name + " (×1)"
        : lineItem.name + " ×" + String(lineItem.quantity)
    }
    .joined(separator: ", ")
}

private func subscriptionSeatAmount(for subscription: Stripe.Subscription) -> Cents<Int> {
  if let amount = subscription.plan.amount {
    return amount
  }

  @Dependency(\.envVars) var envVars

  let pricing = Pricing(
    billing: subscription.plan.interval == .month ? .monthly : .yearly,
    quantity: subscription.totalQuantity
  )
  if subscription.plan.product == envVars.stripe.productId {
    if let modernPricing = pricing.modernPricing {
      return modernPricing
    }
  }

  return pricing.legacyPricing
}

private func itemSeatAmount(
  for item: Stripe.Subscription.Item,
  subscription: Stripe.Subscription
) -> Cents<Int> {
  if let amount = item.plan.amount {
    return amount
  }

  @Dependency(\.envVars) var envVars

  let billing: Pricing.Billing = item.plan.interval == .month ? .monthly : .yearly
  if item.plan.product == envVars.stripe.productId {
    let quantityForTier = subscription.totalQuantity > 1
      ? max(item.quantity, 2)
      : max(item.quantity, 1)
    let pricing = Pricing(billing: billing, quantity: quantityForTier)
    return pricing.modernPricing ?? pricing.legacyPricing
  }

  return Pricing(billing: billing, quantity: max(item.quantity, 1)).legacyPricing
}

private func planDisplayName(for plan: Stripe.Plan) -> String {
  if plan.description == plan.id.rawValue, plan.id.rawValue.contains("pointfree_pro") {
    return "Pro"
  }
  return plan.description
}

private func planLineItems(for subscription: Stripe.Subscription) -> [PlanLineItem] {
  let items = subscription.items.data.filter { $0.quantity > 0 }
  guard items.count > 1
  else {
    return [
      .init(
        name: planDisplayName(for: subscription.plan),
        quantity: subscription.totalQuantity,
        seatAmount: subscriptionSeatAmount(for: subscription),
        interval: subscription.plan.interval
      )
    ]
  }

  return items.map { item in
    .init(
      name: planDisplayName(for: item.plan),
      quantity: item.quantity,
      seatAmount: itemSeatAmount(for: item, subscription: subscription),
      interval: item.plan.interval
    )
  }
}

private func planPricingDescription(for subscription: Stripe.Subscription) -> String {
  let lineItems = planLineItems(for: subscription)
  guard let firstLineItem = lineItems.first else { return "" }
  let interval = firstLineItem.interval.rawValue

  if lineItems.count == 1 {
    if firstLineItem.quantity > 1 {
      let total = Cents(rawValue: firstLineItem.seatAmount.rawValue * firstLineItem.quantity)
      return "\(format(cents: firstLineItem.seatAmount))/\(interval) per seat (\(format(cents: total))/\(interval) total)"
    } else {
      return "\(format(cents: firstLineItem.seatAmount))/\(interval)"
    }
  }

  let terms = lineItems
    .map { "\(format(cents: $0.seatAmount))×\($0.quantity)" }
    .joined(separator: " + ")
  let total = Cents(rawValue: lineItems.reduce(0) { $0 + $1.seatAmount.rawValue * $1.quantity })
  return "\(terms) (\(format(cents: total))/\(interval) total)"
}

private func inviteTeammateAmount(for subscription: Stripe.Subscription) -> Cents<Int> {
  let proposedQuantity = max(subscription.totalQuantity + 1, 2)
  let proposedPricing = Pricing(
    billing: subscription.plan.interval == .month ? .monthly : .yearly,
    quantity: proposedQuantity
  )

  return proposedPricing.modernPricing ?? proposedPricing.legacyPricing
}

private struct PlanLineItem {
  var name: String
  var quantity: Int
  var seatAmount: Cents<Int>
  var interval: Stripe.Plan.Interval
}

public func status(for subscription: Stripe.Subscription) -> String {
  switch subscription.status {
  case .active:
    let currentPeriodEndString =
      subscription.cancelAtPeriodEnd
      ? " through " + dateFormatter.string(from: subscription.currentPeriodEnd)
      : ""
    return "Active" + currentPeriodEndString
  case .canceled:
    return "Canceled"
  case .pastDue:
    return "Past due"
  case .paused:
    return "Paused"
  case .incomplete, .incompleteExpired, .unpaid:
    return "Unpaid"
  case .trialing:
    return "In trial"
  }
}

public func nextBilling(
  forSubscription subscription: Stripe.Subscription,
  upcomingInvoice: Stripe.Invoice?,
  currentDate: Date
) -> String {
  switch (subscription.status, upcomingInvoice) {
  case let (.active, .some(invoice)):
    return format(cents: invoice.amountDue)
      + " on "
      + dateFormatter.string(from: invoice.periodEnd)
  case (.canceled, _):
    return subscription.currentPeriodEnd > currentDate
      ? "Cancels " + dateFormatter.string(from: subscription.currentPeriodEnd)
      : "Canceled"
  case (.active, .none),
    (.incomplete, _),
    (.incompleteExpired, _),
    (.pastDue, _),
    (.paused, _),
    (.unpaid, _),
    (.trialing, _):
    return ""  // FIXME
  }
}

private func subscriptionPlanRows(
  subscription: Stripe.Subscription,
  upcomingInvoice: Stripe.Invoice?,
  paymentMethod: Either<any CardProtocol, PaymentMethod>?,
  currentDate: Date
) -> Node {

  let planRow = Node.gridRow(
    .gridColumn(
      sizes: [.mobile: 3],
      .p(.div("Plan"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p(.text(planName(for: subscription)))
          )
        ),
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [
              .class([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])
            ],
            .p(mainAction(for: subscription, paymentMethod: paymentMethod))
          )
        )
      )
    )
  )

  let pricingRow = Node.gridRow(
    .gridColumn(
      sizes: [.mobile: 3],
      .p(.div("Pricing"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .div(
        attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
        .p(.text(planPricingDescription(for: subscription)))
      )
    )
  )

  let statusRow = Node.gridRow(
    .gridColumn(
      sizes: [.mobile: 3],
      .p(.div("Status"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p(.text(status(for: subscription)))
          )
        ),
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [
              .class([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])
            ],
            .p(
              subscription.isCancellable
                ? cancelAction(for: subscription)
                : []
            )
          )
        )
      )
    )
  )

  let nextBillingRow: Node =
    subscription.cancelAtPeriodEnd || subscription.status == .canceled
    ? []
    : .gridRow(
      .gridColumn(
        sizes: [.mobile: 3],
        .p(.div("Next billing"))
      ),
      .gridColumn(
        sizes: [.mobile: 9],
        .div(
          attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
          .p(
            .text(
              nextBilling(
                forSubscription: subscription,
                upcomingInvoice: upcomingInvoice,
                currentDate: currentDate
              )
            )
          )
        )
      )
    )

  let discountRow: Node =
    subscription.discount.map { discount in
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 3],
          .p(.div("Discount"))
        ),
        .gridColumn(
          sizes: [.mobile: 9],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p(.text(discountDescription(for: discount)))
          )
        )
      )
    }
    ?? []

  let creditRow: Node =
    subscription.customer.right
    .filter { $0.balance < 0 }
    .map { customer in
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 3],
          .p(.div("Account credit"))
        ),
        .gridColumn(
          sizes: [.mobile: 9],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p(.text(format(cents: customer.balance)))
          )
        )
      )
    }
    ?? []

  return .div(
    attributes: [.class([Class.padding([.mobile: [.top: 1, .bottom: 3]])])],
    planRow,
    pricingRow,
    statusRow,
    nextBillingRow,
    discountRow,
    creditRow
  )
}

private func discountDescription(for discount: Stripe.Discount) -> String {
  return
    "\(discount.coupon.name ?? discount.coupon.id.rawValue): \(discount.coupon.formattedDescription)"
}

private func cancelAction(for subscription: Stripe.Subscription) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .form(
    attributes: [
      .action(siteRouter.path(for: .account(.subscription(.cancel)))),
      .method(.post),
      .onsubmit(
        unsafe: """
          if (!confirm("Cancel your membership? You will lose access to Point-Free at the end of the current billing period. Should you change your mind, you can reactivate your membership at any time before this period ends.")) {
            return false
          }
          """
      ),
    ],
    .button(
      attributes: [
        .class([Class.pf.components.button(color: .black, size: .small, style: .underline)])
      ],
      "Cancel"
    )
  )
}

private func mainAction(
  for subscription: Stripe.Subscription,
  paymentMethod: Either<any CardProtocol, PaymentMethod>?
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  if subscription.isCanceling {
    return .form(
      attributes: [
        .action(siteRouter.path(for: .account(.subscription(.reactivate)))),
        .method(.post),
      ],
      .button(
        attributes: [.class([Class.pf.components.button(color: .purple, size: .small)])],
        "Reactivate"
      )
    )
  } else if subscription.status == .canceled {
    return .a(
      attributes: [
        .class([Class.pf.components.button(color: .purple, size: .small)]),
        .href(siteRouter.path(for: .pricingLanding)),
      ],
      "Rejoin"
    )
  } else {
    @Dependency(\.envVars) var envVars

    let discount = subscription.discount?.coupon.discount ?? { $0 }
    let isTeam = subscription.quantity > 1
    let pricingTransitionPrefix = (subscription.plan.product == envVars.stripe.productId)
      ? "Your new rate will be "
      : "This change moves you to our current pricing of "

    func formattedModernAmount(_ billing: Pricing.Billing) -> String? {
      let seatAmount = Pricing(billing: billing, quantity: subscription.quantity).modernPricing
      guard let seatAmount else { return nil }
      let amount = discount(seatAmount)
        .map { $0 * subscription.quantity }
      return currencyFormatter.string(
        from: NSNumber(value: Double(amount.rawValue) / 100)
      )
    }

    switch subscription.plan.interval {
    case .month:
      let formattedAmount = formattedModernAmount(.yearly)
      if paymentMethod != nil {
        return .form(
          attributes: [
            .action(siteRouter.path(for: .account(.subscription(.change(.update()))))),
            .method(.post),
            .onsubmit(
              unsafe: """
                if (!confirm("Upgrade to yearly billing? \(pricingTransitionPrefix)\(formattedAmount ?? "")/year. You will be charged immediately with a prorated refund for the time remaining in your billing period.")) {
                  return false
                }
                """
            ),
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
            attributes: [.class([Class.pf.components.button(color: .purple, size: .small)])],
            "Upgrade to yearly billing"
          )
        )
      } else {
        return .a(
          attributes: [
            .class([Class.pf.components.button(color: .purple, size: .small)]),
            .href(siteRouter.path(for: .account(.paymentInfo()))),
          ],
          "Add payment info to upgrade"
        )
      }
    case .year:
      guard !isTeam else { return [] }
      let formattedAmount = formattedModernAmount(.monthly)
      return .form(
        attributes: [
          .action(siteRouter.path(for: .account(.subscription(.change(.update()))))),
          .method(.post),
          .onsubmit(
            unsafe: """
              if (!confirm("Switch to monthly billing? \(pricingTransitionPrefix)\(formattedAmount ?? "")/month. You will be charged \(formattedAmount ?? "") on a monthly basis at the end of your current billing period.")) {
                return false
              }
              """
          ),
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
          attributes: [.class([Class.pf.components.button(color: .purple, size: .small)])],
          "Switch to monthly billing"
        )
      )
    }
  }
}

private func subscriptionTeamRow(_ data: AccountData) -> Node {
  let currentTeamNode: Node
  if !data.teammates.isEmpty,
    data.isSubscriptionOwner
  {
    currentTeamNode = .div(
      attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
      .h4(
        attributes: [.class([Class.padding([.mobile: [.bottom: 0]])])],
        "Your current team:"
      ),
      .fragment(data.teammates.map { teammateRowView(data.currentUser, $0) })
    )
  } else {
    currentTeamNode = []
  }

  let invitesNode: Node
  if !data.teamInvites.isEmpty {
    invitesNode = .div(
      attributes: [.class([Class.padding([.mobile: [.leftRight: 1, .top: 1]])])],
      .h4(
        attributes: [.class([Class.padding([.mobile: [.bottom: 0]])])],
        "These teammates have been invited, but have not yet accepted."
      ),
      .fragment(data.teamInvites.map(inviteRowView))
    )
  } else {
    invitesNode = []
  }

  return .gridRow(
    attributes: [.class([subscriptionInfoRowClass])],
    .gridColumn(
      sizes: [.mobile: 3],
      .div(.p("Team"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      currentTeamNode,
      invitesNode
    )
  )
}

private func teammateRowView(_ currentUser: User, _ teammate: User) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  let teammateLabel =
    currentUser.id == teammate.id
    ? "\(teammate.displayName) (you)"
    : teammate.name.map { "\($0) (\(teammate.email))" } ?? teammate.email.rawValue

  return .gridRow(
    .gridColumn(sizes: [.mobile: 8], .p(.text(teammateLabel))),
    .gridColumn(
      sizes: [.mobile: 4],
      attributes: [.class([Class.grid.end(.desktop)])],
      .form(
        attributes: [.action(siteRouter.path(for: .team(.remove(teammate.id)))), .method(.post)],
        .p(
          .input(attributes: [
            .type(.submit), .class([Class.pf.components.button(color: .purple, size: .small)]),
            .value("Remove"),
          ])
        )
      )
    )
  )
}

private func inviteRowView(_ invite: TeamInvite) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      .p(.text(invite.email.rawValue))
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      attributes: [.class([Class.grid.end(.desktop)])],
      .form(
        attributes: [
          .action(siteRouter.path(for: .invite(.invitation(invite.id, .resend)))),
          .method(.post),
          .class([Class.display.inlineBlock]),
        ],
        .p(
          .input(
            attributes: [
              .type(.submit),
              .class([Class.pf.components.button(color: .purple, size: .small)]),
              .value("Resend"),
            ]
          )
        )
      ),

      .form(
        attributes: [
          .action(siteRouter.path(for: .invite(.invitation(invite.id, .revoke)))),
          .method(.post),
          .class([
            Class.display.inlineBlock, Class.padding([.mobile: [.left: 1], .desktop: [.left: 2]]),
          ]),
        ],
        .p(
          .input(
            attributes: [
              .type(.submit),
              .class([Class.pf.components.button(color: .red, size: .small, style: .underline)]),
              .value("Revoke"),
            ]
          )
        )
      )
    )
  )
}

private func addTeammateToSubscriptionRow(_ data: AccountData) -> Node {
  guard !data.subscriberState.isEnterpriseSubscriber else { return [] }
  guard let stripeSubscription = data.stripeSubscription else { return [] }
  guard let subscription = data.subscription else { return [] }
  guard data.isSubscriptionOwner else { return [] }
  guard stripeSubscription.isRenewing else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  if stripeSubscription.plan.interval == .month {
    let upgradeAction: Node
    if data.paymentMethod != nil {
      upgradeAction = .form(
        attributes: [
          .action(siteRouter.path(for: .account(.subscription(.change(.update()))))),
          .method(.post),
          .onsubmit(
            unsafe: """
              if (!confirm("Upgrade to yearly billing to invite teammates? You will be charged immediately with a prorated refund for the time remaining in your billing period.")) {
                return false
              }
              """
          ),
        ],
        .input(attributes: [
          .name("billing"),
          .type(.hidden),
          .value("yearly"),
        ]),
        .input(attributes: [
          .name("quantity"),
          .type(.hidden),
          .value(stripeSubscription.quantity),
        ]),
        .button(
          attributes: [.class([Class.pf.components.button(color: .purple, size: .small)])],
          "Upgrade to yearly billing"
        )
      )
    } else {
      upgradeAction = .a(
        attributes: [
          .class([Class.pf.components.button(color: .purple, size: .small)]),
          .href(siteRouter.path(for: .account(.paymentInfo()))),
        ],
        "Add payment info to upgrade"
      )
    }

    return .gridRow(
      attributes: [.class([subscriptionInfoRowClass])],
      .gridColumn(
        sizes: [.mobile: 3],
        .div(.p("Add teammate"))
      ),
      .gridColumn(
        sizes: [.mobile: 9],
        .div(
          attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
          .p("Inviting teammates requires yearly billing."),
          .p(upgradeAction)
        )
      )
    )
  }

  let amount = inviteTeammateAmount(for: stripeSubscription)
  let interval = stripeSubscription.plan.interval == .year ? "year" : "month"

  let inviteViaEmail: Node
  let invitesRemaining = stripeSubscription.quantity - data.teamInvites.count - data.teammates.count
  if invitesRemaining <= 0 {
    inviteViaEmail = .gridRow(
      attributes: [.class([subscriptionInfoRowClass])],
      .gridColumn(
        sizes: [.mobile: 3],
        .div(.p("Invite via email"))
      ),
      .gridColumn(
        sizes: [.mobile: 9],
        .markdownBlock(
          attributes: [
            .class([
              Class.pf.type.body.regular
            ])
          ],
          """
          Add a teammate for a discounted rate of **$\(amount.rawValue / 100)/\
          \(interval)**. Your first invoice will be prorated based on your current billing cycle.
          """
        ),
        .form(
          attributes: [
            .action(siteRouter.path(for: .invite(.addTeammate(nil)))),
            .method(.post),
            .class([Class.flex.flex, Class.padding([.mobile: [.top: 1]])]),
          ],
          .input(
            attributes: [
              .class([smallInputClass, Class.align.middle, Class.size.width100pct]),
              .name("email"),
              .placeholder("blob@example.com"),
              .type(.email),
              .required(true),
            ]
          ),
          .input(
            attributes: [
              .type(.submit),
              .class([
                Class.pf.components.button(color: .purple, size: .small),
                Class.align.middle,
                Class.margin([.mobile: [.left: 1], .desktop: [.left: 2]]),
              ]),
              .value("Add"),
            ]
          )
        )
      )
    )
  } else {
    inviteViaEmail = []
  }

  guard data.paymentMethod != nil
  else {
    return .gridRow(
      attributes: [.class([subscriptionInfoRowClass])],
      .gridColumn(
        sizes: [.mobile: 3],
        .div(.p("Add teammate"))
      ),
      .gridColumn(
        sizes: [.desktop: 9],
        .gridRow(
          .gridColumn(
            sizes: [.mobile: 12, .desktop: 6],
            .div(
              attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
              .p("Payment info required to add seats")
            )
          ),
          .gridColumn(
            sizes: [.mobile: 12, .desktop: 6],
            .div(
              attributes: [
                .class([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])
              ],
              .p(
                .a(
                  attributes: [
                    .class([Class.pf.components.button(color: .purple, size: .small)]),
                    .href(siteRouter.path(for: .account(.paymentInfo()))),
                  ],
                  "Add payment info"
                )
              )
            )
          )
        )
      )
    )
  }

  return [
    inviteViaEmail,

    .gridRow(
      attributes: [.class([subscriptionInfoRowClass])],
      .gridColumn(
        sizes: [.mobile: 3],
        .div(.p("Invite via link"))
      ),
      .gridColumn(
        sizes: [.mobile: 9],
        .markdownBlock(
          attributes: [
            .class([
              Class.pf.type.body.regular
            ])
          ],
          """
          Invite your colleages to your membership by sharing the following URL. Your credit
          card will be charged a prorated amount of **$\(amount.rawValue / 100)/\(interval)**
          when a teammate joins.
          """
        ),
        copyToPasteboard(
          text: siteRouter.url(for: .teamInviteCode(.landing(code: subscription.teamInviteCode))),
          buttonColor: .white
        ),
        .form(
          attributes: [
            .action(siteRouter.path(for: .account(.regenerateTeamInviteCode))),
            .class([
              Class.pf.type.body.small,
              Class.pf.colors.fg.gray400,
              Class.padding([.mobile: [.top: 1]]),
            ]),
            .method(.post),
            .onsubmit(
              unsafe: """
                if (!confirm("Really invalidate the current invite link? Team mates will need an updated link to join.")) {
                  return false
                }
                """
            ),
          ],
          .button(
            attributes: [
              .class([
                Class.border.none,
                Class.cursor.pointer,
                Class.padding([.mobile: [.all: 0]]),
                Class.pf.colors.bg.white,
                Class.type.underline,
              ])
            ],
            "Click here"
          ),
          " to invalidate the current invite link and generate a new one."
        )
      )
    ),
  ]
}

private func subscriptionInviteMoreRowView(_ data: AccountData) -> Node {
  guard !data.subscriberState.isEnterpriseSubscriber else { return [] }
  guard let subscription = data.stripeSubscription else { return [] }
  guard subscription.plan.interval == .year else { return [] }
  guard data.isSubscriptionOwner else { return [] }
  let invites = data.teamInvites
  let teammates = data.teammates
  let invitesRemaining = subscription.quantity - invites.count - teammates.count
  guard invitesRemaining > 0 else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  return .gridRow(
    attributes: [.class([subscriptionInfoRowClass])],
    .gridColumn(
      sizes: [.mobile: 3],
      .div(.p("Invite more"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .div(
        attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
        .p(inviteTeammatesDescription(invitesRemaining: invitesRemaining)),

        .form(
          attributes: [
            .action(siteRouter.path(for: .invite(.send(nil)))),
            .method(.post),
            .class([Class.flex.flex]),
          ],
          .input(
            attributes: [
              .class([smallInputClass, Class.align.middle, Class.size.width100pct]),
              .name("email"),
              .placeholder("blob@example.com"),
              .type(.email),
            ]
          ),
          .input(
            attributes: [
              .type(.submit),
              .class([
                Class.pf.components.button(color: .purple, size: .small),
                Class.align.middle,
                Class.margin([.mobile: [.left: 1], .desktop: [.left: 2]]),
              ]),
              .value("Invite"),
            ]
          )
        )
      )
    )
  )
}

private func inviteTeammatesDescription(invitesRemaining: Int) -> Node {
  let seats = invitesRemaining == 1 ? "1 open seat" : "\(invitesRemaining) open seats"
  return .text("You have \(seats) on your team. Invite a team member below:")
}

private func subscriptionPaymentInfoView(
  _ subscription: Stripe.Subscription,
  paymentMethod: Either<any CardProtocol, PaymentMethod>?
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  let paymentInfo: Node
  if let card = paymentMethod?.left {
    paymentInfo = [
      .p(.text("\(card.cardBrand.rawValue) ending in \(card.last4)")),
      .p(.text("Expires \(card.expMonth)/\(card.expYear)")),
    ]
  } else if let card = paymentMethod?.right?.card {
    paymentInfo = [
      .p(.text("\(card.brand.description) ending in \(card.last4)")),
      .p(.text("Expires \(card.expMonth)/\(card.expYear)")),
    ]
  } else {
    paymentInfo = [
      .p("No payment info")
    ]
  }

  return [
    .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], ["Payment info"]),
    .gridRow(
      attributes: [.class([subscriptionInfoRowClass])],
      .gridColumn(
        sizes: [.mobile: 3],
        .div(.p("Payment"))
      ),
      Node.gridColumn(
        sizes: [.desktop: 9],
        Node.gridRow(
          Node.gridColumn(
            sizes: [.mobile: 12, .desktop: 6],
            .div(
              attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
              paymentInfo
            )
          ),
          .gridColumn(
            sizes: [.mobile: 12, .desktop: 6],
            .div(
              attributes: [
                .class([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])
              ],
              .p(
                .a(
                  attributes: [
                    .class([Class.pf.components.button(color: .purple, size: .small)]),
                    .href(siteRouter.path(for: .account(.paymentInfo()))),
                  ],
                  subscription.customer.right?.hasPaymentInfo == true
                    ? "Update payment info"
                    : "Add payment info"
                )
              ),
              .p(
                .a(
                  attributes: [
                    .class([
                      Class.pf.components.button(color: .black, size: .small, style: .underline)
                    ]),
                    .href(siteRouter.path(for: .account(.invoices()))),
                  ],
                  "Payment history"
                )
              )
            )
          )
        )
      )
    ),
  ]
}

public func format(cents: Cents<Int>) -> String {
  let dollars = NSNumber(value: Double(cents.rawValue) / 100)
  return currencyFormatter.string(from: dollars)
    ?? NumberFormatter.localizedString(from: dollars, number: .currency)
}

private var logoutView: Node {
  @Dependency(\.siteRouter) var siteRouter

  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12],
      .a(
        attributes: [
          .class([Class.pf.components.button(color: .black)]),
          .href(siteRouter.path(for: .auth(.logout))),
        ],
        "Logout"
      )
    )
  )
}

private func copyToPasteboard(
  text: String,
  buttonColor: Class.pf.components.Color
) -> Node {
  .div(
    attributes: [
      .class([Class.flex.flex, Class.padding([.mobile: [.top: 1]])])
    ],
    .input(
      attributes: [
        .class([smallInputClass, Class.align.middle, Class.size.width100pct]),
        .value(text),
        .type(.text),
        .readonly(true),
        .onclick(safe: "this.select();"),
      ]
    ),
    .input(
      attributes: [
        .type(.button),
        .class([
          Class.pf.components.button(color: .white, size: .small),
          Class.align.middle,
          Class.margin([.mobile: [.left: 1], .desktop: [.left: 2]]),
        ]),
        .value("Copy"),
        .onclick(
          unsafe: """
            navigator.clipboard.writeText("\(text)");
            this.value = "Copied!";
            setTimeout(() => { this.value = "Copy"; }, 3000);
            """
        ),
      ]
    )
  )
}

private let subscriptionInfoRowClass =
  Class.border.top
  | Class.pf.colors.border.gray800
  | Class.padding([.mobile: [.top: 2, .bottom: 3]])

let labelClass =
  Class.h5
  | Class.type.bold
  | Class.display.block
  | Class.margin([.mobile: [.bottom: 1]])

let smallInputClass =
  baseInputClass
  | Class.size.height(rem: 2)
  | Class.padding([.mobile: [.all: 1]])

let blockSelectClass =
  Class.display.block
  | Class.margin([.mobile: [.bottom: 2]])
  | Class.size.height(rem: 3)
  | Class.size.width100pct
  | Class.pf.colors.border.gray800
  | Class.type.fontFamily.inherit

public struct AccountData {
  public let currentUser: User
  public let emailSettings: [EmailSetting]
  public let episodeCredits: [EpisodeCredit]
  public let paymentMethod: Either<any CardProtocol, PaymentMethod>?
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
    paymentMethod: Either<any CardProtocol, PaymentMethod>?,
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
    self.paymentMethod = paymentMethod
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

private let dateFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateFormat = "MMM d, yyyy"
  df.timeZone = TimeZone(secondsFromGMT: 0)
  return df
}()
