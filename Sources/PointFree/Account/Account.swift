import Css
import FunctionalCss
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Tagged
import TaggedMoney
import Tuple
import View

let accountResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple2<User?, SubscriberState>, Data> =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <| fetchAccountData
    >=> writeStatus(.ok)
    >=> respond(
      view: View(accountView),
      layoutData: { data in
        SimplePageLayoutData(
          currentSubscriberState: data.subscriberState,
          currentUser: data.currentUser,
          data: data,
          title: "Account"
        )
    }
)

private func fetchAccountData<I>(
  _ conn: Conn<I, Tuple2<User, SubscriberState>>
  ) -> IO<Conn<I, AccountData>> {

  let (user, subscriberState) = lower(conn.data)

  let userSubscription = user.subscriptionId
    .map(
      Current.database.fetchSubscriptionById
        >>> mapExcept(requireSome)
    )
    ?? throwE(unit)

  let ownerSubscription = Current.database.fetchSubscriptionByOwnerId(user.id)
    .mapExcept(requireSome)

  let owner = ownerSubscription
    .flatMap(Current.database.fetchUserById <<< ^\.userId)
    .mapExcept(requireSome)

  let subscription = userSubscription <|> ownerSubscription

  let stripeSubscription = subscription
    .map(^\.stripeSubscriptionId)
    .flatMap(Current.stripe.fetchSubscription)

  let upcomingInvoice = stripeSubscription
    .map(^\.customer >>> either(id, ^\.id))
    .flatMap(Current.stripe.fetchUpcomingInvoice)

  let everything = zip8(
    Current.database.fetchEmailSettingsForUserId(user.id).run.parallel
      .map { $0.right ?? [] },

    Current.database.fetchEpisodeCredits(user.id).run.parallel
      .map { $0.right ?? [] },

    stripeSubscription.run.map(^\.right).parallel,

    subscription.run.map(^\.right).parallel,

    owner.run.map(^\.right).parallel,

    Current.database.fetchTeamInvites(user.id).run.parallel
      .map { $0.right ?? [] },

    Current.database.fetchSubscriptionTeammatesByOwnerId(user.id).run.parallel
      .map { $0.right ?? [] },

    upcomingInvoice.run.map(^\.right).parallel
  )

  return everything
    .map {
      conn.map(
        const(
          AccountData(
            currentUser: user,
            emailSettings: $0,
            episodeCredits: $1,
            stripeSubscription: $2,
            subscriberState: subscriberState,
            subscription: $3,
            subscriptionOwner: $4,
            teamInvites: $5,
            teammates: $6,
            upcomingInvoice: $7
          )
        )
      )
    }
    .sequential
}

private func accountView(_ data: AccountData) -> [Node] {
  let content: [Node] =
    [titleRowView]
      + profileRowView(data)
      + privateRssFeed(data)
      + subscriptionOverview(data)
      + creditsView(data)
      + [logoutView]

  return [
    gridRow([
      gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
        div(
          [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
          content
        )
        ])
      ])
  ]
}

private func creditsView(_ data: AccountData) -> [Node] {

  guard !data.subscriberState.isActiveSubscriber else { return [] }
  guard data.currentUser.episodeCreditCount > 0 || data.episodeCredits.count > 0 else { return [] }

  return [
    gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
      gridColumn(sizes: [.mobile: 12], [
        div(
          [
            h2([`class`([Class.pf.type.responsiveTitle4])], ["Episode Credits"]),
            p([
              "Episode credits allow you to see subscriber-only episodes before commiting to a full ",
              .text("subscription. You currently have \(pluralizedCredits(count: data.currentUser.episodeCreditCount)) "),
              "remaining."
              ])
            ]
            + subscribeCallout(data.subscriberState)
            + episodeCreditsView(data.episodeCredits)
        )
        ])
      ])
  ]
}

private func subscribeCallout(_ subscriberState: SubscriberState) -> [Node] {

  guard !subscriberState.isActiveSubscriber else { return [] }

  return [
    p([
      "To get all past and future episodes, ",
      a([`class`([Class.pf.colors.link.purple]), href(path(to: .pricing(nil, expand: nil)))], ["become"]),
      " a subscriber today!"
      ])
  ]
}

