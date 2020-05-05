import Css
import FunctionalCss
import Foundation
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
  currentDate: Date,
  appSecret: AppSecret
) -> Node {
  let content: Node = [
    titleRowView,
    profileRowView(accountData),
    privateRssFeed(accountData: accountData, appSecret: appSecret),
    referAFriend(accountData: accountData),
    subscriptionOverview(accountData: accountData, currentDate: currentDate),
    creditsView(accountData: accountData, allEpisodes: allEpisodes),
    logoutView
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
  guard accountData.currentUser.episodeCreditCount > 0 || accountData.episodeCredits.count > 0 else { return [] }

  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(
          attributes: [.class([Class.pf.type.responsiveTitle4])],
          "Episode Credits"
        ),
        .p(
          "Episode credits allow you to see subscriber-only episodes before commiting to a full ",
          .text("subscription. You currently have \(pluralizedCredits(count: accountData.currentUser.episodeCreditCount)) "),
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

  return .p(
    "To get all past and future episodes, ",
    .a(
      attributes: [.class([Class.pf.colors.link.purple]), .href(path(to: .pricingLanding))],
      "become"
    ),
    " a subscriber today!"
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
            Class.padding([.mobile: [.top: 2]])
          ]
        ),
      ],
      "Chosen episodes"
    ),

    .ul(
      .fragment(
        allEpisodes
          .filter { ep in credits.contains(where: { $0.episodeSequence == ep.sequence }) }
          .reversed()
          .map { ep in .li([episodeLinkView(ep)]) }
      )
    )
  ]
}

private func episodeLinkView(_ episode: Episode) -> Node {
  return .a(
    attributes: [
      .href(path(to: .episode(.show(.left(episode.slug))))),
      .class([Class.pf.colors.link.purple])
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

  let nameFields: Node = [
    .label(attributes: [.class([labelClass])], "Name"),
    .input(
      attributes: [
        .class([blockInputClass]),
        .name(ProfileData.CodingKeys.name.stringValue),
        .type(.text),
        .value(data.currentUser.name ?? ""),
      ]
    )
  ]

  let emailFields: Node = [
    .label(attributes: [.class([labelClass])], "Email"),
    .input(
      attributes: [
        .class([blockInputClass]),
        .name(ProfileData.CodingKeys.email.stringValue),
        .type(.email),
        .value(data.currentUser.email.rawValue)
      ]
    )
  ]

  let showExtraInvoiceInfo = data.isSubscriptionOwner && !data.subscriberState.isEnterpriseSubscriber
  let extraInvoiceInfoFields: Node = !showExtraInvoiceInfo ? [] : [
    .label(attributes: [.class([labelClass])], "Extra Invoice Info"),
    .textarea(
      attributes: [
        .placeholder("Company name, billing address, VAT number, ..."),
        .class([blockInputClass]),
        .name(ProfileData.CodingKeys.extraInvoiceInfo.stringValue),
      ],
      data.stripeSubscription?.customer.right?.extraInvoiceInfo ?? ""
    )
  ]

  let submit = Node.input(
    attributes: [
      .type(.submit),
      .class([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])]),
      .value("Update profile")
    ]
  )

  let formContent: Node = [
    nameFields,
    emailFields,
    extraInvoiceInfoFields,
    emailSettingCheckboxes(data.emailSettings, data.subscriberState),
    submit
  ]

  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], "Profile"),
        .form(
          attributes: [.action(path(to: .account(.update(nil)))), .method(.post)],
          formContent
        )
      )
    )
  )
}

private func emailSettingCheckboxes(_ currentEmailSettings: [EmailSetting], _ subscriberState: SubscriberState) -> Node {
  let newsletters = subscriberState.isNonSubscriber
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
                .checked(currentEmailSettings.contains(where: ^\.newsletter == newsletter)),
                .class([Class.margin([.mobile: [.right: 1]])])
              ]
            ),
            .text(newsletterDescription(newsletter))
          )
        }
      )
    )
  ]
}

