import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

let accountResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <| fetchAccountData
    >-> writeStatus(.ok)
    >-> map(lower)
    >>> respond(text: "yo")
//    >>> respond(
//      view: accountView,
//      layoutData: { subscription, teamInvites, teammates, emailSettings, currentUser, subscriptionStatus in
//        SimplePageLayoutData(
//          currentSubscriptionStatus: subscriptionStatus,
//          currentUser: currentUser,
//          data: (subscription, teamInvites, teammates, emailSettings, [], currentUser),
//          title: "Account"
//        )
//    }
//)

private func fetchAccountData<I, A>(
  _ conn: Conn<I, T2<Database.User, A>>
  ) -> IO<Conn<I, T6<Stripe.Subscription?, [Database.TeamInvite], [Database.User], [Database.EmailSetting], Database.User, A>>> {

  let user = get1(conn.data)

  let subscription = user.subscriptionId
    .map(
      (
        AppEnvironment.current.database.fetchSubscriptionById
          >>> mapExcept(requireSome)
          >>> map(^\.stripeSubscriptionId)
          >-> AppEnvironment.current.stripe.fetchSubscription
        )
        >>> ^\.run
        >>> map(^\.right)
    )
    ?? pure(nil)

  return zip5(
//    subscription.parallel,
//
//    AppEnvironment.current.database.fetchTeamInvites(user.id).run.parallel
//      .map { $0.right ?? [] },
//
//    AppEnvironment.current.database.fetchSubscriptionTeammatesByOwnerId(user.id).run.parallel
//      .map { $0.right ?? [] },
//
//    AppEnvironment.current.database.fetchEmailSettingsForUserId(user.id).run.parallel
//      .map { $0.right ?? [] },
//
//    AppEnvironment.current.database.fetchEpisodeCredits(user.id).run.parallel
//      .map { $0.right ?? [] }

    pure(nil),
    pure([]),
    pure([]),
    pure([])
    , pure([])
    )
    .map { conn.map(const($0.0 .*. $0.1 .*. $0.2 .*. $0.3 .*. conn.data)) }
    .sequential
}

let accountView = View<(Stripe.Subscription?, [Database.TeamInvite], [Database.User], [Database.EmailSetting], [Database.EpisodeCredit], Database.User)> { subscription, teamInvites, teammates, emailSettings, episodeCredits, currentUser in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
          titleRowView.view(unit)
            <> profileRowView.view((currentUser, emailSettings))
            <> subscriptionRowView.view((currentUser, subscription, teamInvites, teammates))
            <> creditsView.view((subscription, currentUser, episodeCredits))
            <> logoutView.view(unit)
      )
      ])
    ])
}

private let creditsView = View<(Stripe.Subscription?, Database.User, [Database.EpisodeCredit])> {
  subscription, currentUser, credits -> [Node] in

  guard subscription?.status != .some(.active) else { return [] }
  guard currentUser.episodeCreditCount > 0 || credits.count > 0 else { return [] }

  return [
    gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
      gridColumn(sizes: [.mobile: 12], [
        div(
          [
            h2([`class`([Class.pf.type.title4])], ["Episode Credits"]),
            p([
              "Episode credits allow you to see subscriber-only episodes before commiting to a full ",
              text("subscription. You currently have \(currentUser.episodeCreditCount) credits "),
              "remaining."
              ]),
            p([
              "To get all past and future episodes, ",
              a([`class`([Class.pf.colors.link.purple]), href(path(to: .pricing(nil, expand: nil)))], ["become"]),
              " a subscriber today!"
              ])
            ]
            <> episodeCreditsView.view(credits)
        )
        ])
      ])
  ]
}

private let episodeCreditsView = View<[Database.EpisodeCredit]> { credits -> [Node] in
  guard credits.count > 0 else { return [] }

  return [
    h3(
      [
        `class`(
          [
            Class.pf.type.title5,
            Class.padding([.mobile: [.top: 2]])
          ]
        ),
        ],
      ["Chosen episodes"]
    ),

    ul(
      episodes(from: credits)
        .reversed()
        .map { ep in li(episodeLinkView.view(ep)) }
    )
  ]
}

private let episodeLinkView = View<Episode> { episode in
  a(
    [
      href(path(to: .episode(.left(episode.slug)))),
      `class`(
        [
          Class.pf.colors.link.purple
        ]
      )
    ],
    [.text(encode("#\(episode.sequence): \(episode.title)"))]
  )
}

