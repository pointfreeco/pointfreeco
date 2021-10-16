import Ccmark
import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tagged
import HtmlCssSupport

public struct EpisodeStats {
  public let allEpisodeCount: AllEpisodeCount
  public let episodeHourCount: EpisodeHourCount
  public let freeEpisodeCount: FreeEpisodeCount

  public typealias FreeEpisodeCount = Tagged<((), freeEpisodeCount: ()), Int>
  public typealias AllEpisodeCount = Tagged<((), allEpisodeCount: ()), Int>
  public typealias EpisodeHourCount = Tagged<((), episodeHourCount: ()), Int>
}

public func stats(forEpisodes episodes: [Episode]) -> EpisodeStats {
  return EpisodeStats(
    allEpisodeCount: .init(rawValue: episodes.count),
    episodeHourCount: .init(
      rawValue: episodes.reduce(into: 0) { $0 += $1.length.rawValue } / 3600
    ),
    freeEpisodeCount: .init(
      rawValue: episodes.lazy.filter { $0.permission == .free }.count
    )
  )
}

public func pricingLanding(
  currentUser: User?,
  stats: EpisodeStats,
  subscriberState: SubscriberState
  ) -> Node {

  return [
    hero(currentUser: currentUser, subscriberState: subscriberState),
    plansAndPricing(
      currentUser: currentUser,
      stats: stats,
      subscriberState: subscriberState
    ),
    whatToExpect,
    faq(faqs: .allFaqs),
    whatPeopleAreSaying,
    featuredTeams,
    footer(allEpisodeCount: stats.allEpisodeCount, currentUser: currentUser, subscriberState: subscriberState)
  ]
}

func ctaColumn(currentUser: User?, subscriberState: SubscriberState) -> Node {
  guard currentUser == nil || subscriberState.isActive else { return [] }

  let title = subscriberState.isActive
    ? "You‘re already a subscriber!"
    : "Start with a free episode"

  let ctaButton: Node = subscriberState.isActive
    ? .a(
      attributes: [
        .href(path(to: .account(.index))),
        .class([Class.pf.components.button(color: .white)])
      ],
      "Manage your account"
    )
    : .gitHubLink(
      text: "Create your account",
      type: .white,
      // TODO: redirect back to home?
      href: path(to: .login(redirect: url(to: .pricingLanding)))
  )

  return .gridColumn(
    sizes: [.mobile: 12, .desktop: 4],
    attributes: [
      .class([
        Class.grid.center(.desktop),
        Class.padding([.desktop: [.left: 2]])
        ])
    ],
    .div(
      .p(
        attributes: [
          .class([
            Class.pf.colors.fg.white,
            Class.padding([.mobile: [.bottom: 2]])
            ])
        ],
        .text(title)
      ),
      ctaButton
    )
  )
}

private func titleColumn(currentUser: User?, subscriberState: SubscriberState) -> Node {
  let isTwoColumnHero = currentUser == nil || subscriberState.isActive
  let titleColumnCount = isTwoColumnHero ? 8 : 12

  return
    .gridColumn(
      sizes: [.mobile: 12, .desktop: titleColumnCount],
      attributes: [
        .class([
          Class.padding([.mobile: [.bottom: 2], .desktop: [.bottom: 0, .right: 2]]),
          isTwoColumnHero ? darkRightBorder: .star
          ]),
      ],
      .h1(
        attributes: [
          .class([
            Class.pf.type.responsiveTitle2,
            Class.pf.colors.fg.white
            ]),
          .style(lineHeight(1.2))
        ],
        .raw("Explore the wonderful world of&nbsp;functional programming in Swift.")
      )
  )
}

private func hero(currentUser: User?, subscriberState: SubscriberState) -> Node {
  return .div(
    attributes: [
      .class([
        Class.pf.colors.bg.black,
        Class.border.top,
        ]),
      // TODO: move to nav?
      .style(key("border-top-color", "#333"))
    ],
    .gridRow(
      attributes: [
        .class([
          Class.grid.middle(.desktop),
          Class.padding([.mobile: [.leftRight: 3, .topBottom: 4], .desktop: [.all: 5]])
          ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto))
      ],
      titleColumn(currentUser: currentUser, subscriberState: subscriberState),
      ctaColumn(currentUser: currentUser, subscriberState: subscriberState)
    )
  )
}