private func newsletterDescription(_ type: EmailSetting.Newsletter) -> String {
  switch type {
  case .announcements:
    return "New announcements (very infrequently)"
  case .newBlogPost:
    return "New blog posts on Point-Free Pointers (about every two weeks)"
  case .newEpisode:
    return "New episode is available (about once a week)"
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

private func privateRssFeed(
  accountData: AccountData,
  appSecret: AppSecret
) -> Node {
  guard accountData.subscriberState.isActiveSubscriber else { return [] }
  let user = accountData.currentUser
  let encryptedUserId = Encrypted(user.id.rawValue.uuidString, with: appSecret)
  let encryptedRssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: appSecret)
  let rssUrl = zip(encryptedUserId, encryptedRssSalt)
    .map { url(to: .account(.rss(userId: $0, rssSalt: $1))) }
  let rssLink: Node = rssUrl
    .map { rssUrl in
      [
        .ul(
          .li(
            .a(
              attributes: [.class([Class.pf.type.underlineLink]), .href(rssUrl)],
              .text(String(rssUrl.prefix(40)) + "...")
            )
          )
        ),
        rssTerms(stripeSubscription: accountData.stripeSubscription)
      ]
    }
    ?? []

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
              Class.pf.colors.bg.gray900
            ]
          )
        ],
        .h4(
          attributes: [
            .class(
              [
                Class.pf.type.responsiveTitle4,
                Class.padding([.mobile: [.bottom: 2]])
              ]
            )
          ],
          "Private RSS Feed"
        ),
        .p("""
Thanks for subscribing to Point-Free and supporting our efforts! We'd like to offer you an alternate way
to consume our videos: an RSS feed that can be used with podcast apps!
"""),
        .p(
          "The link below should work with most podcast apps out there today (please ",
          .a(
            attributes: [
              .class([Class.pf.type.underlineLink]),
              .href("mailto:support@pointfree.co")
            ],
            "email us"
          ),
          " if it doesn't). It is also tied directly to your Point-Free account and regularly ",
          " monitored, so please do not share with others."
        ),
        rssLink
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
        .style(backgroundColor(.rgb(0xff, 0xff, 0xdd)))
      ],
      "Because you are on a monthly subscription plan, you get access to the last ",
      .text("\(nonYearlyMaxRssItems)"),
      " episodes in your RSS feed (don't worry, you can watch every past episode directly on this site).",
      " To access all episodes from the RSS feed, please consider upgrading to a yearly subscription."
      )
    : []
}

private func referAFriend(
  accountData: AccountData
) -> Node {
  guard
    accountData.isSubscriptionOwner,
    accountData.stripeSubscription?.isCancellable == true,
    !accountData.subscriberState.isEnterpriseSubscriber
    else { return [] }

  let referralUrl = url(
    to: .subscribeConfirmation(
      lane: .personal,
      billing: nil,
      isOwnerTakingSeat: nil,
      teammates: nil,
      referralCode: accountData.currentUser.referralCode,
      useRegionCoupon: false
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
              Class.pf.colors.bg.gray900
            ]
          )
        ],
        .h4(
          attributes: [
            .class(
              [
                Class.pf.type.responsiveTitle4,
                Class.padding([.mobile: [.bottom: 2]])
              ]
            )
          ],
          "Refer a Friend"
        ),
        .p("""
Refer Point-Free to a friend! You'll both get one month free (an $18 credit) when they sign up from your personal referral link:
"""),
        .ul(
          .li(
            .a(
              attributes: [
                .class([Class.pf.type.underlineLink]),
                .href(referralUrl),
              ],
              .text(referralUrl)
            )
          )
        )
      )
    )
  )
}