private func episodes(from credits: [Database.EpisodeCredit]) -> [Episode] {
  return AppEnvironment.current.episodes()
    .filter { ep in credits.contains(where: { $0.episodeSequence == ep.sequence }) }
}

private func episode(atSequence sequence: Int) -> Episode? {
  return AppEnvironment.current.episodes()
    .first(where: { $0.sequence == sequence })
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 2]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title2])], ["Account"])
        ])
      ])
    ])
}

private let profileRowView = View<(Database.User, [Database.EmailSetting])> { currentUser, currentEmailSettings in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h2([`class`([Class.pf.type.title4])], ["Profile"]),

        form([action(path(to: .account(.update(nil)))), method(.post)], [
          label([`class`([labelClass])], ["Name"]),
          input([
            `class`([blockInputClass]),
            name(ProfileData.CodingKeys.name.stringValue),
            type(.text),
            value(currentUser.name ?? ""),
            ]),

          label([`class`([labelClass])], ["Email"]),
          input([
            `class`([blockInputClass]),
            name(ProfileData.CodingKeys.email.stringValue),
            type(.email),
            value(currentUser.email.unwrap)
            ]),

          ] + emailSettingCheckboxes.view(currentEmailSettings) + [

            input([
              type(.submit),
              `class`([Class.pf.components.button(color: .purple), Class.margin([.mobile: [.top: 3]])]),
              value("Update profile")
              ])
          ])
        ])
      ])
    ])
}

private let emailSettingCheckboxes = View<[Database.EmailSetting]> { currentEmailSettings in
  [
    p(["Receive email when:"]),
    p([`class`([Class.padding([.mobile: [.left: 1]])])], Database.EmailSetting.Newsletter.allNewsletters.map { newsletter in
      label([`class`([Class.display.block])], [
        input(
          [
            type(.checkbox),
            name("emailSettings[\(newsletter.rawValue)]"),
            checked(currentEmailSettings.contains(where: ^\.newsletter == newsletter)),
            `class`([Class.margin([.mobile: [.right: 1]])])
          ]
        ),
        .text(encode(newsletterDescription(newsletter)))
        ])
    })
  ]
}

private func newsletterDescription(_ type: Database.EmailSetting.Newsletter) -> String {
  switch type {
  case .announcements:
    return "New announcements (very infrequently)"
  case .newEpisode:
    return "New episode is available (about once a week)"
  }
}

private let subscriptionRowView = View<(Database.User, Stripe.Subscription?, [Database.TeamInvite], [Database.User])> { currentUser, subscription, invites, allTeammates -> [Node] in
  guard let subscription = subscription else { return [] }

  let teammates = allTeammates.filter(^\.id.unwrap != currentUser.id.unwrap)

  return [
    gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
      gridColumn(sizes: [.mobile: 12], [
        div([
          h2([`class`([Class.pf.type.title4])], ["Subscription overview"]),

          gridColumn(
            sizes: [.mobile: 12],
            subscriptionPlanRows.view(subscription)
              <> subscriptionTeamRow.view(teammates)
              <> subscriptionInvitesRowView.view(invites)
              <> subscriptionInviteMoreRowView.view((subscription, invites, teammates))
              <> subscriptionPaymentInfoView.view(subscription)
          )
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

public func nextBilling(for subscription: Stripe.Subscription) -> String {
  switch subscription.status {
  case .active:
    return totalAmount(for: subscription)
      + " on "
      + dateFormatter.string(from: subscription.currentPeriodEnd)
  case .canceled:
    return subscription.currentPeriodEnd > AppEnvironment.current.date()
      ? "Cancels " + dateFormatter.string(from: subscription.currentPeriodEnd)
      : "Canceled"
  case .pastDue:
    return "" // FIXME
  case .unpaid:
    return "" // FIXME
  case .trialing:
    return "" // FIXME
  }
}

private let subscriptionPlanRows = View<Stripe.Subscription> { subscription in
  return div([`class`([Class.padding([.mobile: [.top: 1, .bottom: 3]])])], [
    gridRow([
      gridColumn(sizes: [.mobile: 3], [
        p([div(["Plan"])])
        ]),
      gridColumn(sizes: [.mobile: 9], [
        gridRow([
          gridColumn(sizes: [.mobile: 12, .desktop: 6], [
            div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
              p([text(planName(for: subscription))])
              ])
            ]),
          gridColumn(sizes: [.mobile: 12, .desktop: 6], [
            div([`class`([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])], [
              p([mainAction(for: subscription)])
              ])
            ])
          ])
        ])
      ]),
    gridRow([
      gridColumn(sizes: [.mobile: 3], [
        p([div(["Status"])])
        ]),
      gridColumn(sizes: [.mobile: 9], [
        gridRow([
          gridColumn(sizes: [.mobile: 12, .desktop: 6], [
            div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
              p([text(status(for: subscription))])
              ])
            ])
          ])
        ])
      ])
    ]
    + (
      subscription.cancelAtPeriodEnd || subscription.status == .canceled
        ? []
        : [
          gridRow([
            gridColumn(sizes: [.mobile: 3], [
              p([div(["Next billing"])])
              ]),
            gridColumn(sizes: [.mobile: 9], [
              div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
                p([text(nextBilling(for: subscription))])
                ])
              ])
            ])
      ]
    )
  )
}