private func pluralizedCredits(count: Int) -> String {
  return count == 1
    ? "1 credit"
    : "\(count) credits"
}

private func episodeCreditsView(_ credits: [EpisodeCredit]) -> [Node] {
  guard credits.count > 0 else { return [] }

  return [
    h3(
      [
        `class`(
          [
            Class.pf.type.responsiveTitle5,
            Class.padding([.mobile: [.top: 2]])
          ]
        ),
      ],
      ["Chosen episodes"]
    ),

    ul(
      episodes(from: credits)
        .reversed()
        .map { ep in li([episodeLinkView(ep)]) }
    )
  ]
}

private func episodeLinkView(_ episode: Episode) -> Node {
  return a(
    [
      href(path(to: .episode(.left(episode.slug)))),
      `class`(
        [
          Class.pf.colors.link.purple
        ]
      )
    ],
    [.text("#\(episode.sequence): \(episode.title)")]
  )
}

private func episodes(from credits: [EpisodeCredit]) -> [Episode] {
  return Current.episodes()
    .filter { ep in credits.contains(where: { $0.episodeSequence == ep.sequence }) }
}

private func episode(atSequence sequence: Int) -> Episode? {
  return Current.episodes()
    .first(where: { $0.sequence == sequence })
}

private let titleRowView = gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
  gridColumn(sizes: [.mobile: 12], [
    div([
      h1([`class`([Class.pf.type.responsiveTitle2])], ["Account"])
      ])
    ])
  ])

