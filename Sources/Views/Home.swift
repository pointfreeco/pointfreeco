import Css
import Foundation
import FunctionalCss
import HtmlUpgrade
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func homeView(
  currentDate: Date,
  currentUser: User?,
  subscriberState: SubscriberState,
  episodes: [Episode],
  date: () -> Date
  ) -> Node {

  let episodes = episodes.sorted(by: their(^\.sequence, >))

  let ctaInsertionIndex = subscriberState.isNonSubscriber ? min(3, episodes.count) : 0
  let firstBatch = episodes[0..<ctaInsertionIndex]
  let secondBatch = episodes[ctaInsertionIndex...]

  return [
    holidaySpecialCalloutView(currentDate: currentDate, subscriberState: subscriberState),
    episodesListView(episodes: firstBatch, date: date),
    subscriberCalloutView(currentDate: currentDate, subscriberState: subscriberState),
    episodesListView(episodes: secondBatch, date: date)
  ]
}

let holidayDiscount2019Interval: ClosedRange<Double> = 1577080800...1577854800

private func holidaySpecialCalloutView(
  currentDate: Date,
  subscriberState: SubscriberState
) -> Node {
  guard holidayDiscount2019Interval.contains(currentDate.timeIntervalSince1970) else { return [] }
  guard subscriberState.isNonSubscriber else { return [] }

  return [
    divider,
    .gridRow(
      .gridColumn(
        sizes: [.desktop: 9, .mobile: 12],
        attributes: [.style(margin(leftRight: .auto))],
        .div(
          attributes: [
            .class([
              Class.margin([.mobile: [.all: 4]]),
            ])
          ],
          holidaySpecialContent
        )
      )
    )
  ]
}

let holidaySpecialContent: Node = .div(
  attributes: [
    .style(backgroundColor(.other("#D6FFE1"))),
    .class([Class.padding([.mobile: [.all: 3]])])
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
    .a(
      attributes: [
        .href(path(to: .discounts(code: "holiday-2019", nil)))
      ],
      "🎉 Holiday Subscription Special 🎉"
    )
  ),
  .p(
    "Hey there! To celebrate the end of 2019 we are offering first-time subscribers 30% off ",
    "their subscription for the first year! ",
    .a(
      attributes: [
        .href(path(to: .discounts(code: "holiday-2019", nil))),
        .class([Class.pf.type.underlineLink])
      ],
      "Act now"
    ),
    " to get access to all past and future episodes of Point-Free. This offer will only last until ",
    "the end of the year!"
  ),
  .p(
    attributes: [
      .class([Class.margin([.mobile: [.top: 3]])])
    ],
    .a(
      attributes: [
        .href(path(to: .discounts(code: "holiday-2019", nil))),
        .class([Class.pf.components.button(color: .black)])
      ],
      "Subscribe now"
    )
  )
)

private func subscriberCalloutView(
  currentDate: Date,
  subscriberState: SubscriberState
) -> Node {
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

private func episodesListView(episodes: ArraySlice<Episode>, date: () -> Date) -> Node {
  return .fragment(episodes.map { episodeRowView(episode: $0, date: date) })
}

private func episodeRowView(episode: Episode, date: () -> Date) -> Node {
  return [
    divider,
    .gridRow(
      .gridColumn(sizes: [.mobile: 12, .desktop: 7], episodeInfoColumnView(episode: episode, date: date)),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 5],
        attributes: [.class([Class.grid.first(.mobile), Class.grid.last(.desktop)])],
        .div(
          attributes: [
            .class([Class.size.height100pct]),
            .style(lineHeight(0) <> gradient <> minHeight(.px(300)))
          ],
          .a(
            attributes: [.href(path(to: .episode(.left(episode.slug))))],
            .img(
              attributes: [
                .src(episode.image),
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

private func episodeInfoColumnView(episode: Episode, date: () -> Date) -> Node {
  return .div(
    attributes: [
      .class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])
    ],
    topLevelEpisodeInfoView(episode: episode, date: date),
    .div(
      attributes: [.class([Class.margin([.mobile: [.top: 3]])])],
      .a(
        attributes: [
          .href(path(to: .episode(.left(episode.slug)))),
          .class([Class.align.middle, Class.pf.colors.link.purple, Class.pf.type.body.regular])
        ],
        .text("Watch episode (\(episode.length / 60) min)"),
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

public func topLevelEpisodeInfoView(episode: Episode, date: () -> Date) -> Node {
  return [
    .strong(
      attributes: [.class([Class.pf.type.responsiveTitle8])],
      .text(topLevelEpisodeMetadata(episode: episode, date: date))
    ),
    .h1(
      attributes: [
        .class([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.top: 2]])])
      ],
      .a(
        attributes: [.href(path(to: .episode(.left(episode.slug))))],
        .text(episode.title)
      )
    ),
    .div(
      attributes: [.class([Class.pf.type.body.leading])],
      .markdownBlock(episode.blurb)
    )
  ]
}

private func topLevelEpisodeMetadata(episode: Episode, date: () -> Date) -> String {
  let components: [String?] = [
    "#\(episode.sequence)",
    episodeDateFormatter.string(from: episode.publishedAt),
    episode.isSubscriberOnly(currentDate: date()) ? "Subscriber-only" : "Free Episode"
  ]

  return components
    .compactMap { $0 }
    .joined(separator: " • ")
}

private let gradient =
  key("background", "linear-gradient(to bottom, rgba(238,238,238,1) 0%, rgba(216,216,216,1) 100%)")