private func subscriptionOwnerOverview(accountData: AccountData, currentDate: Date) -> Node {
  guard let subscription = accountData.stripeSubscription else { return [] }

  let content: Node = accountData.subscriberState.isEnterpriseSubscriber
    ? enterpriseSubscriptionOverview(accountData)
    : [
      subscriptionPlanRows(
        subscription: subscription,
        upcomingInvoice: accountData.upcomingInvoice,
        currentDate: currentDate
      ),
      subscriptionTeamRow(accountData),
      subscriptionInvitesRowView(accountData.teamInvites),
      subscriptionInviteMoreRowView(accountData),
      addTeammateToSubscriptionRow(accountData),
      subscriptionPaymentInfoView(subscription)
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

private func enterpriseSubscriptionOverview(_ data: AccountData) -> Node {
  guard let subscription = data.stripeSubscription else { return [] }
  guard
    case let .owner(_, _, .some(enterpriseAccount)) = data.subscriberState
    else { return [] }

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

  let shareUrl = url(to: .enterprise(.landing(enterpriseAccount.domain)))
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
                attributes: [.class([Class.pf.colors.link.purple]), .mailto("support@pointfree.co")],
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
    contactUsRow
  )
}

private func subscriptionTeammateOverview(_ data: AccountData) -> Node {
  guard data.stripeSubscription != nil else { return [] }

  var enterpriseShareLink: Node
  if case let .teammate(_, .some(enterpriseAccount)) = data.subscriberState {
    let shareUrl = url(to: .enterprise(.landing(enterpriseAccount.domain)))
    enterpriseShareLink = .p(
      "Share Point-Free with your co-workers by sending them this link: ",
      .a(attributes: [.href(shareUrl)], .text(shareUrl))
    )
  } else {
    enterpriseShareLink = []
  }

  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h2(attributes: [.class([Class.pf.type.responsiveTitle4])], "Subscription overview"),

        .p(
          "You are currently on a team subscription. Contact ",
          .a(
            attributes: [
              .mailto(data.subscriptionOwner?.email.rawValue ?? ""),
              .class([Class.pf.colors.link.purple])
            ],
            .text(data.subscriptionOwner?.name ?? "the owner")
          ),
          " for more information."
        ),

        enterpriseShareLink,

        .form(
          attributes: [.action(path(to: .team(.leave))), .method(.post)],
          .input(
            attributes: [
              .class([Class.pf.components.button(color: .red, size: .small)]),
              .type(.submit),
              .value("Leave this team")
            ]
          )
        )
      )
    )
  )
}

private func planName(for subscription: Stripe.Subscription) -> String {
  return subscription.quantity > 1
    ? subscription.plan.nickname + " (×" + String(subscription.quantity) + ")"
    : subscription.plan.nickname
}

public func status(for subscription: Stripe.Subscription) -> String {
  switch subscription.status {
  case .active:
    let currentPeriodEndString = subscription.cancelAtPeriodEnd
      ? " through " + dateFormatter.string(from: subscription.currentPeriodEnd)
      : ""
    return "Active" + currentPeriodEndString
  case .canceled:
    return "Canceled"
  case .pastDue:
    return "Past due"
  case .unpaid:
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
  case (.active, .none), (.pastDue, _), (.unpaid, _), (.trialing, _):
    return "" // FIXME
  }
}

private func subscriptionPlanRows(
  subscription: Stripe.Subscription,
  upcomingInvoice: Stripe.Invoice?,
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
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])],
            .p(mainAction(for: subscription))
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
        ),
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])],
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

  let nextBillingRow: Node = subscription.cancelAtPeriodEnd || subscription.status == .canceled
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

  let discountRow: Node = subscription.discount.map { discount in
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

   let creditRow: Node = subscription.customer.right
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
    statusRow,
    nextBillingRow,
    discountRow,
    creditRow
  )
}

private func discountDescription(for discount: Stripe.Discount) -> String {
  return "\(discount.coupon.name ?? discount.coupon.id.rawValue): \(discount.coupon.formattedDescription)"
}

private func cancelAction(for subscription: Stripe.Subscription) -> Node {
  return .form(
    attributes: [
      .action(path(to: .account(.subscription(.cancel)))),
      .method(.post),
      .onsubmit(unsafe: """
if (!confirm("Cancel your subscription? You will lose access to Point-Free at the end of the current billing period. Should you change your mind, you can reactivate your subscription at any time before this period ends.")) {
  return false
}
"""),
    ],
    .button(
      attributes: [.class([Class.pf.components.button(color: .black, size: .small, style: .underline)])],
      "Cancel"
    )
  )
}

