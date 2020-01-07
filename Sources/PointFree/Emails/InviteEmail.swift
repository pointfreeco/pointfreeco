import Css
import FunctionalCss
import HtmlUpgrade
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

let teamInviteEmailView = simpleEmailLayout(teamInviteEmailBodyView) <<< { inviter, invite in
  SimpleEmailLayoutData(
    user: nil,
    newsletter: nil,
    title: "You’re invited to join \(inviter.displayName)’s team on Point-Free",
    preheader: "Your colleague \(inviter.displayName) has invited you to join their team account on Point-Free.",
    template: .default,
    data: (inviter, invite)
  )
}

private func teamInviteEmailBodyView(inviter: User, invite: TeamInvite) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])], "You’re invited!"
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            "Your colleague ",
            .text(inviter.displayName),
            """
             has invited you to join their team account on Point-Free, a video series about functional
            programming and the Swift programming language. To accept, simply click the link below!
            """
          ),
          .p(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
            .a(
              attributes: [
                .href(url(to: .invite(.show(invite.id)))),
                .class([Class.pf.components.button(color: .purple)])
              ],
              "Click here to accept!"
            )
          )
        )
      )
    )
  )
}

let inviteeAcceptedEmailView = simpleEmailLayout(inviteeAcceptedEmailBodyView) <<< { inviter, invitee in
  SimpleEmailLayoutData(
    user: nil,
    newsletter: nil,
    title: "\(invitee.displayName) has accepted your invitation!",
    preheader: "",
    template: .default,
    data: (inviter, invitee)
  )
}

private func inviteeAcceptedEmailBodyView(inviter: User, invitee: User) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .h3(
          attributes: [.class([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.bottom: 2]])])],
          "Your invitation was accepted!"
        ),
        .p("Hey ", .text(inviter.displayName), "!"),
        .p(
          "Your colleague ",
          .text(invitee.displayName),
          " has accepted your invitation! They now have full access to everything Point-Free has to offer. "
        ),
        .p(
          "To review who is on your team, ",
          .a(attributes: [.href(url(to: .account(.index)))], "click here"),
          "."
        )
      )
    )
  )
}
