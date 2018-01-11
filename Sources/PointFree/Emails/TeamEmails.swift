import Css
import Html
import HtmlCssSupport
import Prelude
import Styleguide

let youHaveBeenRemovedEmailView = simpleEmailLayout(youHaveBeenRemovedEmailBody)
  .contramap { teamOwner, teammate in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "You have been removed from \(teamOwner.name)’s Point-Free team",
      preheader: "",
      data: (teamOwner, teammate)
    )
}

private let youHaveBeenRemovedEmailBody = View<(Database.User, Database.User)> { teamOwner, teammate in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], ["Team removal"]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            text("""
              You have been removed from \(teamOwner.name)’s Point-Free team, which means you no longer
              have access to full episodes and transcripts. If you wish to subscribe to an individual plan,
              click the link below!
              """)
            ]),

          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([
              href(url(to: .pricing(nil, nil))),
              `class`([Class.pf.components.button(color: .purple)])
              ],
              ["See subscription plans"])
            ])
          ])
        ])
      ])
    ])
}

//parallel(sendEmail(
//  to: [teammate.email],
//  subject: "You have been removed from \(owner.name)’s Point-Free team",
//  content: inj1("You have been removed")
//  )
//  .run),
//parallel(sendEmail(
//to: [owner.email],
//subject: "Your teammate \(teammate.name) has been removed",
//content: inj1("EOM")
//)
//.run)

//
//let teamInviteEmailView = simpleEmailLayout(teamInviteEmailBodyView)
//  .contramap { inviter, invite in
//    SimpleEmailLayoutData(
//      user: nil,
//      newsletter: nil,
//      title: "You’re invited to join \(inviter.name)’s team on Point-Free",
//      preheader: "Your colleague \(inviter.name) has invited you to join their team account on Point-Free.",
//      data: (inviter, invite)
//    )
//}
//
//private let teamInviteEmailBodyView = View<(Database.User, Database.TeamInvite)> { inviter, invite in
//  emailTable([style(contentTableStyles)], [
//    tr([
//      td([valign(.top)], [
//        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
//          h3([`class`([Class.pf.type.title3])], ["You’re invited!"]),
//          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
//            "Your colleague ",
//            .text(encode(inviter.name)),
//            """
//             has invited you to join their team account on Point-Free, a weekly video series discussing
//            functional programming and the Swift programming language. To accept, simply click the link below!
//            """
//            ]),
//          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
//            a([
//              href(url(to: .invite(.show(invite.id)))),
//              `class`([Class.pf.components.button(color: .purple)])
//              ],
//              ["Click here to accept!"])
//            ])
//          ])
//        ])
//      ])
//    ])
//}
//
//let inviteeAcceptedEmailView = simpleEmailLayout(inviteeAcceptedEmailBodyView)
//  .contramap { inviter, invitee in
//    SimpleEmailLayoutData(
//      user: nil,
//      newsletter: nil,
//      title: "\(invitee.name) has accepted your invitation!",
//      preheader: "",
//      data: (inviter, invitee)
//    )
//}
//
//private let inviteeAcceptedEmailBodyView = View<(Database.User, Database.User)> { inviter, invitee in
//  emailTable([style(contentTableStyles)], [
//    tr([
//      td([valign(.top)], [
//        h3([`class`([Class.pf.type.title3]), `class`([Class.padding([.mobile: [.bottom: 2]])])], [
//          "Your invitation was accepted!"
//          ]),
//        p([
//          "Hey ", .text(encode(inviter.name)), "!"
//          ]),
//        p([
//          "Your colleague ",
//          .text(encode(invitee.name)),
//          " has accepted your invitation! They now have full access to everything Point-Free has to offer. "
//          ]),
//
//        p([
//          "To review who is on your team, ",
//          a([href(url(to: .account(.index)))], ["click here"]),
//          "."
//          ])
//        ])
//      ])
//    ])
//}
//
