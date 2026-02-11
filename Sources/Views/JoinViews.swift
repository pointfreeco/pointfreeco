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
        .h3(attributes: [.class([Class.pf.type.responsiveTitle3])], "Join a team on Point-Free!"),
        .p(.text(joinDescription)),
        .p(
          "You must be logged in to accept this invitation. Would you like to log in with GitHub?"),
        .p(
          attributes: [.class([Class.padding([.mobile: [.top: 3]])])],
          .gitHubLink(
            text: "Login with GitHub",
            type: .black,
            href: siteRouter.loginPath(redirect: .teamInviteCode(.landing(code: code)))
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
          .action(siteRouter.path(for: .teamInviteCode(.join(code: code, email: nil)))),
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
      ),
    ]
  } else {
    confirmation = .form(
      attributes: [
        .action(siteRouter.path(for: .teamInviteCode(.join(code: code, email: nil)))),
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
          .text(joinDescription)
        ),
        confirmation
      )
    )
  )
}

private var joinDescription: String {
  """
  You have been invited to join a team on Point-Free, a hub for advanced Swift programming. \
  Accepting this invitation gives you access to expert guidance, battle-tested tools, advanced AI \
  skill documents, exclusive videos, and a community of likeminded engineers.
  """
}