private let baseCtaButtonClass =
  Class.display.block
    | Class.size.width100pct
    | Class.type.bold
    | Class.typeScale([.mobile: .r1_25, .desktop: .r1])
    | Class.padding([.mobile: [.topBottom: 1]])
    | Class.type.align.center

private let choosePlanButtonClasses =
  baseCtaButtonClass
    | Class.pf.colors.bg.black
    | Class.pf.colors.fg.white
    | Class.pf.colors.link.white

private let contactusButtonClasses =
  baseCtaButtonClass
    | Class.pf.colors.bg.white
    | Class.pf.colors.fg.black
    | Class.pf.colors.link.black
    | Class.border.all
    | Class.pf.colors.border.gray800

private func plansAndPricing(
  currentUser: User?,
  stats: EpisodeStats,
  subscriberState: SubscriberState
  ) -> Node {
  return [
    .gridRow(
      attributes: [
        .class([
          Class.padding([.mobile: [.leftRight: 2, .top: 3], .desktop: [.leftRight: 4, .top: 4]]),
          Class.grid.between(.desktop)
          ]),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.grid.center(.desktop),
            Class.padding([.desktop: [.bottom: 2]])
            ])
        ],
        .h3(
          attributes: [
            .id("plans-and-pricing"),
            .class([Class.pf.type.responsiveTitle2])
          ],
          "Plans and pricing"
        )
      )
    ),
    .ul(
      attributes: [
        .class([
          Class.margin([.mobile: [.all: 0]]),
          Class.padding([.mobile: [.all: 0], .desktop: [.leftRight: 2, .topBottom: 0]]),
          Class.type.list.styleNone,
          Class.flex.wrap,
          Class.flex.flex
          ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto))
      ],
      pricingPlan(
        currentUser: currentUser,
        subscriberState: subscriberState,
        plan: .free(freeEpisodeCount: stats.freeEpisodeCount)
      ),
      pricingPlan(
        currentUser: currentUser,
        subscriberState: subscriberState,
        plan: .personal(
          allEpisodeCount: stats.allEpisodeCount,
          episodeHourCount: stats.episodeHourCount
        )
      ),
      pricingPlan(
        currentUser: currentUser,
        subscriberState: subscriberState,
        plan: .team
      ),
      pricingPlan(
        currentUser: currentUser,
        subscriberState: subscriberState,
        plan: .enterprise
      )
    ),
    .gridRow(
      attributes: [
        .class([Class.padding([.mobile: [.leftRight: 2], .desktop: [.leftRight: 5]])]),
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.grid.center(.desktop),
            Class.padding([.mobile: [.top: 2, .bottom: 3, .leftRight: 2], .desktop: [.bottom: 4]])
            ])
        ],
        .p(
          attributes: [
            .class([
              Class.pf.type.body.regular,
              Class.typeScale([.mobile: .r1, .desktop: .r0_875]),
              Class.pf.colors.fg.gray400
              ]),
            .style(maxWidth(.px(480)) <> margin(leftRight: .auto))
          ],
          "Prices shown with annual billing. When billed month to month, the ",
          .strong("Personal"),
          " plan is $18, and the ",
          .strong("Team"),
          " plan is $16 per member per month."
        )
      )
    )
  ]
}

private func planCost(_ cost: PricingPlan.Cost) -> Node {
  return .gridRow(
    attributes: [
      .class([
        Class.grid.start(.mobile),
        Class.grid.middle(.mobile)
        ]),
    ],
    .gridColumn(
      sizes: [:],
      attributes: [
        .class([
          Class.padding([.mobile: [.right: 2]])
          ]),
        .style(flex(grow: 0, shrink: nil, basis: nil))
      ],
      .h3(
        attributes: [
          .class([
            Class.pf.colors.fg.black,
            Class.typeScale([.mobile: .r2, .desktop: .r2]),
            Class.type.light
            ])
        ],
        .text(cost.value)
      )
    ),
    .gridColumn(
      sizes: [:],
      .p(
        attributes: [
          .class([
            Class.pf.type.body.small,
            Class.typeScale([.mobile: .r0_875, .desktop: .r0_75]),
            Class.type.lineHeight(1)
            ])
        ],
        .raw(cost.title ?? "")
      )
    )
  )
}

