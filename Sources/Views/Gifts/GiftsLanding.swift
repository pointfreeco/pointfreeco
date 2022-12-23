import Ccmark
import Css
import Dependencies
import FunctionalCss
import Html
import PointFreeRouter
import Prelude

public func giftsLanding(
  episodeStats: EpisodeStats
) -> Node {
  [
    landingHero(title: "Share the wonderful world of&nbsp;functional programming in Swift."),
    options(episodeStats: episodeStats),
    whatToExpect,
    faq(faqs: .giftFaqs),
    whatPeopleAreSaying,
    featuredTeams,
  ]
}

private func options(episodeStats: EpisodeStats) -> Node {
  [
    .gridRow(
      attributes: [
        .class([
          Class.padding([.mobile: [.leftRight: 2, .top: 3], .desktop: [.leftRight: 4, .top: 4]]),
          Class.grid.between(.desktop),
        ])
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.grid.center(.desktop),
            Class.padding([.desktop: [.bottom: 2]]),
          ])
        ],
        .h3(
          attributes: [
            .id("plans-and-pricing"),
            .class([Class.pf.type.responsiveTitle4]),
          ],
          "Give the gift of Point-Free"
        )
      )
    ),
    .ul(
      attributes: [
        .class([
          Class.margin([.mobile: [.all: 0]]),
          Class.padding([
            .mobile: [.leftRight: 0, .top: 0, .bottom: 3],
            .desktop: [.leftRight: 2, .top: 0, .bottom: 4],
          ]),
          Class.type.list.styleNone,
          Class.flex.wrap,
          Class.flex.flex,
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      giftOption(plan: .threeMonths, episodeStats: episodeStats),
      giftOption(plan: .sixMonths, episodeStats: episodeStats),
      giftOption(plan: .year, episodeStats: episodeStats)
    ),
  ]
}

extension Gifts.Plan {
  var title: String {
    switch self {
    case .threeMonths:
      return "3 months"
    case .sixMonths:
      return "6 months"
    case .year:
      return "1 year"
    }
  }

  struct Feature {
    var isHighlighted = false
    var name: String
  }

  func features(episodeStats: EpisodeStats) -> [Feature] {
    switch self {
    case .threeMonths:
      return [
        .init(name: "Full access for 3 months"),
        .init(name: "All \(episodeStats.allEpisodeCount) episodes with transcripts"),
        .init(name: "Over \(episodeStats.episodeHourCount) hours of video"),
        .init(name: "Private RSS feed for offline viewing"),
        .init(name: "Download all episode playgrounds"),
      ]
    case .sixMonths:
      return [
        .init(name: "Full access for 6 months"),
        .init(name: "All \(episodeStats.allEpisodeCount) episodes with transcripts"),
        .init(name: "Over \(episodeStats.episodeHourCount) hours of video"),
        .init(name: "Private RSS feed for offline viewing"),
        .init(name: "Download all episode playgrounds"),
      ]
    case .year:
      return [
        .init(isHighlighted: true, name: "22% off the 3 and 6 month gift options"),
        .init(name: "Full access for 1 year"),
        .init(name: "All \(episodeStats.allEpisodeCount) episodes with transcripts"),
        .init(name: "Over \(episodeStats.episodeHourCount) hours of video"),
        .init(name: "Private RSS feed for offline viewing"),
        .init(name: "Download all episode playgrounds"),
      ]
    }
  }
}

func giftOption(
  plan: Gifts.Plan,
  episodeStats: EpisodeStats
) -> ChildOf<Tag.Ul> {
  @Dependency(\.siteRouter) var siteRouter

  let cost: Int
  switch plan {
  case .threeMonths:
    cost = 54
  case .sixMonths:
    cost = 108
  case .year:
    cost = 168
  }

  return .li(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2], .desktop: [.all: 1]]),
        Class.margin([.mobile: [.all: 0]]),
        Class.flex.flex,
        giftOptionSelector,
      ])
    ],
    .div(
      attributes: [
        .class([
          Class.pf.colors.bg.gray900,
          Class.flex.column,
          Class.padding([.mobile: [.all: 2]]),
          Class.size.width100pct,
          Class.flex.flex,
        ])
      ],
      .h4(
        attributes: [.class([Class.pf.type.responsiveTitle4])],
        .text(plan.title)
      ),
      .gridRow(
        attributes: [
          .class([
            Class.grid.start(.mobile),
            Class.grid.middle(.mobile),
          ])
        ],
        .gridColumn(
          sizes: [:],
          attributes: [
            .class([
              Class.pf.type.responsiveTitle4,
              Class.padding([.mobile: [.right: 2]]),
            ]),
            .style(flex(grow: 0, shrink: nil, basis: nil)),
          ],
          .h3(
            attributes: [
              .class([
                Class.pf.colors.fg.black,
                Class.typeScale([.mobile: .r2, .desktop: .r2]),
                Class.type.light,
              ])
            ],
            .text("$\(cost)")
          )
        ),
        .gridColumn(
          sizes: [:],
          .p(
            attributes: [
              .class([
                Class.pf.type.body.small,
                Class.typeScale([.mobile: .r0_875, .desktop: .r0_75]),
                Class.type.lineHeight(1),
              ])
            ],
            "One-time payment"
          )
        )
      ),
      .ul(
        attributes: [
          .class([
            Class.type.list.styleNone,
            Class.padding([.mobile: [.all: 0]]),
            Class.pf.colors.fg.gray400,
            Class.pf.type.body.regular,
            Class.typeScale([.mobile: .r1, .desktop: .r0_875]),
            Class.pf.colors.fg.gray400,
          ]),
          .style(flex(grow: 1, shrink: 0, basis: .auto)),
        ],
        .fragment(
          plan.features(episodeStats: episodeStats).map { feature in
            .li(
              attributes: [.class([Class.padding([.mobile: [.top: 1]])])],
              .div(
                attributes: [
                  .class([pricingPlanFeatureClass]),
                  .style(feature.isHighlighted ? key("background", "#ffd") : .empty),
                ],
                .raw(unsafeMark(from: feature.name))
              )
            )
          }
        )
      ),
      .a(
        attributes: [
          .href(siteRouter.path(for: .gifts(.plan(plan)))),
          .class([
            Class.margin([.mobile: [.top: 2], .desktop: [.top: 3]]),
            choosePlanButtonClasses,
          ]),
        ],
        "Choose gift"
      )
    )
  )
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

