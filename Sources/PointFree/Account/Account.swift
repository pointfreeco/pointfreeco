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
  requireUser
    <| fetchAccountData
    >-> writeStatus(.ok)
    >-> respond(accountView.contramap(lower))

func fetchAccountData<I, A>(
  _ conn: Conn<I, Tuple2<Database.User, A>>
  ) -> IO<Conn<I, Tuple5<Database.User, Database.Subscription?, [Database.TeamInvite], [Database.User], A>>> {

  let (user, rest) = lower(conn.data)

  let subscription = user.subscriptionId
    .map {
      AppEnvironment.current.database.fetchSubscriptionById($0)
        .mapExcept(requireSome)
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
    .map { conn.map(const(user .*. $0 .*. $1 .*. $2 .*. rest)) }
}

let accountView = View<(Database.User, Database.Subscription?, [Database.TeamInvite], [Database.User], Prelude.Unit)> { currentUser, subscription, teamInvites, teammates, _ in

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

        form([action("#"), method(.post)], [
          label([`class`([labelClass])], ["Name"]),
          input([`class`([blockInputClass]), type(.text), value(currentUser.name)]),

          label([`class`([labelClass])], ["Email"]),
          input([`class`([blockInputClass]), type(.email), value(currentUser.email.unwrap)]),

          label([`class`([Class.display.block])], [
            input([type(.checkbox), `class`([Class.margin([.mobile: [.right: 1]])])]),
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

private let subscriptionRowView = View<(Database.Subscription?, [Database.TeamInvite], [Database.User])> { subscription, invites, teammates -> [Node] in
  guard let subscription = subscription else { return [] }

  return [
    gridRow([`class`([Class.padding([.mobile: [.bottom: 4]])])], [
      gridColumn(sizes: [.mobile: 12], [
        div([
          h2([`class`([Class.pf.type.title4])], ["Subscription overview"]),

          gridColumn(
            sizes: [.mobile: 12],
            subscriptionPlanRow.view(subscription)
              <> subscriptionTeamRow.view(teammates)
              <> subscriptionInvitesRowView.view(invites)
              <> subscriptionInviteMoreRowView.view(unit)
              <> subscriptionPaymentInfoView.view(unit))
          ])
        ])
      ])
  ]
}

private let subscriptionPlanRow = View<Database.Subscription?> { _ in
  gridRow([`class`([subscriptionInfoRowClass])], [
    gridColumn(sizes: [.mobile: 2], [
      div([
        "Plan"
        ])
      ]),
    gridColumn(sizes: [.mobile: 10], [
      div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
        "Yearly Team"
        ])
      ])
    ])
}

private let subscriptionTeamRow = View<[Database.User]> { teammates -> [Node] in
  guard !teammates.isEmpty else { return [] }

  return [
    gridRow([`class`([subscriptionInfoRowClass])], [
      gridColumn(sizes: [.mobile: 2], [
        div([
          p(["Team"])
          ])
        ]),
      gridColumn(sizes: [.mobile: 10], [
        div([`class`([Class.padding([.mobile: [.leftRight: 1]])])],
            [p(["Your current team:"])]
              <> teammates.flatMap(teammateRowView.view)
        )
        ])
      ])
  ]
}

private let teammateRowView = View<Database.User> { teammate in
  gridRow([`class`([Class.margin([.mobile: [.top: 2]])])], [
    gridColumn(sizes: [:], [
      .text(encode("\(teammate.name) (\(teammate.email.unwrap))"))
      ]),
    gridColumn(sizes: [:], [`class`([Class.grid.end(.mobile)])], [
      form([action(path(to: .team(.remove(teammate.id)))), method(.post)], [
        input([type(.submit), `class`([Class.pf.components.button(color: .purple, size: .small)]), value("Remove")])
        ]),
      ])
    ])
}

private let subscriptionInvitesRowView = View<[Database.TeamInvite]> { invites -> [Node] in
  guard !invites.isEmpty else { return [] }

  return [
    gridRow([`class`([subscriptionInfoRowClass])], [
      gridColumn(sizes: [.mobile: 2], [
        div([
          p(["Invites"])
          ])
        ]),
      gridColumn(sizes: [.mobile: 10], [
        div([`class`([Class.padding([.mobile: [.leftRight: 1]])])],
            [p(["These teammates have been invited, but have not yet accepted."])]
              <> invites.flatMap(inviteRowView.view))
        ])
      ])
  ]
}

private let inviteRowView = View<Database.TeamInvite> { invite in
  gridRow([`class`([Class.margin([.mobile: [.top: 2]])])], [
    gridColumn(sizes: [:], [
      .text(encode(invite.email.unwrap))
      ]),
    gridColumn(sizes: [:], [`class`([Class.grid.end(.mobile)])], [
      form([action(path(to: .invite(.resend(invite.id)))), method(.post), `class`([Class.display.inlineBlock])], [
        input([type(.submit), `class`([Class.pf.components.button(color: .purple, size: .small)]), value("Resend")])
        ]),

      form([action(path(to: .invite(.revoke(invite.id)))), method(.post), `class`([Class.display.inlineBlock, Class.padding([.mobile: [.left: 2]])])], [
        input([type(.submit), `class`([Class.pf.components.button(color: .purple, size: .small)]), value("Revoke")])
        ]),
      ]),
    ])
}

private let subscriptionInviteMoreRowView = View<Prelude.Unit> { _ in
  gridRow([`class`([subscriptionInfoRowClass])], [
    gridColumn(sizes: [.mobile: 2], [
      div([
        p(["Invite more"])
        ])
      ]),
    gridColumn(sizes: [.mobile: 10], [
      div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
        p(["You have 10 open spots on your team. Invite a team member below:"]),

        form([action(path(to: .invite(.send(nil)))), method(.post)], [
          input([
            type(.email),
            `class`([smallInputClass, Class.align.middle]),
            name("email")]),

          input([
            type(.submit),
            `class`([
              Class.pf.components.button(color: .purple, size: .small),
              Class.align.middle,
              Class.margin([.mobile: [.left: 1]])
              ]),
            value("Add team member")])
          ])
        ])
      ])
    ])
}

private let subscriptionPaymentInfoView = View<Prelude.Unit> { _ in
  gridRow([`class`([subscriptionInfoRowClass])], [
    gridColumn(sizes: [.mobile: 3, .desktop: 2], [
      div([
        p(["Payment"])
        ])
      ]),
    gridColumn(sizes: [.mobile: 9, .desktop: 5], [
      div([`class`([Class.padding([.mobile: [.leftRight: 1]])])], [
        p(["American Express 3*** ****** *2002"]),
        p(["Expiration: 1/2018"]),
        p(["Next payment due: 2017-12-24"]),
        p(["Total Amount: $18.00"])
        ])
      ]),
    gridColumn(sizes: [.mobile: 12, .desktop: 5], [
      div([`class`([Class.grid.end(.mobile)])], [
        p([
          a([href("#"), `class`([Class.pf.components.button(color: .purple, size: .small)])], ["Update payment method"])
          ])
        ])
      ])
    ])
}

private let logoutView = View<Prelude.Unit> { _ in
  gridRow([
    gridColumn(sizes: [.mobile: 12], [
      a([`class`([Class.pf.components.button(color: .black)]), href(path(to: .logout))], ["Logout"])
      ])
    ])
}

private let subscriptionInfoRowClass =
  Class.border.bottom
    | Class.pf.colors.border.gray800
    | Class.padding([.mobile: [.topBottom: 3]])

private let labelClass =
  Class.h5
    | Class.type.bold
    | Class.display.block
    | Class.margin([.mobile: [.bottom: 1]])

private let baseInputClass =
  Class.type.fontFamilyInherit
    | Class.type.fontFamilyInherit
    | Class.pf.colors.fg.black
    | ".border-box"
    | Class.border.rounded.all
    | Class.border.all
    | Class.pf.colors.border.gray800

private let regularInputClass =
  baseInputClass
    | Class.size.height(rem: 3)
    | Class.padding([.mobile: [.all: 1]])
    | Class.margin([.mobile: [.bottom: 2]])

private let smallInputClass =
  baseInputClass
    | Class.size.height(rem: 2)
    | Class.padding([.mobile: [.all: 1]])

private let blockInputClass =
  regularInputClass
    | Class.size.width100pct
    | Class.display.block