func pricingPlan(
  currentUser: User?,
  subscriberState: SubscriberState,
  plan: PricingPlan
  ) -> ChildOf<Tag.Ul> {

  let cost = plan.cost.map(planCost) ?? []

  return .li(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2], .desktop: [.all: 1]]),
        Class.margin([.mobile: [.all: 0]]),
        Class.flex.flex,
        planItem,
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
          ]),
      ],
      .h4(
        attributes: [.class([Class.pf.type.responsiveTitle4])],
        .text(plan.title)
      ),
      cost,
      .ul(
        attributes: [
          .class([
            Class.type.list.styleNone,
            Class.padding([.mobile: [.all: 0]]),
            Class.pf.colors.fg.gray400,
            Class.pf.type.body.regular,
            Class.typeScale([.mobile: .r1, .desktop: .r0_875]),
            Class.pf.colors.fg.gray400
            ]),
          .style(flex(grow: 1, shrink: 0, basis: .auto))
        ],
        .fragment(
          plan.features.map { feature in
            .li(
              attributes: [.class([Class.padding([.mobile: [.top: 1]])])],
              .div(
                attributes: [.class([pricingPlanFeatureClass])],
                .raw(unsafeMark(from: feature))
              )
            )
          }
        )
      ),
      pricingPlanCta(currentUser: currentUser, subscriberState: subscriberState, plan: plan)
    )
  )
}

private func pricingPlanCta(
  currentUser: User?,
  subscriberState: SubscriberState,
  plan: PricingPlan
  ) -> Node {

  if plan.cost == nil {
    return .a(
      attributes: [
        .mailto("support@pointfree.co"),
        .class([
          Class.margin([.mobile: [.top: 2], .desktop: [.top: 3]]),
          contactusButtonClasses
          ])
      ],
      "Contact Us"
    )
  } else if plan.isFree && currentUser == nil  {
    return .a(
      attributes: [
        .href(path(to: .login(redirect: url(to: .pricingLanding)))),
        .class([
          Class.margin([.mobile: [.top: 2], .desktop: [.top: 3]]),
          choosePlanButtonClasses
          ])
      ],
      "Choose plan"
    )
  } else if !plan.isFree {
    return .a(
      attributes: [
        .href(
          subscriberState.isActive
            ? path(to: .account(.index))
            : path(
              to: plan.lane
                .map {
                  let route = Route.subscribeConfirmation(
                    lane: $0,
                    billing: nil,
                    isOwnerTakingSeat: nil,
                    teammates: nil,
                    referralCode: nil,
                    useRegionalDiscount: false
                  )
                  return currentUser == nil ? .login(redirect: url(to: route)) : route
                }
                ?? .home
          )
        ),
        .class([
          Class.margin([.mobile: [.top: 2], .desktop: [.top: 3]]),
          choosePlanButtonClasses
          ])
      ],
      subscriberState.isActive ? "Manage subscription" : "Choose plan"
    )
  } else {
    return []
  }
}

let whatToExpect = Node.div(
  attributes: [.style(backgroundColor(.other("#fafafa")))],
  .gridRow(
    attributes: [
      .class([
        Class.padding([.mobile: [.leftRight: 2, .topBottom: 3], .desktop: [.all: 4]])
        ]),
      .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto))
    ],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [
        .class([
          Class.grid.center(.desktop),
          Class.padding([.mobile: [.bottom: 2], .desktop: [.bottom: 3]])
          ])
      ],
      .h3(
        attributes: [
          .id("what-to-expect"),
          .class([Class.pf.type.responsiveTitle2])
        ],
        "What to expect"
      )
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      attributes: [
        .class([
          Class.grid.center(.desktop),
          Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]]),
          Class.margin([.mobile: [.bottom: 1], .desktop: [.bottom: 0]]),
          lightBottomBorder,
          lightRightBorder
          ]),
      ],
      whatToExpectColumn(item: .newContent)
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      attributes: [
        .class([
          Class.grid.center(.desktop),
          Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]]),
          Class.margin([.mobile: [.bottom: 1], .desktop: [.bottom: 0]]),
          lightBottomBorder
          ])
      ],
      whatToExpectColumn(item: .topics)
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      attributes: [
        .class([
          Class.grid.center(.desktop),
          Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]]),
          Class.margin([.mobile: [.bottom: 1], .desktop: [.bottom: 0]]),
          lightRightBorder
          ])
      ],
      whatToExpectColumn(item: .playgrounds)
    ),
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 6],
      attributes: [.class([Class.grid.center(.desktop)])],
      whatToExpectColumn(item: .transcripts)
    )
  )
)

