import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func homeView(episodes: [Episode], emergencyMode: Bool) -> Node {
  @Dependency(\.subscriberState) var subscriberState

  let episodes = episodes.sorted(by: their(\.sequence, >))

  let ctaInsertionIndex = subscriberState.isNonSubscriber ? min(3, episodes.count) : 0
  let firstBatch = episodes[0..<ctaInsertionIndex]
  let secondBatch = episodes[ctaInsertionIndex...]

  return [
    holidaySpecialCalloutView(),
    episodesListView(episodes: firstBatch, emergencyMode: emergencyMode),
    homeSubscriberCalloutView,
    episodesListView(episodes: secondBatch, emergencyMode: emergencyMode),
  ]
}

let holidayDiscount2019Interval: ClosedRange<Double> = 1_577_080_800...1_577_854_800

private func holidaySpecialCalloutView() -> Node {
  @Dependency(\.date.now) var now
  @Dependency(\.subscriberState) var subscriberState

  guard holidayDiscount2019Interval.contains(now.timeIntervalSince1970) else { return [] }
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
              Class.margin([.mobile: [.topBottom: 4], .desktop: [.leftRight: 4]])
            ])
          ],
          holidaySpecialContent
        )
      )
    ),
  ]
}

var holidaySpecialContent: Node {
  @Dependency(\.siteRouter) var siteRouter

  return .div(
    attributes: [
      .style(backgroundColor(.other("#D6FFE1"))),
      .class([Class.padding([.mobile: [.all: 3]])]),
    ],
    .h4(
      attributes: [
        .class(
          [
            Class.pf.type.responsiveTitle4,
            Class.padding([.mobile: [.bottom: 2]]),
          ]
        )
      ],
      .a(
        attributes: [
          .href(siteRouter.path(for: .discounts(code: "holiday-2019", nil)))
        ],
        "🎉 Holiday Subscription Special 🎉"
      )
    ),
    .p(
      "Hey there! To celebrate the end of 2019 we are offering first-time subscribers 30% off ",
      "their subscription for the first year! ",
      .a(
        attributes: [
          .href(siteRouter.path(for: .discounts(code: "holiday-2019", nil))),
          .class([Class.pf.type.underlineLink]),
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
          .href(siteRouter.path(for: .discounts(code: "holiday-2019", nil))),
          .class([Class.pf.components.button(color: .black)]),
        ],
        "Subscribe now"
      )
    )
  )
}

private var homeSubscriberCalloutView: Node {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

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
                Class.pf.colors.bg.gray900,
              ]
            )
          ],
          .h4(
            attributes: [
              .class(
                [
                  Class.pf.type.responsiveTitle4,
                  Class.padding([.mobile: [.bottom: 2]]),
                ]
              )
            ],
            "Subscribe to Point-Free"
          ),
          .p(
            "👋 Hey there! See anything you like? You may be interested in ",
            .a(
              attributes: [
                .href(siteRouter.path(for: .pricingLanding)),
                .class([Class.pf.type.underlineLink]),
              ],
              "subscribing"
            ),
            " so that you get access to these episodes and all future ones."
          )
        )
      )
    ),
  ]
}

private func episodesListView(episodes: ArraySlice<Episode>, emergencyMode: Bool)
  -> Node
{
  return .fragment(
    episodes.map {
      episodeRowView(episode: $0, emergencyMode: emergencyMode)
    })
}

private func episodeRowView(episode: Episode, emergencyMode: Bool) -> Node {
  @Dependency(\.date.now) var now

  return [
    divider,
    .gridRow(
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 7],
        episodeInfoColumnView(episode: episode, emergencyMode: emergencyMode)
      ),
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 5],
        attributes: [.class([Class.grid.first(.mobile), Class.grid.last(.desktop)])],
        episodeImageColumnView(episode: episode)
      )
    ),
  ]
}

