import Css
import FunctionalCss
import Html
import Models
import PointFreeRouter
import Prelude
import Styleguide
import View
import HtmlCssSupport

public func subscribeLanding(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  return hero(currentUser: currentUser, subscriberState: subscriberState)
    + plansAndPricing
    + whatToExpect
    + faq
    + whatPeopleAreSaying
    + featuredTeams
    + footer
}

func ctaColumn(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  guard !subscriberState.isActive else { return [] }

  return [
    gridColumn(
      sizes: [.mobile: 12, .desktop: 4],
      [
        `class`([
          Class.grid.center(.desktop),
          Class.padding([.desktop: [.left: 2]])
          ])
      ],
      [
        div(
          [],
          [
            p(
              [
                `class`([
                  Class.pf.colors.fg.white,
                  Class.padding([.mobile: [.bottom: 2]])
                  ])
              ],
              ["Start with a free episode"]
            ),
            gitHubLink(
              text: "Create your account",
              type: .white,
              // TODO: redirect back to home?
              href: path(to: .login(redirect: url(to: .subscribeLanding)))
            )
          ]
        )
      ]
    )
  ]
}

private func titleColumn(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  let isTwoColumnHero = !subscriberState.isActive
  let titleColumnCount = isTwoColumnHero ? 8 : 12

  return [
    gridColumn(
      sizes: [.mobile: 12, .desktop: titleColumnCount],
      [
        `class`([
          Class.padding([.mobile: [.bottom: 2], .desktop: [.bottom: 0, .right: 2]]),
          isTwoColumnHero ? rightBorderClass: .star
          ]),
      ],
      [
        h1(
          [
            `class`([
              Class.pf.type.responsiveTitle2,
              Class.pf.colors.fg.white
              ]),
            style(lineHeight(1.2))
          ],
          [.raw("Explore the wonderful world of&nbsp;functional programming in Swift.")]
        )
      ]
    )
  ]
}

private func hero(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  return [
    div(
      [
        `class`([
          Class.pf.colors.bg.black,
          Class.padding([.mobile: [.leftRight: 3, .topBottom: 4], .desktop: [.all: 5]])
          ]),
        style(
          // TODO: move to nav?
          key("border-top", "1px solid #333")
        )
      ],
      [
        gridRow(
          [
            `class`([Class.grid.middle(.desktop)])
          ],
          titleColumn(currentUser: currentUser, subscriberState: subscriberState)
            + ctaColumn(currentUser: currentUser, subscriberState: subscriberState)
        )
      ]
    )
  ]
}

private let plansAndPricing = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle3])],
        ["Plans and pricing"]
      )
    ]
  )
]

private let whatToExpect = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle3])],
        ["What to expect"]
      )
    ]
  )
]

private let faq = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle3])],
        ["FAQ"]
      )
    ]
  )
]

private let whatPeopleAreSaying = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle3])],
        ["What people are saying"]
      )
    ]
  )
]

private let featuredTeams = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle7])],
        ["Featured teams"]
      )
    ]
  )
]

private let footer = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle3])],
        ["Get started with our free plan"]
      )
    ]
  )
]

public let extraSubscriptionLandingStyles = rightBorderStyles

private let rightBorderClass = CssSelector.class("border-right")
private let rightBorderStyles =
  Breakpoint.desktop.query(only: screen) {
    rightBorderClass % key("border-right", "1px solid #333")
}