private func whatToExpectColumn(item: WhatToExpectItem) -> Node {
  return .div(
    attributes: [.class([Class.padding([.desktop: [.all: 3]])])],
    .img(
      src: item.imageSrc,
      alt: "",
      attributes: [
        .class([
          Class.layout.fit, Class.margin([.mobile: [.bottom: 2]]),
          Class.pf.colors.bg.white
          ])
      ]
    ),
    .h4(
      attributes: [.class([Class.pf.type.responsiveTitle5])],
      .text(item.title)
    ),
    .p(
      attributes: [.class([Class.pf.colors.fg.gray400])],
      .text(item.description)
    )
  )
}

let whatPeopleAreSaying = Node.gridRow(
  attributes: [
    .class([Class.grid.between(.desktop)])
  ],
  .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .class([
        Class.padding([.mobile: [.leftRight: 2, .top: 0, .bottom: 3], .desktop: [.leftRight: 4, .top: 0, .bottom: 3]]),
        Class.grid.center(.desktop),
        ]),
    ],
    .div(
      attributes: [
        .class([Class.border.top, Class.padding([.mobile: [.top: 3], .desktop: [.top: 4]])]),
        .style(borderColor(top: Colors.gray850))
      ],
      .h3(
        attributes: [
          .id("what-people-are-saying"),
          .class([Class.pf.type.responsiveTitle2])
        ],
        "What people are saying"
      )
    )
  ),
  .div(
    attributes: [
      .class([
        Class.flex.flex,
        Class.flex.none,
        Class.size.width100pct,
        Class.margin([.mobile: [.bottom: 4]]),
        Class.layout.overflowAuto(.x),
        testimonialContainer
        ]),
    ],
    .fragment(testimonialItems)
  )
)

private let testimonialItems: [Node] = Testimonial.all.map { testimonial in
  .div(
    attributes: [
      .class([
        Class.flex.column,
        Class.flex.flex,
        Class.pf.colors.bg.gray900,
        Class.padding([.mobile: [.all: 3]]),
        Class.margin([.mobile: [.leftRight: 2]]),
        testimonialItem
        ]),
    ],
    .a(
      attributes: [
        .href(testimonial.tweetUrl),
        .target(.blank),
        .rel(.init(rawValue: "noopener noreferrer")),
        .class([
          Class.pf.colors.fg.black,
          Class.pf.type.body.leading
          ]),
        .style(flex(grow: 1, shrink: 0, basis: .auto))
      ],
      .text("“\(testimonial.quote)”")
    ),
    .a(
      attributes: [
        .href("https://www.twitter.com/\(testimonial.twitterHandle)"),
        .class([
          Class.pf.colors.fg.black,
          Class.pf.type.body.leading,
          ]),
      ],
      .twitterIconImg(fill: "1DA1F3"),
      .span(
        attributes: [
          .class([Class.type.medium]),
          .style(margin(left: .px(3)))
        ],
        .text(testimonial.subscriber ?? "@\(testimonial.twitterHandle)")
      )
    )
  )
}

let featuredTeams = Node.gridRow(
  attributes: [
    .class([
      Class.pf.colors.bg.gray900,
      Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]),
      Class.grid.middle(.mobile),
      Class.grid.center(.mobile)
      ])
  ],
  .gridColumn(
    sizes: [.mobile: 12, .desktop: 12],
    attributes: [.class([Class.padding([.mobile: [.bottom: 3]])])],
    .h6(
      attributes: [
        .id("featured-teams"),
        .class([
          Class.pf.colors.fg.gray400,
          Class.pf.type.responsiveTitle7,
          Class.type.align.center
          ]),
      ],
      "Featured Teams"
    )
  ),
  .gridColumn(
    sizes: [.mobile: 6, .desktop: 2],
    attributes: [.class([Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]])])],
    [.img(base64: nytLogoSvg, type: .image(.svg), alt: "New York Times")]
  ),
  .gridColumn(
    sizes: [.mobile: 6, .desktop: 2],
    attributes: [.class([Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]])])],
    [.img(base64: spotifyLogoSvg, type: .image(.svg), alt: "Spotify")]
  ),
  .gridColumn(
    sizes: [.mobile: 6, .desktop: 2],
    [.img(base64: venmoLogoSvg, type: .image(.svg), alt: "Venmo")]
  ),
  .gridColumn(
    sizes: [.mobile: 6, .desktop: 2],
    [.img(base64: atlassianLogoSvg, type: .image(.svg), alt: "Atlassian")]
  )
)

