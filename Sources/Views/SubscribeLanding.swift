import Css
import FunctionalCss
import Html
import Models
import PointFreeRouter
import Prelude
import Styleguide
import View
import HtmlCssSupport

public let subscribeLanding = View<User?> { _ in
  hero
    + plansAndPricing
    + whatToExpect
    + faq
    + whatPeopleAreSaying
    + featuredTeams
    + footer
}

private let hero = [
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
        [
          gridColumn(
            sizes: [.mobile: 12, .desktop: 8],
            [
              `class`([
                Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]]),
                Class.border.right
                ]),
//              style(key("border-right", "1px solid #242424"))
            ],
            [
              h1(
                [
                  `class`([
                    Class.pf.type.responsiveTitle1,
                    Class.pf.colors.fg.white
                    ]),
                  style(lineHeight(1.2))
                ],
                [.raw("Explore the wonderful world of&nbsp;functional programming in Swift.")]
              )
            ]
          ),
          gridColumn(
            sizes: [.mobile: 12, .desktop: 4],
            [
              `class`([Class.grid.center(.desktop)])
            ],
            [
              div(
                [],
                [
                  p(
                    [
                      `class`([
                        Class.pf.colors.fg.white,
                        Class.padding([.mobile: [.bottom: 2 ]])
                        ])
                    ],
                    ["Start with a free episode"]
                  ),
                  gitHubLink(
                    text: "Create your account",
                    type: .white,
                    href: path(to: .login(redirect: url(to: .subscribeLanding)))
                  )
                ]
              )
            ]
          )
        ]
      )
    ]
  )
]

private let plansAndPricing = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle2])],
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
        [`class`([Class.pf.type.responsiveTitle2])],
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
        [`class`([Class.pf.type.responsiveTitle2])],
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
        [`class`([Class.pf.type.responsiveTitle2])],
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
        [`class`([Class.pf.type.responsiveTitle2])],
        ["Get started with our free plan"]
      )
    ]
  )
]
