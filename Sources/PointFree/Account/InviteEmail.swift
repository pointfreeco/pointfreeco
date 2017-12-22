@testable import Css
import Html
import HtmlCssSupport
import Prelude
import Styleguide

let teamInviteEmailView: View<(Database.User, Database.TeamInvite)> = simpleEmailLayout(
  title: { inviter, _ in
    "You’re invited to join \(inviter.name)’s team on Point-Free"
}, preheader: { inviter, _ in
  "Your colleage \(inviter.name) has invited you to join their team account on Point-Free."
}, bodyView: View { inviter, invite in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], ["You’re invited!"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            "Your colleague ",
            .text(encode(inviter.name)),
            """
             has invited you to join their team account on Point-Free, a weekly video series discussing
            functional programming and the Swift programming language. To accept, simply click the link below!
            """
            ]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([
              href(url(to: .invite(.show(invite.id)))),
              `class`([Class.pf.components.button(color: .purple)])
              ],
              ["Click here to accept!"])
            ])
          ])
        ])
      ])
    ])
  }
)

let inviteeAcceptedEmailView: View<(Database.User, Database.User)> = simpleEmailLayout(
  title: { _ in "Your invitation was accepted!" },
  bodyView: View { inviter, invitee in
    emailTable([style(contentTableStyles)], [
      tr([
        td([valign(.top)], [
          h3([`class`([Class.pf.type.title3]), `class`([Class.padding([.mobile: [.bottom: 2]])])], [
            "Your invitation was accepted!"
            ]),
          p([
            "Hey ", .text(encode(inviter.name)), "!"
            ]),
          p([
            "Your colleague ",
            .text(encode(invitee.name)),
            " has accepted your invitation! They now have full access to everything Point-Free has to offer. "
            ]),

          p([
            "To review your who is on your team, ",
            a([href(url(to: .account))], ["click here"]),
            "."
            ])
          ])
        ])
      ])
  }
)
