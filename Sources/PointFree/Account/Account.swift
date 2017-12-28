import Css
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
  filterMap(require1)
    <| fetchAccountData
    >-> writeStatus(.ok)
    >-> respond(accountView.contramap(lower))

func fetchAccountData<I, A>(
  _ conn: Conn<I, T2<Database.User, A>>
  ) -> IO<Conn<I, T5<Stripe.Subscription?, [Database.TeamInvite], [Database.User], Database.User, A>>> {

  let user = get1(conn.data)

  let subscription = user.subscriptionId
    .map {
      AppEnvironment.current.database.fetchSubscriptionById($0)
        .mapExcept(requireSome)
        .withExcept(const(unit))
        .flatMap { AppEnvironment.current.stripe.fetchSubscription($0.stripeSubscriptionId) }
        .run
        .map(^\.right)
    }
    ?? pure(nil)

  return sequential(
    zip(
      parallel(subscription),

      parallel(AppEnvironment.current.database.fetchTeamInvites(user.id).run)
        .map { $0.right ?? [] },

      parallel(AppEnvironment.current.database.fetchSubscriptionTeammatesByOwnerId(user.id).run)
        .map { $0.right ?? [] }
    )
    )
    .map { conn.map(const($0 .*. $1 .*. $2 .*. conn.data)) }
}

let accountView = View<(Stripe.Subscription?, [Database.TeamInvite], [Database.User], Database.User)> { subscription, teamInvites, teammates, currentUser in

  document([
    html([
      head([
        style(renderedNormalizeCss),
        style(styleguide),
        style(render(config: pretty, css: pricingExtraStyles)),
        meta(viewport: .width(.deviceWidth), .initialScale(1)),
        ]),
      body(
        darkNavView.view((currentUser, nil))
          <> [
            gridRow([
              gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))],  [
                div([`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
                    titleRowView.view(unit)
                      <> profileRowView.view(currentUser)
                      <> subscriptionRowView.view((subscription, teamInvites, teammates))
                      <> logoutView.view(unit))
                ])
              ])
          ]
          <> footerView.view(unit)
      )
      ])
    ])
}

private let titleRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h1([`class`([Class.pf.type.title2])], ["Account"])
        ])
      ])
    ])
}

private let profileRowView = View<Database.User> { currentUser in
  gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
    gridColumn(sizes: [.mobile: 12], [
      div([
        h2([`class`([Class.pf.type.title4])], ["Profile"]),

        form([action(path(to: .updateProfile(nil))), method(.post)], [
          label([`class`([labelClass])], ["Name"]),
          input([
            `class`([blockInputClass]),
            name(Database.User.CodingKeys.name.stringValue),
            type(.text),
            value(currentUser.name),
            ]),

          label([`class`([labelClass])], ["Email"]),
          input([
            `class`([blockInputClass]),
            name(Database.User.CodingKeys.email.stringValue),
            type(.email),
            value(currentUser.email.unwrap)
            ]),

          label([`class`([Class.display.block])], [
            input(
              [
                type(.checkbox),
                checked(false), // FIXME
                `class`([Class.margin([.mobile: [.right: 1]])])
              ]
            ),
            "Receive emails from us"
            ]),

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

private let subscriptionRowView = View<(Stripe.Subscription?, [Database.TeamInvite], [Database.User])> { subscription, invites, teammates -> [Node] in
  guard let subscription = subscription else { return [] }

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
    let currentPeriodEndString = subscription.currentPeriodEnd
      .map { subscription.cancelAtPeriodEnd ? " through " + dateFormatter.string(from: $0) : "" } ?? ""
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
    let totalAmountString = totalAmount(for: subscription) ?? ""
    let currentPeriodEndString = subscription.currentPeriodEnd
      .map { " on " + dateFormatter.string(from: $0) } ?? ""
    return totalAmountString + currentPeriodEndString
  case .canceled:
    return subscription.currentPeriodEnd
      .filterOptional { $0 > AppEnvironment.current.date() }
      .map { "Cancels " + dateFormatter.string(from: $0) }
      ?? "Canceled"
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
              p([
                a([
                  `class`([Class.pf.components.button(color: .purple, size: .small)]),
                  href("#")
                  ],
                  ["Upgrade"]) // TODO: disable when subscription.status == .canceled
                ])
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
            ]),
          gridColumn(sizes: [.mobile: 12, .desktop: 6], [
            div([`class`([Class.padding([.mobile: [.leftRight: 1]]), Class.grid.end(.desktop)])], [
              p([mainAction(for: subscription)])
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
      [action(path(to: .reactivate)), method(.post)],
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
        href(path(to: .pricing(nil, nil)))
      ],
      ["Resubscribe"]
    )
  } else {
    return a(
      [
        `class`([Class.pf.components.button(color: .red, size: .small, style: .underline)]),
        href(path(to: .confirmCancel))
      ],
      ["Cancel"]
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
      p([.text(encode("\(teammate.name) (\(teammate.email.unwrap))"))])
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
        p([input([type(.submit), `class`([Class.pf.components.button(color: .purple, size: .small)]), value("Revoke")])
        ])]),
      ]),
    ])
}

private let subscriptionInviteMoreRowView = View<(Stripe.Subscription?, [Database.TeamInvite], [Database.User])> { subscription, invites, teammates -> [Node] in

  guard let subscription = subscription else { return [] }
  guard subscription.quantity > 1 else { return [] }
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
                  href(path(to: .paymentInfo)),
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

private func totalAmount(for subscription: Stripe.Subscription) -> String? {
  let totalCents = subscription.plan.amount.rawValue * subscription.quantity
  let totalDollars = Double(totalCents) / 100
  return currencyFormatter.string(from: NSNumber(value: totalDollars))
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
    | Class.type.fontFamilyInherit
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
