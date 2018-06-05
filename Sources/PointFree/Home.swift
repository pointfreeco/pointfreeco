import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple
import UrlFormEncoding

let homeMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple3<Database.User?, SubscriberState, Route?>, Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: homeView,
      layoutData: { (currentUser: Database.User?, subscriberState: SubscriberState, currentRoute: Route?) in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (currentUser, subscriberState),
          description: "Point-Free is a video series exploring functional programming and Swift.",
          extraStyles: markdownBlockStyles <> pricingExtraStyles,
          image: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
          openGraphType: .website,
          style: .base(.mountains(.main)),
          title: "Point-Free: A video series on functional programming and the Swift programming language.",
          twitterCard: .summaryLargeImage
        )
    }
)

let homeView = View<(Database.User?, SubscriberState)> { currentUser, subscriberState -> [Node] in

  let episodes = Current.episodes().sorted(by: their(^\.sequence, >))

  let ctaInsertionIndex = subscriberState.isNonSubscriber ? min(3, episodes.count) : 0
  let firstBatch = episodes[0..<ctaInsertionIndex]
  let secondBatch = episodes[ctaInsertionIndex...]

  return episodesListView.view(firstBatch)
    <> subscriberCalloutView.view(subscriberState)
    <> episodesListView.view(secondBatch)
    <> (subscriberState.isNonSubscriber ? pricingOptionsView.view((currentUser, .default, false)) : [])
}

private let subscriberCalloutView = View<SubscriberState> { subscriberState -> [Node] in
  guard subscriberState.isNonSubscriber else { return [] }

  return dividerView.view(unit) <> [
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
                      href(path(to: .pricing(nil, expand: nil))),
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

private let episodesListView = View<ArraySlice<Episode>> { eps in
  eps.flatMap(episodeRowView.view)
}

private let episodeRowView = View<Episode> { ep in

  dividerView.view(unit) + [
    gridRow([
      gridColumn(sizes: [.mobile: 12, .desktop: 7], episodeInfoColumnView.view(ep)),

      gridColumn(sizes: [.mobile: 12, .desktop: 5], [`class`([Class.grid.first(.mobile), Class.grid.last(.desktop)])], [
        div([`class`([Class.size.height100pct]), style(lineHeight(0) <> gradient <> minHeight(.px(300)))], [
          a([href(path(to: .episode(.left(ep.slug))))], [
            img(
              src: ep.image,
              alt: "",
              [`class`([Class.size.width100pct, Class.size.height100pct]),
               style(objectFit(.cover))]
            )
            ])
          ])
        ])
      ])
  ]
}

private let episodeInfoColumnView = View<Episode> { ep in
  div(
    [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])],
    topLevelEpisodeInfoView.view(ep) + [
      div([`class`([Class.margin([.mobile: [.top: 3]])])], [
        a(
          [href(path(to: .episode(.left(ep.slug)))), `class`([Class.align.middle, Class.pf.colors.link.purple, Class.pf.type.body.regular])],
          [
            "Watch episode",
            img(
              base64: rightArrowSvgBase64(fill: "#974DFF"),
              mediaType: .image(.svg),
              alt: "",
              [`class`([Class.align.middle, Class.margin([.mobile: [.left: 1]])]), width(16), height(16)]
            )
          ]
        ),
        ])
    ]
  )
}

private let gradient =
  key("background", "linear-gradient(to bottom, rgba(238,238,238,1) 0%, rgba(216,216,216,1) 100%)")