private func mainAction(for subscription: Stripe.Subscription) -> Node {
  if subscription.isCanceling {
    return .form(
      attributes: [.action(path(to: .account(.subscription(.reactivate)))), .method(.post)],
      .button(
        attributes: [.class([Class.pf.components.button(color: .purple, size: .small)])],
        "Reactivate"
      )
    )
  } else if subscription.status == .canceled {
    return .a(
      attributes: [
        .class([Class.pf.components.button(color: .purple, size: .small)]),
        .href(path(to: .pricingLanding))
      ],
      "Resubscribe"
    )
  } else {
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
          attributes: [.class([Class.pf.components.button(color: .purple, size: .small)])],
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
          attributes: [.class([Class.pf.components.button(color: .purple, size: .small)])],
          "Switch to monthly billing"
        )
      )
    }
  }
}

private func subscriptionTeamRow(_ data: AccountData) -> Node {
  guard
    !data.teammates.isEmpty,
    data.isTeamSubscription,
    !data.subscriberState.isEnterpriseSubscriber
    else { return [] }

  return .gridRow(
    attributes: [.class([subscriptionInfoRowClass])],
    .gridColumn(
      sizes: [.mobile: 3],
      .div(.p("Team"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .div(
        attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
        .p("Your current team:"),
        .fragment(data.teammates.map { teammateRowView(data.currentUser, $0) })
      )
    )
  )
}

private func teammateRowView(_ currentUser: User, _ teammate: User) -> Node {

  let teammateLabel = currentUser.id == teammate.id
    ? "\(teammate.displayName) (you)"
    : teammate.name.map { "\($0) (\(teammate.email))" } ?? teammate.email.rawValue

  return .gridRow(
    .gridColumn(sizes: [.mobile: 8], .p(.text(teammateLabel))),
    .gridColumn(
      sizes: [.mobile: 4], attributes: [.class([Class.grid.end(.desktop)])],
      .form(
        attributes: [.action(path(to: .team(.remove(teammate.id)))), .method(.post)],
        .p(
          .input(attributes: [.type(.submit), .class([Class.pf.components.button(color: .purple, size: .small)]), .value("Remove")])
        )
      )
    )
  )
}

private func subscriptionInvitesRowView(_ invites: [TeamInvite]) -> Node {
  guard !invites.isEmpty else { return [] }

  return .gridRow(
    attributes: [.class([subscriptionInfoRowClass])],
    .gridColumn(
      sizes: [.mobile: 3],
      .div(.p("Invites"))
    ),
    .gridColumn(
      sizes: [.mobile: 9],
      .div(
        attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
        .p("These teammates have been invited, but have not yet accepted."),
        .fragment(invites.map(inviteRowView))
      )
    )
  )
}

private func inviteRowView(_ invite: TeamInvite) -> Node {
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
          .action(path(to: .invite(.resend(invite.id)))),
          .method(.post),
          .class([Class.display.inlineBlock])
        ],
        .p(
          .input(
            attributes: [
              .type(.submit),
              .class([Class.pf.components.button(color: .purple, size: .small)]),
              .value("Resend")
            ]
          )
        )
      ),

      .form(
        attributes: [
          .action(path(to: .invite(.revoke(invite.id)))),
          .method(.post),
          .class([Class.display.inlineBlock, Class.padding([.mobile: [.left: 1], .desktop: [.left: 2]])])
        ],
        .p(
          .input(
            attributes: [
              .type(.submit),
              .class([Class.pf.components.button(color: .red, size: .small, style: .underline)]),
              .value("Revoke")
            ]
          )
        )
      )
    )
  )
}

private func addTeammateToSubscriptionRow(_ data: AccountData) -> Node {
  guard !data.subscriberState.isEnterpriseSubscriber else { return [] }
  guard let subscription = data.stripeSubscription else { return [] }
  guard subscription.isRenewing else { return [] }
  let invitesRemaining = subscription.quantity - data.teamInvites.count - data.teammates.count
  guard invitesRemaining == 0 else { return [] }

  let amount = subscription.plan.interval == .some(.year) ? Cents(rawValue: 144_00) : Cents(rawValue: 16_00)
  let interval = subscription.plan.interval == .some(.year) ? "year" : "month"

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
        .form(
          attributes: [
            .action(path(to: .invite(.addTeammate(nil)))),
            .method(.post),
            .class([Class.flex.flex, Class.padding([.mobile: [.top: 1]])])
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
                Class.margin([.mobile: [.left: 1], .desktop: [.left: 2]])
              ]),
              .value("Add")
            ]
          )
        ),
        .p(
          attributes: [
            .class([
              Class.pf.type.body.small,
              Class.pf.colors.fg.gray400,
              Class.padding([.mobile: [.top: 1]])
            ])
          ],
          .text("""
            Add a teammate to your subscription for a discounted rate of $\(amount.rawValue / 100)
            per \(interval). Your first invoice will be prorated based on your current billing cycle.
            """)
        )
      )
    )
  )
}

