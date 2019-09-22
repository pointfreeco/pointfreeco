import Css
import FunctionalCss
import HtmlUpgrade
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func homeView(currentUser: User?, subscriberState: SubscriberState, episodes: [Episode]) -> Node {

  let episodes = episodes.sorted(by: their(^\.sequence, >))

  let ctaInsertionIndex = subscriberState.isNonSubscriber ? min(3, episodes.count) : 0
  let firstBatch = episodes[0..<ctaInsertionIndex]
  let secondBatch = episodes[ctaInsertionIndex...]

  return [
    episodesListView(firstBatch),
    subscriberCalloutView(subscriberState),
    episodesListView(secondBatch)
  ]
}

private let divider = Node.hr(attributes: [.class([Class.pf.components.divider])])

private func subscriberCalloutView(_ subscriberState: SubscriberState) -> Node {
  guard subscriberState.isNonSubscriber else { return [] }

  return [
    divider,
    .gridRow(
      .gridColumn(
        sizes: [.desktop: 9, .mobile: 12],
        attributes: [.style(margin(leftRight: .auto))],
        .div(
          attributes: [
            .class(
              [
                Class.margin([.mobile: [.all: 4]]),
                Class.padding([.mobile: [.all: 3]]),
                Class.pf.colors.bg.gray900
              ]
            )
          ],
          .h4(
            attributes: [
              .class(
                [
                  Class.pf.type.responsiveTitle4,
                  Class.padding([.mobile: [.bottom: 2]])
                ]
              )
            ],
            "Subscribe to Point-Free"
          ),
          .p(
            "👋 Hey there! See anything you like? You may be interested in ",
            .a(
              attributes: [
                .href(path(to: .pricingLanding)),
                .class([Class.pf.type.underlineLink])
              ],
              "subscribing"
            ),
            " so that you get access to these episodes and all future ones."
          )
        )
      )
    )
  ]
}

private func episodesListView(_ eps: ArraySlice<Episode>) -> Node {
  return .fragment(eps.map(episodeRowView))
}

private func episodeRowView(_ ep: Episode) -> Node {
  return [
    divider,
    .gridRow(
      .gridColumn(sizes: [.mobile: 12, .desktop: 7], episodeInfoColumnView(ep)),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 5],
        attributes: [.class([Class.grid.first(.mobile), Class.grid.last(.desktop)])],
        .div(
          attributes: [
            .class([Class.size.height100pct]),
            .style(lineHeight(0) <> gradient <> minHeight(.px(300)))
          ],
          .a(
            attributes: [.href(path(to: .episode(.left(ep.slug))))],
            .img(
              attributes: [
                .src(ep.image),
                .alt(""),
                .class([Class.size.width100pct, Class.size.height100pct]),
                .style(objectFit(.cover))
              ]
            )
          )
        )
      )
    )
  ]
}

private func episodeInfoColumnView(_ ep: Episode) -> Node {
  return .div(
    attributes: [
      .class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])
    ],
    topLevelEpisodeInfoView(ep: ep),
    .div(
      attributes: [.class([Class.margin([.mobile: [.top: 3]])])],
      .a(
        attributes: [
          .href(path(to: .episode(.left(ep.slug)))),
          .class([Class.align.middle, Class.pf.colors.link.purple, Class.pf.type.body.regular])
        ],
        .text("Watch episode (\(ep.length / 60) min)"),
        .img(
          base64: rightArrowSvgBase64(fill: "#974DFF"),
          type: .image(.svg),
          alt: "",
          attributes: [.class([Class.align.middle, Class.margin([.mobile: [.left: 1]])]), .width(16), .height(16)]
        )
      )
    )
  )
}

public func topLevelEpisodeInfoView(ep: Episode) -> Node {
  return [
    .strong(
      attributes: [.class([Class.pf.type.responsiveTitle8])],
      .text(topLevelEpisodeMetadata(ep))
    ),
    .h1(
      attributes: [
        .class([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.top: 2]])])
      ],
      .a(
        attributes: [.href(path(to: .episode(.left(ep.slug))))],
        .text(ep.title)
      )
    ),
    .div(
      attributes: [.class([Class.pf.type.body.leading])],
      .markdownBlock(ep.blurb)
    )
  ]
}

private func topLevelEpisodeMetadata(_ ep: Episode) -> String {
  let components: [String?] = [
    "#\(ep.sequence)",
    episodeDateFormatter.string(from: ep.publishedAt),
    /* TODO: ep.subscriberOnly */ true ? "Subscriber-only" : "Free Episode"
  ]

  return components
    .compactMap { $0 }
    .joined(separator: " • ")
}

private let gradient =
  key("background", "linear-gradient(to bottom, rgba(238,238,238,1) 0%, rgba(216,216,216,1) 100%)")