private func profileRowView(_ data: AccountData) -> [Node] {

  let nameFields = [
    label([`class`([labelClass])], ["Name"]),
    input([
      `class`([blockInputClass]),
      name(ProfileData.CodingKeys.name.stringValue),
      type(.text),
      value(data.currentUser.name ?? ""),
      ])
  ]

  let emailFields = [
    label([`class`([labelClass])], ["Email"]),
    input([
      `class`([blockInputClass]),
      name(ProfileData.CodingKeys.email.stringValue),
      type(.email),
      value(data.currentUser.email.rawValue)
      ])
  ]

  let extraInvoiceInfoFields = !data.isSubscriptionOwner ? [] : [
    label([`class`([labelClass])], ["Extra Invoice Info"]),
    textarea(
      [
        placeholder("Company name, billing address, VAT number, ..."),
        `class`([blockInputClass]),
        name(ProfileData.CodingKeys.extraInvoiceInfo.stringValue),
      ],
      data.stripeSubscription?.customer.right?.extraInvoiceInfo ?? ""
    )
  ]

  let submit = [
    input([
      type(.submit),
      `class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])]),
      value("Update profile")
      ])
  ]

  let formContent: [Node] =
    nameFields
      + emailFields
      + extraInvoiceInfoFields
      + emailSettingCheckboxes(data.emailSettings, data.subscriberState)
      + submit

  return [
    gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
      gridColumn(sizes: [.mobile: 12], [
        div([
          h2([`class`([Class.pf.type.responsiveTitle4])], ["Profile"]),

          form(
            [action(path(to: .account(.update(nil)))), method(.post)],
            formContent
          )
          ])
        ])
      ])
  ]
}

private func emailSettingCheckboxes(_ currentEmailSettings: [EmailSetting], _ subscriberState: SubscriberState) -> [Node] {
  let newsletters = subscriberState.isNonSubscriber
    ? EmailSetting.Newsletter.allNewsletters
    : EmailSetting.Newsletter.subscriberNewsletters

  return [
    // TODO: hide `welcomeEmails` for subscribers?
    p(["Receive email for:"]),
    p([`class`([Class.padding([.mobile: [.left: 1]])])], newsletters.map { newsletter in
      label([`class`([Class.display.block])], [
        input(
          [
            type(.checkbox),
            name("emailSettings[\(newsletter.rawValue)]"),
            checked(currentEmailSettings.contains(where: ^\.newsletter == newsletter)),
            `class`([Class.margin([.mobile: [.right: 1]])])
          ]
        ),
        .text(newsletterDescription(newsletter))
        ])
    })
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

private func subscriptionOverview(_ data: AccountData) -> [Node] {

  if data.isSubscriptionOwner {
    return subscriptionOwnerOverview(data)
  } else if data.stripeSubscription != nil {
    return subscriptionTeammateOverview(data)
  } else {
    return []
  }
}

private func privateRssFeed(_ data: AccountData) -> [Node] {
  guard Current.features.hasAccess(to: .podcastRss, for: data.currentUser) else { return [] }
  guard data.subscriberState.isActiveSubscriber else { return [] }
  let user = data.currentUser
  let encryptedUserId = Encrypted(user.id.rawValue.uuidString, with: Current.envVars.appSecret)
  let encryptedRssSalt = Encrypted(user.rssSalt.rawValue.uuidString, with: Current.envVars.appSecret)
  let rssUrl = zip(encryptedUserId, encryptedRssSalt)
    .map { url(to: .account(.rss(userId: $0, rssSalt: $1))) }
  let rssLink = rssUrl
    .map { rssUrl in
      [
        p([
          a(
            [`class`([Class.pf.type.underlineLink]), href(rssUrl)],
            [text(String(rssUrl.prefix(40)) + "...")]
          )
          ]
        )
        ]
        + rssTerms(stripeSubscription: data.stripeSubscription)
    }
    ?? []

  return [
    gridRow([
      gridColumn(
        sizes: [.desktop: 10, .mobile: 12],
        [style(margin(leftRight: .auto))],
        [
          div(
            [
              `class`(
                [
                  Class.margin([.mobile: [.bottom: 4]]),
                  Class.padding([.mobile: [.all: 3]]),
                  Class.pf.colors.bg.gray900
                ]
              )
            ],
            [
              h4(
                [
                  `class`(
                    [
                      Class.pf.type.responsiveTitle4,
                      Class.padding([.mobile: [.bottom: 2]])
                    ]
                  )
                ],
                ["Private RSS Feed"]
              ),
              p(["""
Thanks for subscribing to Point-Free and supporting our efforts! We'd like to offer you an alternate way
to consume our videos: an RSS feed that can be used with podcast apps!
"""]),
              p([
                "The link below should work with most podcast apps out there today (please ",
                a(
                  [
                    `class`([Class.pf.type.underlineLink]),
                    href("mailto:support@pointfree.co")
                  ],
                  ["email us"]
                ),
                " if it doesn't). It is also tied directly to your Point-Free account and regularly ",
                " monitored, so please do not share with others."
                ])
              ]
              + rssLink
          )
        ]
      )
      ])
  ]
}

private func rssTerms(stripeSubscription: Stripe.Subscription?) -> [Node] {
  return stripeSubscription?.plan.interval == .some(.month)
    ? [
      p([
        `class`([Class.padding([.mobile: [.all: 2]]), Class.margin([.mobile: [.top: 2]])]),
        style(backgroundColor(.rgb(0xff, 0xff, 0xdd)))
        ],
        [
          "Because you are on a monthly subscription plan, you get access to the last ",
          .text("\(nonYearlyMaxRssItems)"),
          " episodes in your RSS feed (don't worry, you can watch every past episode directly on this site).",
          " To access all episodes from the RSS feed, please consider ",
          a(
            [`class`([Class.pf.type.underlineLink]), href(path(to: .account(.subscription(.change(.show)))))],
            ["upgrading"]
          ),
          " to a yearly subscription."
        ]
      )
      ]
    : []
}

private func subscriptionOwnerOverview(_ data: AccountData) -> [Node] {
  guard let subscription = data.stripeSubscription else { return [] }
  guard !data.subscriberState.isEnterpriseSubscriber else { return [] }
  // TODO: enterprise specific UI

  var content: [Node] = subscriptionPlanRows(subscription, data.upcomingInvoice)
  content.append(contentsOf: subscriptionTeamRow(data))
  content.append(contentsOf: subscriptionInvitesRowView(data.teamInvites))
  content.append(contentsOf: subscriptionInviteMoreRowView(data))
  content.append(contentsOf: subscriptionPaymentInfoView(subscription))

  return [
    gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
      gridColumn(sizes: [.mobile: 12], [
        div([
          h2([`class`([Class.pf.type.responsiveTitle4])], ["Subscription overview"]),
          gridColumn(sizes: [.mobile: 12], content)
          ])
        ])
      ])
  ]
}

private func subscriptionTeammateOverview(_ data: AccountData) -> [Node] {
  guard data.stripeSubscription != nil else { return [] }

  return [
    gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
      gridColumn(sizes: [.mobile: 12], [
        div([
          h2([`class`([Class.pf.type.responsiveTitle4])], ["Subscription overview"]),

          p([
            "You are currently on a team subscription. Contact ",
            a(
              [
                mailto(data.subscriptionOwner?.email.rawValue ?? ""),
                `class`([Class.pf.colors.link.purple])
              ],
              [
                .text(data.subscriptionOwner?.name ?? "the owner")
              ]
            ),
            " for more information.",
            ]),

          form([action(path(to: .team(.leave))), method(.post)], [
            input(
              [
                `class`([Class.pf.components.button(color: .red, size: .small)]),
                type(.submit),
                value("Leave this team")
              ]
            )
            ]),
          ])
        ])
      ])
  ]
}

private func planName(for subscription: Stripe.Subscription) -> String {
  return subscription.quantity > 1
    ? subscription.plan.name + " (×" + String(subscription.quantity) + ")"
    : subscription.plan.name
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

public func nextBilling(for subscription: Stripe.Subscription, upcomingInvoice: Stripe.Invoice?) -> String {
  switch (subscription.status, upcomingInvoice) {
  case let (.active, .some(invoice)):
    return format(cents: invoice.amountDue)
      + " on "
      + dateFormatter.string(from: invoice.periodEnd)
  case (.canceled, _):
    return subscription.currentPeriodEnd > Current.date()
      ? "Cancels " + dateFormatter.string(from: subscription.currentPeriodEnd)
      : "Canceled"
  case (.active, .none), (.pastDue, _), (.unpaid, _), (.trialing, _):
    return "" // FIXME
  }
}

private func subscriptionPlanRows(_ subscription: Stripe.Subscription, _ upcomingInvoice: Stripe.Invoice?) -> [Node] {

  let planRow = gridRow([
    gridColumn(sizes: [.mobile: 3], [
      p([div(["Plan"])])
      ]),
    gridColumn(sizes: [.mobile: 9], [
      gridRow([
        gridColumn(sizes: [.mobile: 12, .desktop: 6], [
          div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
            p([.text(planName(for: subscription))])
            ])
          ]),
        gridColumn(sizes: [.mobile: 12, .desktop: 6], [
          div([`class`([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])], [
            p([mainAction(for: subscription)])
            ])
          ])
        ])
      ])
    ])

  let statusRow = gridRow([
    gridColumn(sizes: [.mobile: 3], [
      p([div(["Status"])])
      ]),
    gridColumn(sizes: [.mobile: 9], [
      gridRow([
        gridColumn(sizes: [.mobile: 12, .desktop: 6], [
          div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
            p([.text(status(for: subscription))])
            ])
          ])
        ])
      ])
    ])

  let nextBillingRow = subscription.cancelAtPeriodEnd || subscription.status == .canceled
    ? nil
    : gridRow([
      gridColumn(sizes: [.mobile: 3], [
        p([div(["Next billing"])])
        ]),
      gridColumn(sizes: [.mobile: 9], [
        div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
          p([.text(nextBilling(for: subscription, upcomingInvoice: upcomingInvoice))])
          ])
        ])
      ])

  let discountRow = subscription.discount.map { discount in
    gridRow([
      gridColumn(sizes: [.mobile: 3], [
        p([div(["Discount"])])
        ]),
      gridColumn(sizes: [.mobile: 9], [
        div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
          p([.text(discountDescription(for: discount))])
          ])
        ])
      ])
  }

  return [
    div(
      [`class`([Class.padding([.mobile: [.top: 1, .bottom: 3]])])],
      [planRow, statusRow] + [nextBillingRow, discountRow].compactMap(id)
    )
  ]
}

private func discountDescription(for discount: Stripe.Discount) -> String {
  return "\(discount.coupon.name ?? discount.coupon.id.rawValue): \(discount.coupon.formattedDescription)"
}

private func mainAction(for subscription: Stripe.Subscription) -> Node {
  if subscription.isCanceling {
    return form(
      [action(path(to: .account(.subscription(.reactivate)))), method(.post)],
      [
        button(
          [`class`([Class.pf.components.button(color: .purple, size: .small)])],
          ["Reactivate"]
        )
      ]
    )
  } else if subscription.status == .canceled {
    return a(
      [
        `class`([Class.pf.components.button(color: .purple, size: .small)]),
        href(path(to: .pricing(nil, expand: nil)))
      ],
      ["Resubscribe"]
    )
  } else {
    return a(
      [
        `class`([Class.pf.components.button(color: .purple, size: .small)]),
        href(path(to: .account(.subscription(.change(.show)))))
      ],
      ["Modify subscription"]
    )
  }
}

private func subscriptionTeamRow(_ data: AccountData) -> [Node] {
  guard
    !data.teammates.isEmpty,
    data.isTeamSubscription,
    !data.subscriberState.isEnterpriseSubscriber
    else { return [] }

  return [
    gridRow([`class`([subscriptionInfoRowClass])], [
      gridColumn(sizes: [.mobile: 3], [
        div([
          p(["Team"])
          ])
        ]),
      gridColumn(sizes: [.mobile: 9], [
        div([`class`([Class.padding([.mobile: [.leftRight: 1]])])],
            [p(["Your current team:"])]
              + data.teammates.map { teammateRowView(data.currentUser, $0) }
        )
        ])
      ])
  ]
}

private func teammateRowView(_ currentUser: User, _ teammate: User) -> Node {

  let teammateLabel = currentUser.id == teammate.id
    ? "\(teammate.displayName) (you)"
    : teammate.name.map { "\($0) (\(teammate.email))" } ?? teammate.email.rawValue

  return gridRow([
    gridColumn(sizes: [.mobile: 8], [p([.text(teammateLabel)])]),
    gridColumn(sizes: [.mobile: 4], [`class`([Class.grid.end(.desktop)])], [
      form([action(path(to: .team(.remove(teammate.id)))), method(.post)], [
        p([input([type(.submit), `class`([Class.pf.components.button(color: .purple, size: .small)]), value("Remove")])])
        ]),
      ])
    ])
}

private func subscriptionInvitesRowView(_ invites: [TeamInvite]) -> [Node] {
  guard !invites.isEmpty else { return [] }

  return [
    gridRow([`class`([subscriptionInfoRowClass])], [
      gridColumn(sizes: [.mobile: 3], [
        div([
          p(["Invites"])
          ])
        ]),
      gridColumn(sizes: [.mobile: 9], [
        div([`class`([Class.padding([.mobile: [.leftRight: 1]])])],
            [p(["These teammates have been invited, but have not yet accepted."])]
              <> invites.map(inviteRowView))
        ])
      ])
  ]
}

private func inviteRowView(_ invite: TeamInvite) -> Node {
  return gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 6], [
      p([.text(invite.email.rawValue)])
      ]),
    gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.grid.end(.desktop)])], [
      form([action(path(to: .invite(.resend(invite.id)))), method(.post), `class`([Class.display.inlineBlock])], [
        p([input([type(.submit), `class`([Class.pf.components.button(color: .purple, size: .small)]), value("Resend")])
          ])]),

      form([action(path(to: .invite(.revoke(invite.id)))), method(.post), `class`([Class.display.inlineBlock, Class.padding([.mobile: [.left: 1], .desktop: [.left: 2]])])], [
        p([input([type(.submit), `class`([Class.pf.components.button(color: .red, size: .small, style: .underline)]), value("Revoke")])
          ])]),
      ]),
    ])
}

private func subscriptionInviteMoreRowView(_ data: AccountData) -> [Node] {

  guard !data.subscriberState.isEnterpriseSubscriber else { return [] }
  guard let subscription = data.stripeSubscription else { return [] }
  guard subscription.quantity > 1 else { return [] }
  let invites = data.teamInvites
  let teammates = data.teammates
  let invitesRemaining = subscription.quantity - invites.count - teammates.count
  guard invitesRemaining > 0 else { return [] }

  return [
    gridRow([`class`([subscriptionInfoRowClass])], [
      gridColumn(sizes: [.mobile: 3], [
        div([
          p(["Invite more"])
          ])
        ]),
      gridColumn(sizes: [.mobile: 9], [
        div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
          p([.text("You have \(invitesRemaining) open spots on your team. Invite a team member below:")]),

          form([
            action(path(to: .invite(.send(nil)))), method(.post),
            `class`([Class.flex.flex])
            ], [
              input([
                `class`([smallInputClass, Class.align.middle, Class.size.width100pct]),
                name("email"),
                placeholder("blob@example.com"),
                type(.email),
                ]),
              input([
                type(.submit),
                `class`([
                  Class.pf.components.button(color: .purple, size: .small),
                  Class.align.middle,
                  Class.margin([.mobile: [.left: 1], .desktop: [.left: 2]])
                  ]),
                value("Invite")])
            ])
          ])
        ])
      ])
  ]
}

private func subscriptionPaymentInfoView(_ subscription: Stripe.Subscription) -> [Node] {
  guard let card = subscription.customer.right?.sources.data.first else { return [] }

  return [
    gridRow([`class`([subscriptionInfoRowClass])], [
      gridColumn(sizes: [.mobile: 3], [
        div([
          p(["Payment"])
          ])
        ]),
      gridColumn(sizes: [.desktop: 9], [
        gridRow([
          gridColumn(sizes: [.mobile: 12, .desktop: 6], [
            div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
              p([.text(card.brand.rawValue + " ending in " + String(card.last4))]),
              p([.text("Expires " + String(card.expMonth) + "/" + String(card.expYear))]),
              ])
            ]),
          gridColumn(sizes: [.mobile: 12, .desktop: 6], [
            div([`class`([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])], [
              p([
                a([
                  `class`([Class.pf.components.button(color: .purple, size: .small)]),
                  href(path(to: .account(.paymentInfo(.show(expand: nil))))),
                  ],
                  ["Update payment method"])
                ]),
              p([
                a([
                  `class`([Class.pf.components.button(color: .black, size: .small, style: .underline)]),
                  href(path(to: .account(.invoices(.index)))),
                  ],
                  ["Payment history"])
                ])
              ])
            ])
          ])
        ])
      ])
  ]
}

public func format(cents: Cents<Int>) -> String {
  let dollars = NSNumber(value: Double(cents.rawValue) / 100)
  return currencyFormatter.string(from: dollars)
    ?? NumberFormatter.localizedString(from: dollars, number: .currency)
}

private let logoutView = gridRow([
  gridColumn(sizes: [.mobile: 12], [
    a([`class`([Class.pf.components.button(color: .black)]), href(path(to: .logout))], ["Logout"])
    ])
  ])

private let subscriptionInfoRowClass =
  Class.border.top
    | Class.pf.colors.border.gray800
    | Class.padding([.mobile: [.top: 2, .bottom: 3]])

let labelClass =
  Class.h5
    | Class.type.bold
    | Class.display.block
    | Class.margin([.mobile: [.bottom: 1]])

let baseInputClass =
  Class.type.fontFamily.inherit
    | Class.pf.colors.fg.black
    | ".border-box"
    | Class.border.rounded.all
    | Class.border.all
    | Class.pf.colors.border.gray800

let regularInputClass =
  baseInputClass
    | Class.size.height(rem: 3)
    | Class.padding([.mobile: [.all: 1]])
    | Class.margin([.mobile: [.bottom: 2]])

let smallInputClass =
  baseInputClass
    | Class.size.height(rem: 2)
    | Class.padding([.mobile: [.all: 1]])

let blockInputClass =
  regularInputClass
    | Class.size.width100pct
    | Class.display.block

let blockSelectClass =
  Class.display.block
    | Class.margin([.mobile: [.bottom: 2]])
    | Class.size.height(rem: 3)
    | Class.size.width100pct
    | Class.pf.colors.border.gray800
    | Class.type.fontFamily.inherit

private struct AccountData {
  let currentUser: User
  let emailSettings: [EmailSetting]
  let episodeCredits: [EpisodeCredit]
  let stripeSubscription: Stripe.Subscription?
  let subscriberState: SubscriberState
  let subscription: Models.Subscription?
  let subscriptionOwner: User?
  let teamInvites: [TeamInvite]
  let teammates: [User]
  let upcomingInvoice: Stripe.Invoice?

  var isSubscriptionOwner: Bool {
    return self.currentUser.id == self.subscriptionOwner?.id
  }

  var isTeamSubscription: Bool {
    guard let id = self.stripeSubscription?.plan.id else { return false }
    return id == .teamMonthly || id == .teamYearly
  }
}
