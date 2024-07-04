import Css
import Dependencies
import FunctionalCss
import Html
import PointFreeDependencies
import PointFreeRouter
import Prelude

extension Gifts.Plan {
  struct Feature {
    var isHighlighted = false
    var name: String
  }

  func features(episodeStats: EpisodeStats) -> [Feature] {
    @Dependency(\.siteRouter) var siteRouter

    let base: [Feature] = [
      .init(name: "All \(episodeStats.allEpisodeCount) episodes with transcripts"),
      .init(name: "Over \(episodeStats.episodeHourCount) hours of video"),
      .init(
        name: "Access to all past [livestreams](\(siteRouter.path(for: .live(.current)))) at 1080p"
      ),
      .init(name: "Private RSS feed for offline viewing"),
      .init(name: "Download all episode code samples"),
    ]

    switch self {
    case .threeMonths:
      return [
        .init(name: "Full access for 3 months")
      ] + base
    case .sixMonths:
      return [
        .init(name: "Full access for 6 months")
      ] + base
    case .year:
      return [
        .init(isHighlighted: true, name: "22% off the 3 and 6 month gift options"),
        .init(name: "Full access for 1 year"),
      ] + base
    }
  }
}

public func landingHero(title: String) -> Node {
  .div(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
        Class.border.top,
      ]),
      .style(key("border-top-color", "#333")),
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([.mobile: [.leftRight: 3, .topBottom: 4], .desktop: [.all: 5]]),
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 12],
        attributes: [
          .class([
            Class.padding([.mobile: [.bottom: 2], .desktop: [.bottom: 0, .right: 2]]),
            .star,
          ])
        ],
        .h1(
          attributes: [
            .class([
              Class.pf.type.responsiveTitle2,
              Class.pf.colors.fg.white,
            ]),
            .style(lineHeight(1.2)),
          ],
          .raw(title)
        )
      )
    )
  )
}

public let extraGiftLandingStyles =
  Breakpoint.desktop.query(only: screen) {
    giftOptionSelector % width(.pct(33))
  }
  <> giftOptionSelector % width(.pct(100))
  <> pricingPlanFeatureStyle

let giftOptionSelector = CssSelector.class("gift-option")
