import Css
import Html
import HtmlCssSupport
import Prelude
import Styleguide

let teamInviteEmailView = View<(Database.User, Database.TeamInvite)> { inviter, invite in
  document([
    html([
      head([
        style(designSystems),
        style(emailBaseStyles)
        ]),

      body([
        table([border(0), cellpadding(0), cellspacing(0), height(.pct(100)), width(.pct(100))], [
          tr([
            td([align(.center), valign(.top)],
               inviteBodyView.view((inviter, invite))
                <> emailFooterView.view(unit))
            ])
          ])
        ])
      ])
    ])
}

private let inviteBodyView = View<(Database.User, Database.TeamInvite)> { inviter, invite in
  table([border(0), cellpadding(20), cellspacing(0), width(.px(600))], [
    tr([
      td([valign(.top)], [
        h3([`class`([Class.h3])], ["You've been invited!"]),
        p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
          "Your colleague ",
          .text(encode(inviter.name)),
          """
           has invited you to join their team account on Point-Free, a weekly video series discussing
          functional programming and the Swift language. To accept, simply click the link below!
          """
          ]),
        p([], [
          a([href(url(to: .invite(.show(invite.id))))], ["Click here!"])
          ])
        ])
      ])
    ])
}

let inviteeAcceptedEmailView = View<(Database.User, Database.User)> { inviter, invitee in
  document([
    html([
      head([
        style(designSystems),
        style(emailBaseStyles)
        ]),

      body([
        table([border(0), cellpadding(0), cellspacing(0), height(.pct(100)), width(.pct(100))], [
          tr([
            td([align(.center), valign(.top)],
               acceptanceBodyView.view((inviter, invitee))
                <> emailFooterView.view(unit))
            ])
          ])
        ])
      ])
    ])
}

private let acceptanceBodyView = View<(Database.User, Database.User)> { inviter, invitee in
  table([border(0), cellpadding(20), cellspacing(0), width(.px(600))], [
    tr([
      td([valign(.top)], [
        h3([`class`([Class.pf.type.title4])], ["Your invitation was accepted!"]),
        p(["Hey ", .text(encode(inviter.name)), "!"]),
        p([
          "Your colleague ",
          .text(encode(invitee.name)),
          " has accepted your invitation! They now have full access to everything Point-Free has to offer. "
          ]),

        p([
          "To review your team who all is on your team, ",
          a([href(url(to: .account))], ["click here"]),
          "."
          ])
        ])
      ])
    ])
}

private let emailFooterView = View<Prelude.Unit> { _ in
  table([`class`([Class.pf.colors.bg.gray900]), border(0), cellpadding(20), cellspacing(0), width(.px(600))], [
    tr([
      td([valign(.top)], [
        p([`class`([Class.pf.type.body.small])], [
          "Contact us via email at ",
          a([mailto("support@pointfree.co")], ["support@pointfree.co"]),
          ", or on Twitter ",
          a([href(twitterUrl(to: .pointfreeco))], ["@pointfreeco"]),
          "."
          ]),

        p([`class`([Class.pf.type.body.small])], [
          "Our postal address: 139 Skillman #5C, Brooklyn, NY 11211"
          ])
        ])
      ])
    ])
}
