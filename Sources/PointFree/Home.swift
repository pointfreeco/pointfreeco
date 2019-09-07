import Css
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import UrlFormEncoding
import Views

let homeMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple3<User?, SubscriberState, Route?>, Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: homeView,
      layoutData: { (currentUser: User?, subscriberState: SubscriberState, currentRoute: Route?) in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (currentUser, subscriberState),
          extraStyles: markdownBlockStyles,
          openGraphType: .website,
          style: .base(.mountains(.main)),
          title: "Point-Free: A video series on functional programming and the Swift programming language.",
          twitterCard: .summaryLargeImage
        )
    }
)

func homeView(currentUser: User?, subscriberState: SubscriberState) -> [Node] {

  let episodes = Current.episodes().sorted(by: their(^\.sequence, >))

  let ctaInsertionIndex = subscriberState.isNonSubscriber ? min(3, episodes.count) : 0
  let firstBatch = episodes[0..<ctaInsertionIndex]
  let secondBatch = episodes[ctaInsertionIndex...]

  return episodesListView(firstBatch)
    <> subscriberCalloutView(subscriberState)
    <> episodesListView(secondBatch)
}

private func subscriberCalloutView(_ subscriberState: SubscriberState) -> [Node] {
  guard subscriberState.isNonSubscriber else { return [] }

  return divider + [
    gridRow([
      gridColumn(
        sizes: [.desktop: 9, .mobile: 12],
        [style(margin(leftRight: .auto))],
        [
          div(
            [
              `class`(
                [
                  Class.margin([.mobile: [.all: 4]]),
                  Class.padding([.mobile: [.all: 3]]),
                  Class.pf.colors.bg.gray900
                ]
              )
            ],
            [
              h4(
                [
                  `class`(
                    [
                      Class.pf.type.responsiveTitle4,
                      Class.padding([.mobile: [.bottom: 2]])
                    ]
                  )
                ],
                ["Subscribe to Point-Free"]
              ),
              p(
                [
                  "👋 Hey there! See anything you like? You may be interested in ",
                  a(
                    [
                      href(path(to: .pricingLanding)),
                      `class`([Class.pf.type.underlineLink])
                    ],
                    ["subscribing"]
                  ),
                  " so that you get access to these episodes and all future ones.",
                  ]
              )
            ]
          )
        ]
      )
      ])
  ]
}

private func episodesListView(_ eps: ArraySlice<Episode>) -> [Node] {
  return eps.flatMap(episodeRowView)
}

private func episodeRowView(_ ep: Episode) -> [Node] {

  return divider + [
    gridRow([
      gridColumn(sizes: [.mobile: 12, .desktop: 7], episodeInfoColumnView(ep)),

      gridColumn(sizes: [.mobile: 12, .desktop: 5], [`class`([Class.grid.first(.mobile), Class.grid.last(.desktop)])], [
        div([`class`([Class.size.height100pct]), style(lineHeight(0) <> gradient <> minHeight(.px(300)))], [
          a([href(path(to: .episode(.left(ep.slug))))], [
            img(
              [src(ep.image), alt(""), `class`([Class.size.width100pct, Class.size.height100pct]),
               style(objectFit(.cover))]
            )
            ])
          ])
        ])
      ])
  ]
}

private func episodeInfoColumnView(_ ep: Episode) -> [Node] {
  return [
    div(
      [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])],
      topLevelEpisodeInfoView(ep: ep) + [
        div([`class`([Class.margin([.mobile: [.top: 3]])])], [
          a(
            [href(path(to: .episode(.left(ep.slug)))), `class`([Class.align.middle, Class.pf.colors.link.purple, Class.pf.type.body.regular])],
            [
              .text("Watch episode (\(ep.length / 60) min)"),
              img(
                base64: rightArrowSvgBase64(fill: "#974DFF"),
                type: .image(.svg),
                alt: "",
                [`class`([Class.align.middle, Class.margin([.mobile: [.left: 1]])]), width(16), height(16)]
              )
            ]
          ),
          ])
      ]
    )
  ]
}

private let gradient =
  key("background", "linear-gradient(to bottom, rgba(238,238,238,1) 0%, rgba(216,216,216,1) 100%)")