private func mainAction(for subscription: Stripe.Subscription) -> Node {
  if subscription.cancelAtPeriodEnd {
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

private let subscriptionTeamRow = View<[Database.User]> { teammates -> [Node] in
  guard !teammates.isEmpty else { return [] }

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
              <> teammates.flatMap(teammateRowView.view)
        )
        ])
      ])
  ]
}

private let teammateRowView = View<Database.User> { teammate in
  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 6], [
      p([.text(encode("\(teammate.name ?? teammate.email.unwrap) (\(teammate.email.unwrap))"))])
      ]),
    gridColumn(sizes: [.mobile: 12, .desktop: 6], [`class`([Class.grid.end(.desktop)])], [
      form([action(path(to: .team(.remove(teammate.id)))), method(.post)], [
        p([input([type(.submit), `class`([Class.pf.components.button(color: .purple, size: .small)]), value("Remove")])])
        ]),
      ])
    ])
}

private let subscriptionInvitesRowView = View<[Database.TeamInvite]> { invites -> [Node] in
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
              <> invites.flatMap(inviteRowView.view))
        ])
      ])
  ]
}

private let inviteRowView = View<Database.TeamInvite> { invite in
  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 6], [
      p([.text(encode(invite.email.unwrap))])
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

private let subscriptionInviteMoreRowView = View<(Stripe.Subscription?, [Database.TeamInvite], [Database.User])> { subscription, invites, teammates -> [Node] in

  guard let subscription = subscription else { return [] }
  guard subscription.quantity > 1 else { return [] }
  let invitesRemaining = subscription.quantity - invites.count - teammates.count - 1
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
          p([.text(encode("You have \(invitesRemaining) open spots on your team. Invite a team member below:"))]),

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

private let subscriptionPaymentInfoView = View<Stripe.Subscription> { subscription -> [Node] in
  guard let card = subscription.customer.sources.data.first else { return [] }

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
              p([text(card.brand.rawValue + " ending in " + String(card.last4))]),
              p([text("Expires " + String(card.expMonth) + "/" + String(card.expYear))]),
              ])
            ]),
          gridColumn(sizes: [.mobile: 12, .desktop: 6], [
            div([`class`([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])], [
              p([`class`([])], [
                a([
                  `class`([Class.pf.components.button(color: .purple, size: .small)]),
                  href(path(to: .account(.paymentInfo(.show(expand: nil))))),
                  ],
                  ["Update payment method"])
                ])
              ])
            ])
          ])
        ])
      ])
  ]
}

private func totalAmount(for subscription: Stripe.Subscription) -> String {
  let totalCents = subscription.plan.amount.rawValue * subscription.quantity
  let totalDollars = NSNumber(value: Double(totalCents) / 100)
  return currencyFormatter.string(from: totalDollars)
    ?? NumberFormatter.localizedString(from: totalDollars, number: .currency)
}

private let logoutView = View<Prelude.Unit> { _ in
  gridRow([
    gridColumn(sizes: [.mobile: 12], [
      a([`class`([Class.pf.components.button(color: .black)]), href(path(to: .logout))], ["Logout"])
      ])
    ])
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

let baseInputClass =
  Class.type.fontFamilyInherit
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
    | Class.type.fontFamilyInherit