private func episodeImageColumnView(episode: Episode) -> Node {
  @Dependency(\.episodeProgresses) var episodeProgresses
  @Dependency(\.siteRouter) var siteRouter

  let filter: Stylesheet
  let watched: Node
  if episodeProgresses[episode.sequence]?.isFinished == true {
    if episode.sequence.rawValue.quotientAndRemainder(dividingBy: 4).remainder == 3 {
      filter = key("filter", "grayscale(1) brightness(175%)")
    } else {
      filter = key("filter", "grayscale(1)")
    }
    watched = .div(
      attributes: [
        .class([
          Class.position.absolute,
          Class.position.left0,
          Class.position.top0,
          Class.pf.type.body.leading,
          Class.pf.colors.fg.white,
          Class.pf.colors.bg.gray150,
          Class.padding([.mobile: [.leftRight: 2]]),
          Class.padding([.mobile: [.topBottom: 2]]),
          Class.margin([.mobile: [.leftRight: 2]]),
          Class.margin([.mobile: [.topBottom: 2]]),
        ])
      ],
      .img(
        base64: checkmarkSvgBase64,
        type: .image(.svg),
        alt: "",
        attributes: [
          .class([
            Class.align.middle
          ]),
          .style(
            margin(right: .rem(0.5), bottom: .rem(0.25))
          ),
        ]
      ),
      "Watched"
    )
  } else {
    filter = .empty
    watched = []
  }

  return .div(
    attributes: [
      .class([
        Class.size.height100pct,
        Class.position.relative,
      ]),
      .style(
        lineHeight(0)
          <> gradient
          <> minHeight(.px(300))
      ),
    ],
    .a(
      attributes: [.href(siteRouter.path(for: .episode(.show(.left(episode.slug)))))],
      .img(
        attributes: [
          .src(episode.image),
          .alt(""),
          .init("loading", "lazy"),
          .class([
            Class.size.width100pct,
            Class.size.height100pct,
          ]),
          .style(objectFit(.cover) <> filter),
        ]
      )
    ),
    watched
  )
}

private func episodeInfoColumnView(episode: Episode, emergencyMode: Bool) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  let minutes = (episode.length.rawValue / 60) % 60
  let hours = (episode.length.rawValue / 60 / 60) % 60
  let length = hours == 0 ? "\(minutes)min" : "\(hours)hr \(minutes)min"

  let text: String
  switch episode.format {
  case .prerecorded:
    text = "Watch episode (\(length))"
  case .livestream:
    text = "Watch livestream (\(length))"
  }

  return .div(
    attributes: [
      .class([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]), Class.pf.colors.bg.white])
    ],
    topLevelEpisodeInfoView(
      episode: episode, emergencyMode: emergencyMode),
    .div(
      attributes: [.class([Class.margin([.mobile: [.top: 3]])])],
      .a(
        attributes: [
          .href(siteRouter.path(for: .episode(.show(.left(episode.slug))))),
          .class([Class.align.middle, Class.pf.colors.link.purple, Class.pf.type.body.regular]),
        ],
        .text(text),
        .img(
          base64: rightArrowSvgBase64(fill: "#974DFF"),
          type: .image(.svg),
          alt: "",
          attributes: [
            .class([Class.align.middle, Class.margin([.mobile: [.left: 1]])]), .width(16),
            .height(16),
          ]
        )
      )
    )
  )
}

public func topLevelEpisodeInfoView(episode: Episode, emergencyMode: Bool) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .strong(
      attributes: [.class([Class.pf.type.responsiveTitle8])],
      .text(
        topLevelEpisodeMetadata(episode: episode, emergencyMode: emergencyMode))
    ),
    .h1(
      attributes: [
        .class([Class.pf.type.responsiveTitle4, Class.margin([.mobile: [.top: 2]])])
      ],
      .a(
        attributes: [.href(siteRouter.path(for: .episode(.show(.left(episode.slug)))))],
        .text(episode.fullTitle)
      )
    ),
    .div(
      attributes: [.class([Class.pf.type.body.leading])],
      .markdownBlock(episode.blurb)
    ),
  ]
}

func topLevelEpisodeMetadata(episode: Episode, emergencyMode: Bool) -> String {
  @Dependency(\.date.now) var now
  let components: [String?] = [
    "#\(episode.sequence)",
    episodeDateFormatter.string(from: episode.publishedAt),
    episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode)
      ? "Subscriber-only" : "Free Episode",
  ]

  return
    components
    .compactMap { $0 }
    .joined(separator: " • ")
}

private let gradient =
  key("background", "linear-gradient(to bottom, rgba(238,238,238,1) 0%, rgba(216,216,216,1) 100%)")
