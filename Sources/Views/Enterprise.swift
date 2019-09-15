import Css
import FunctionalCss
import HtmlUpgrade
import Models
import PointFreeRouter
import Styleguide
import UrlFormEncoding

public func enterpriseView(_ currentUser: User?, _ account: EnterpriseAccount) -> Node {
  let loggedOutView: Node = [
    .p(
      attributes: [.class([Class.pf.colors.fg.green, Class.padding([.mobile: [.bottom: 3]])])],
      "Log in to gain access to every episode of ", pointFreeRaw, "."
    ),
    .gitHubLink(
      text: "Sign in with GitHub",
      type: .white,
      href: pointFreeRouter.path(to: .login(redirect: pointFreeRouter.url(to: .enterprise(.landing(account.domain)))))
    ),
  ]

  let loggedInView: Node = [
    .p(
      attributes: [.class([Class.pf.colors.fg.green])],
      "Enter your company email address to gain access to every episode of ", pointFreeRaw, "."
    ),
    .gridRow(
      attributes: [
        .class([
          Class.padding([.mobile: [.bottom: 3]]),
          Class.margin([.mobile: [.top: 2]])]
        )
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [],
        .form(
          attributes: [
            .action(pointFreeRouter.path(to: .enterprise(.requestInvite(account.domain, .init(email: ""))))),
            .method(.post),
          ],
          .gridRow(
            attributes: [
              .class([
                Class.padding([.mobile: [.bottom: 3]]),
                Class.margin([.mobile: [.top: 4]]),
                Class.flex.flex,
                Class.flex.items.baseline
                ])
            ],
            .gridColumn(
              sizes: [.mobile: 8],
              attributes: [],
              .input(
                attributes: [
                  .class([blockInputClass]),
                  .name(EnterpriseRequestFormData.CodingKeys.email.rawValue),
                  .placeholder("blob@\(account.domain)"),
                  .type(.email),
                ])
            ),
            .gridColumn(
              sizes: [.mobile: 4],
              attributes: [],
              .button(
                attributes: [.class([Class.pf.components.button(color: .white), Class.margin([.mobile: [.left: 1]])])],
                "Request Access")
            )
          )
        )
      )
    )
  ]

  return .gridRow(
    attributes: [.class([enterpriseRowClass])],
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 7],
      attributes: [],
      .div(
        .h2(
          attributes: [.class([Class.pf.colors.fg.white, Class.pf.type.responsiveTitle2])],
          [pointFreeRaw, " 🤝 ", .text(account.companyName)]
        ),
        currentUser == nil ? loggedOutView : loggedInView
      )
    )
  )
}

private let pointFreeRaw = Node.raw("Point&#8209;Free")

private let enterpriseRowClass =
  Class.pf.colors.bg.purple150
    | Class.grid.center(.mobile)
    | Class.padding([.mobile: [.topBottom: 3, .leftRight: 2], .desktop: [.topBottom: 4, .leftRight: 0]])

// TODO: Remove when the `blockInputClass` in Account.swift is moved into Views.
private let blockInputClass =
  regularInputClass
    | Class.size.width100pct
    | Class.display.block

let baseInputClass =
  Class.type.fontFamily.inherit
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