private func subscriptionInviteMoreRowView(_ data: AccountData) -> Node {

  guard !data.subscriberState.isEnterpriseSubscriber else { return [] }
  guard let subscription = data.stripeSubscription else { return [] }
  guard subscription.quantity > 1 else { return [] }
  let invites = data.teamInvites
  let teammates = data.teammates
  let invitesRemaining = subscription.quantity - invites.count - teammates.count
  guard invitesRemaining > 0 else { return [] }

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
            .action(path(to: .invite(.send(nil)))),
            .method(.post),
            .class([Class.flex.flex])
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
                Class.margin([.mobile: [.left: 1], .desktop: [.left: 2]])
              ]),
              .value("Invite")
            ]
          )
        )
      )
    )
  )
}

private func inviteTeammatesDescription(invitesRemaining: Int) -> Node {
  let seats = invitesRemaining == 1 ? "1 open seat": "\(invitesRemaining) open seats"
  return .text("You have \(seats) on your team. Invite a team member below:")
}

private func subscriptionPaymentInfoView(_ subscription: Stripe.Subscription) -> Node {
  guard let card = subscription.customer.right?.sources.data.first?.left
    else { return subscriptionInvoiceBillingInfoView }

  return .gridRow(
    attributes: [.class([subscriptionInfoRowClass])],
    .gridColumn(
      sizes: [.mobile: 3],
      .div(.p("Payment"))
    ),
    .gridColumn(
      sizes: [.desktop: 9],
      .gridRow(
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
            .p(.text(card.brand.rawValue + " ending in " + String(card.last4))),
            .p(.text("Expires " + String(card.expMonth) + "/" + String(card.expYear)))
          )
        ),
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 6],
          .div(
            attributes: [.class([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])],
            .p(
              .a(
                attributes: [
                  .class([Class.pf.components.button(color: .purple, size: .small)]),
                  .href(path(to: .account(.paymentInfo(.show)))),
                ],
                "Update payment method"
              )
            ),
            .p(
              .a(
                attributes: [
                  .class([Class.pf.components.button(color: .black, size: .small, style: .underline)]),
                  .href(path(to: .account(.invoices(.index)))),
                ],
                "Payment history"
              )
            )
          )
        )
      )
    )
  )
}

private let subscriptionInvoiceBillingInfoView = Node.gridRow(
  attributes: [.class([subscriptionInfoRowClass])],
  .gridColumn(
    sizes: [.mobile: 3],
    .div(.p("Payment"))
  ),
  .gridColumn(
    sizes: [.desktop: 9],
    .gridRow(
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 7],
        .div(
          attributes: [.class([Class.padding([.mobile: [.leftRight: 1]])])],
          .p(
            "You are enrolled in invoice billing. If you have any questions, please ",
            .a(
              attributes: [
                .class([Class.pf.type.underlineLink]),
                .href("mailto:support@pointfree.co")
              ],
              "contact us"
            ),
            "."
          )
        )
      ),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 5],
        .div(
          attributes: [.class([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])],
          .p(
            .a(
              attributes: [
                .class([Class.pf.components.button(color: .black, size: .small, style: .underline)]),
                .href(path(to: .account(.invoices(.index)))),
              ],
              "Payment history"
            )
          )
        )
      )
    )
  )
)

public func format(cents: Cents<Int>) -> String {
  let dollars = NSNumber(value: Double(cents.rawValue) / 100)
  return currencyFormatter.string(from: dollars)
    ?? NumberFormatter.localizedString(from: dollars, number: .currency)
}

private let logoutView = Node.gridRow(
  .gridColumn(
    sizes: [.mobile: 12],
    .a(
      attributes: [.class([Class.pf.components.button(color: .black)]), .href(path(to: .logout))],
      "Logout"
    )
  )
)

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

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .none
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  return formatter
}()