extension Array where Element == Faq {
  fileprivate static let giftFaqs = [
    Faq(
      question: "Will I be charged on a recurring basis?",
      answer: """
        Nope. A gift subscription is a one-time payment and you will not be charged again.
        """),
    Faq(
      question: "When am I charged and when does the gift subscription start?",
      answer: """
        You are charged immediately, but the subscription does not start until the recipient accepts your gift.
        """),
    .existingSubscriberRedeemGift,
    .combinedWithStudentDiscountsEtc,
  ]
}

extension Faq {
  static let existingSubscriberRedeemGift = Self(
    question: "Can I accept a gift if I already have a Point-Free subscription?",
    answer: """
      Yes! If you receive a gift and are currently a subscriber we will apply the credit to your account and the amount will be applied to future invoices.
      """)

  static let combinedWithStudentDiscountsEtc = Self(
    question:
      "Can gift subscriptions be combined with student discounts, referrals, regional discounts, etc.?",
    answer: """
      Unfortunately not at this time. Gift subscriptions are charged at the full price of our [regular](/pricing) subscriptions.
      """
  )
}

public let extraGiftLandingStyles =
  Breakpoint.desktop.query(only: screen) {
    giftOptionSelector % width(.pct(33))
  }
  <> giftOptionSelector % width(.pct(100))
  <> pricingPlanFeatureStyle

let giftOptionSelector = CssSelector.class("gift-option")

private let choosePlanButtonClasses =
  Class.display.block
  | Class.size.width100pct
  | Class.type.bold
  | Class.typeScale([.mobile: .r1_25, .desktop: .r1])
  | Class.padding([.mobile: [.topBottom: 1]])
  | Class.type.align.center
  | Class.pf.colors.bg.black
  | Class.pf.colors.fg.white
  | Class.pf.colors.link.white