private func footer(
  allEpisodeCount: EpisodeStats.AllEpisodeCount,
  currentUser: User?,
  subscriberState: SubscriberState
  ) -> Node {

  guard !subscriberState.isActive else { return [] }

  let title = currentUser == nil
    ? "Get started with our Free plan"
    : "Get started with our Personal plan"
  let subtitle = currentUser == nil

    ? "Includes a free episode of your choice, plus weekly<br>updates from our newsletter."
    : "Access all \(allEpisodeCount.rawValue) episodes on Point-Free today!"

  let ctaButton: Node = currentUser == nil
    ? .gitHubLink(
      text: "Create your account",
      type: .white,
      // TODO: redirect back to home?
      href: path(to: .login(redirect: url(to: .pricingLanding)))
      )
    : .a(
      attributes: [
        .href(
          path(
            to: .subscribeConfirmation(
              lane: .personal,
              billing: nil,
              isOwnerTakingSeat: nil,
              teammates: nil,
              referralCode: nil,
              useRegionalDiscount: false
            )
          )
        ),
        .class([Class.pf.components.button(color: .white)])
      ],
      "Subscribe"
  )

  return .div(
    attributes: [
      .class([
        Class.pf.colors.bg.gray150,
        Class.padding([.mobile: [.leftRight: 2, .topBottom: 4], .desktop: [.all: 5]]),
        Class.type.align.center
        ]),
    ],
    .h3(
      attributes: [
        .class([
          Class.pf.type.responsiveTitle3,
          Class.pf.colors.fg.white
          ])
      ],
      .text(title)
    ),
    .p(
      attributes: [
        .class([
          Class.pf.colors.fg.white,
          Class.padding([.mobile: [.bottom: 3]])
          ])
      ],
      .raw(subtitle)
    ),
    ctaButton
  )
}

struct PricingPlan {
  let cost: Cost?
  let lane: Pricing.Lane?
  let features: [String]
  let title: String

  struct Cost {
    let title: String?
    let value: String
  }

  var isFree: Bool {
    return self.cost?.value == "$0" && self.lane == nil
  }

  static func free(freeEpisodeCount: EpisodeStats.FreeEpisodeCount) -> PricingPlan {
    return PricingPlan(
      cost: Cost(title: nil, value: "$0"),
      lane: nil,
      features: [
        "Weekly newsletter access",
        "\(freeEpisodeCount.rawValue) free episodes with transcripts",
        "1 free credit to redeem any subscriber-only episode",
        "Download all episode playgrounds"
      ],
      title: "Free"
    )
  }

  static func personal(
    allEpisodeCount: EpisodeStats.AllEpisodeCount,
    episodeHourCount: EpisodeStats.EpisodeHourCount,
    showDiscountOptions: Bool = true
    ) -> PricingPlan {
    return PricingPlan(
      cost: Cost(title: "per&nbsp;month, billed&nbsp;annually", value: "$14"),
      lane: .personal,
      features: [
        "All \(allEpisodeCount.rawValue) episodes with transcripts",
        "Over \(episodeHourCount.rawValue) hours of video",
        "Private RSS feed for offline viewing in podcast apps",
        "Download all episode playgrounds",
      ] + (
        showDiscountOptions
        ? ["""
            [Regional](\(path(to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: true))))
            and [education](\(path(to: .blog(.show(slug: post0010_studentDiscounts.slug))))) discounts
            available
            """]
        : []
      ),
      title: "Personal"
    )
  }

  static let team = PricingPlan(
    cost: Cost(title: "per&nbsp;member, per&nbsp;month, billed&nbsp;annually", value: "$12"),
    lane: .team,
    features: [
      "All personal plan features",
      "For teams of 2 or more",
      "Add teammates at any time with prorated billing",
      "Remove and reassign teammates at any time"
    ],
    title: "Team"
  )

  static let enterprise = PricingPlan(
    cost: nil,
    lane: nil,
    features: [
      "For large teams",
      "Unlimited, company-wide access to all content",
      "Hassle-free team management",
      "Custom sign up landing page for your company",
      "Invoiced billing"
    ],
    title: "Enterprise"
  )
}

