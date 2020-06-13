import Css
import FunctionalCss
import Html
import Models
import PointFreeRouter

public func showInviteView(teamInvite: TeamInvite, inviter: User, currentUser: User?) -> Node {
  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        currentUser
          .map { showInviteLoggedInView(currentUser: $0, teamInvite: teamInvite, inviter: inviter) }
          ?? showInviteLoggedOutView(invite: teamInvite, inviter: inviter)
      )
    )
  )
}

private func showInviteLoggedOutView(invite: TeamInvite, inviter: User) -> Node {
  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.topBottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h3(attributes: [.class([Class.pf.type.responsiveTitle3])], "You’ve been invited!"),

        .p(
          "Your colleague ",
          .a(attributes: [.mailto(inviter.email.rawValue)], .text(inviter.displayName)),
          """
           has invited you to join their team on Point-Free, a video series exploring functional programming
          concepts using the Swift programming language. Accepting this invitation gives you access to all of
          the videos, transcripts, and code samples on this site.
          """
        ),
        .p(
          "You must be logged in to accept this invitation. Would you like to log in with GitHub?"),
        .p(
          attributes: [.class([Class.padding([.mobile: [.top: 3]])])],
          .gitHubLink(
            text: "Login with GitHub",
            type: .black,
            href: path(to: .login(redirect: url(to: .invite(.show(invite.id)))))
          )
        )
      )
    )
  )
}

private func showInviteLoggedInView(currentUser: User, teamInvite: TeamInvite, inviter: User)
  -> Node
{
  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.topBottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h3(attributes: [.class([Class.pf.type.responsiveTitle3])], "You’ve been invited!"),
        .p(
          "Your colleague ",
          .a(attributes: [.mailto(inviter.email.rawValue)], .text(inviter.displayName)),
          """
           has invited you to join their team account on Point-Free, a video series exploring functional
          programming concepts using the Swift programming language. Accepting this invitation gives you
          access to all of the videos, transcripts, and code samples on this site.
          """
        ),
        .form(
          attributes: [.action(path(to: .invite(.accept(teamInvite.id)))), .method(.post)],
          .input(
            attributes: [
              .type(.submit),
              .value("Accept"),
              .class([Class.pf.components.button(color: .purple)]),
            ]
          )
        )
      )
    )
  )
}

public let inviteNotFoundView = Node.gridRow(
  .gridColumn(
    sizes: [.mobile: 12, .desktop: 8],
    attributes: [.style(margin(leftRight: .auto))],
    .div(
      attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
      .h3(attributes: [.class([Class.pf.type.responsiveTitle3])], "Invite not found"),
      .p(
        """
        Yikes! We couldn’t find that invite. Perhaps it was already taken, or it may have been revoked by
        the sender. To see subscription plans available, click the link below:
        """
      ),
      .p(
        attributes: [.class([Class.padding([.mobile: [.top: 3]])])],
        .a(
          attributes: [
            .href(path(to: .pricingLanding)),
            .class([Class.pf.components.button(color: .purple)]),
          ],
          "Subscribe"
        )
      )
    )
  )
)
