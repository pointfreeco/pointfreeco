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
        Class.pf.type.responsiveTitle1,
        Class.pf.colors.bg.black,
        Class.pf.colors.fg.white
        ]),
      style(
        padding(all: .rem(7))
          <> lineHeight(1.15)
      )
    ],
    [
      "Explore the wonderful world of functional programming in Swift."
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