extension Array where Element == Faq {
  fileprivate static let allFaqs = [
    Faq(
      question: "Can I upgrade my subscription from monthly to yearly?",
      answer: """
Yes, you can upgrade at any time. You will be charged immediately with a prorated amount based on how much
time you have left in your current billing period.
"""),
    Faq(
      question: "How do team subscriptions work?",
      answer: """
A team subscription consists of a number of seats that you pay for, and those seats can be added, removed
and reassigned at any time. Colleagues are invited to your team over email.
"""),
    Faq(
      question: "Do you offer student discounts?",
      answer: """
We do! If you <a href="mailto:support@pointfree.co?subject=Student%20Discount">email us</a> proof of your
student status (e.g. scan of ID card) we will give you a <strong>50% discount</strong> off of the Personal plan.
"""
    ),
    Faq(
      question: "Do you offer referral discounts?",
      answer: """
We do! If you know someone that has a Point-Free subscription, ask them to share their referral link (available on their account page) with you. If you subscribe with that link you will both receive a month free! 
"""
    ),
    Faq(
      question: "Do you offer country-based discounts?",
      answer: """
Yes! We understand that paying for a subscription in US dollars can be difficult for certain currencies. So we offer [regional](\(path(to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: true)))) discounts of <strong>50% off</strong> every billing cycle when your credit card has been issued from certain countries. For more information, [see here](\(path(to: .subscribeConfirmation(lane: .personal, useRegionalDiscount: true)))).
"""
    ),
  ]
}

private struct WhatToExpectItem {
  let imageSrc: String
  let title: String
  let description: String

  static let newContent = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/regular-updates.jpg",
    title: "New content regularly",
    description: """
We dissect some of the most important topics in functional programming frequently, and deliver them straight
to your inbox.
"""
  )

  static let topics = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/episode-topics.jpg",
    title: "Wide variety of topics",
    description: """
We cover both abstract ideas and practical concepts you can start using in your code base immediately.
"""
  )

  static let playgrounds = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/download-playgrounds.jpg",
    title: "Playground downloads",
    description: """
Download a fully-functioning Swift playground from the episode so you can experiment with the concepts
discussed.
"""
  )

  static let transcripts = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/video-transcription.jpg",
    title: "Video transcripts",
    description: """
We transcribe each video by hand so you can search and reference easily. Click on a timestamp to jump
directly to that point in the video.
"""
  )
}

public let extraSubscriptionLandingStyles =
  Breakpoint.desktop.query(only: screen) {
    extraSubscriptionLandingDesktopStyles
    }
    <> markdownBlockStyles
    <> pricingPlanFeatureStyle
    <> planItem % width(.pct(100))
    <> testimonialStyle

private let desktopBorderStyles: Stylesheet = concat([
  darkRightBorder % key("border-right", "1px solid #333"),
  lightRightBorder % key("border-right", "1px solid #e8e8e8"),
  lightBottomBorder % key("border-bottom", "1px solid #e8e8e8"),
])

private let extraSubscriptionLandingDesktopStyles: Stylesheet =
  desktopBorderStyles
    <> planItem % width(.pct(25))

private let darkRightBorder = CssSelector.class("dark-right-border-d")
private let lightRightBorder = CssSelector.class("light-right-border-d")
private let lightBottomBorder = CssSelector.class("light-bottom-border-d")
private let planItem = CssSelector.class("plan-item")

private let testimonialContainer = CssSelector.class("testimonial-container")
private let testimonialItem = CssSelector.class("testimonial-item")
public let testimonialStyle: Stylesheet =
Breakpoint.desktop.query(only: screen) {
  testimonialContainer % height(.px(400))
  <> testimonialItem % width(.px(340))
  <> testimonialItem % height(.px(380))
}
<> testimonialContainer % (
  height(.px(380))
  <> key("-webkit-overflow-scrolling", "touch")
)
<> testimonialItem % (
  flex(grow: 0, shrink: 0, basis: .auto)
  <> width(.px(260))
  <> height(.px(380))
)

let pricingPlanFeatureClass = CssSelector.class("pricing-plan-feature")
let pricingPlanFeatureStyle: Stylesheet =
  (pricingPlanFeatureClass > "p") % margin(all: 0)
