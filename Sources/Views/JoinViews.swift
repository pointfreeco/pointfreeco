import Css
import Dependencies
import FunctionalCss
import Html
import Models
import Styleguide

public func joinTeamLanding(
  code: Subscription.TeamInviteCode
) -> Node {
  @Dependency(\.currentUser) var currentUser

  return .gridRow(
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        attributes: [.class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        currentUser
          .map { joinTeamLandingLoggedIn(code: code, currentUser: $0) }
          ?? joinTeamLandingLoggedOut(code: code)
      )
    )
  )
}

private func joinTeamLandingLoggedOut(
  code: Subscription.TeamInviteCode
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.topBottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h3(attributes: [.class([Class.pf.type.responsiveTitle3])], "Join a team subscription!"),
        .p(
          """
          You have been invited to join a team subscription on Point-Free, a video series exploring
          advanced concepts in the Swift programming language. Accepting this invitation gives you
          access to all videos, transcripts, code samples and more.
          """
        ),
        .p(
          "You must be logged in to accept this invitation. Would you like to log in with GitHub?"),
        .p(
          attributes: [.class([Class.padding([.mobile: [.top: 3]])])],
          .gitHubLink(
            text: "Login with GitHub",
            type: .black,
            href: siteRouter.loginPath(redirect: .join(.landing(code: code)))
          )
        )
      )
    )
  )
}

private func joinTeamLandingLoggedIn(
  code: Subscription.TeamInviteCode,
  currentUser: User
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  let confirmation: Node
  if code.isDomain {
    confirmation = [
      .p(
        """
        To accept, please confirm your company email address.
        """
      ),
      .form(
        attributes: [
          .action(siteRouter.path(for: .join(.join(code: code, email: nil)))),
          .method(.post),
        ],
        .input(
          attributes: [
            .class([blockInputClass]),
            .type(.text),
            .placeholder("blob@\(code)"),
            .name("email"),
          ]
        ),
        .input(
          attributes: [
            .type(.submit),
            .value("Request Access"),
            .class([Class.pf.components.button(color: .black)]),
          ]
        )
      )
    ]
  } else {
    confirmation = .form(
      attributes: [
        .action(siteRouter.path(for: .join(.join(code: code, email: nil)))),
        .method(.post),
      ],
      .input(
        attributes: [
          .type(.submit),
          .value("Accept"),
          .class([Class.pf.components.button(color: .purple)]),
        ]
      )
    )
  }

  return .gridRow(
    attributes: [.class([Class.padding([.mobile: [.topBottom: 4]])])],
    .gridColumn(
      sizes: [.mobile: 12],
      .div(
        .h3(attributes: [.class([Class.pf.type.responsiveTitle3])], "You’ve been invited!"),
        .p(
          attributes: [
            .class([Class.padding([.mobile: [.bottom: 2]])])
          ],
          """
          You have been invited to join a team subscription on Point-Free, a video series exploring
          advanced concepts in the Swift programming language. Accepting this invitation gives you
          access to all videos, transcripts, code samples and more.
          """
        ),
        confirmation
      )
    )
  )
}
