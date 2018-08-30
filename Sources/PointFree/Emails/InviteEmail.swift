import Css
import Html
import HtmlCssSupport
import Prelude
import Styleguide
import View

let teamInviteEmailView = simpleEmailLayout(teamInviteEmailBodyView)
  .contramap { inviter, invite in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "You’re invited to join \(inviter.displayName)’s team on Point-Free",
      preheader: "Your colleague \(inviter.displayName) has invited you to join their team account on Point-Free.",
      template: .default,
      data: (inviter, invite)
    )
}

private let teamInviteEmailBodyView = View<(Database.User, Database.TeamInvite)> { inviter, invite in
  emailTable([style(contentTableStyles)], [
    tr([
      td([ // todo: valign(.top)], [
        div([Styleguide.class([Class.padding([.mobile: [.all: 2]])])], [
          h3([Styleguide.class([Class.pf.type.responsiveTitle3])], ["You’re invited!"]),
          p([Styleguide.class([Class.padding([.mobile: [.topBottom: 2]])])], [
            "Your colleague ",
            .text(inviter.displayName),
            """
             has invited you to join their team account on Point-Free, a video series about functional
            programming and the Swift programming language. To accept, simply click the link below!
            """
            ]),
          p([Styleguide.class([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([
              href(url(to: .invite(.show(invite.id)))),
              Styleguide.class([Class.pf.components.button(color: .purple)])
              ],
              ["Click here to accept!"])
            ])
          ])
        ])
      ])
    ])
}

let inviteeAcceptedEmailView = simpleEmailLayout(inviteeAcceptedEmailBodyView)
  .contramap { inviter, invitee in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "\(invitee.displayName) has accepted your invitation!",
      preheader: "",
      template: .default,
      data: (inviter, invitee)
    )
}

private let inviteeAcceptedEmailBodyView = View<(Database.User, Database.User)> { inviter, invitee in
  emailTable([style(contentTableStyles)], [
    tr([
      td([ // todo: valign(.top)], [
        h3([Styleguide.class([Class.pf.type.responsiveTitle3]), Styleguide.class([Class.padding([.mobile: [.bottom: 2]])])], [
          "Your invitation was accepted!"
          ]),
        p([
          "Hey ", .text(inviter.displayName), "!"
          ]),
        p([
          "Your colleague ",
          .text(invitee.displayName),
          " has accepted your invitation! They now have full access to everything Point-Free has to offer. "
          ]),

        p([
          "To review who is on your team, ",
          a([href(url(to: .account(.index)))], ["click here"]),
          "."
          ])
        ])
      ])
    ])
}
