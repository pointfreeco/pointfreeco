import Dependencies
import PointFreeRouter
import StyleguideV2
import TaggedMoney
import Transcripts

public struct GiftsV2: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  public init() {}

  public var body: some HTML {
    PageHeader {
      "Gifts"
    } blurb: {
      """
      Purchase a 3, 6, or 12 month subscription for a friend, colleague or loved one.
      """
    }

    PageModule(theme: .content) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        HTMLForEach(Gifts.Plan.allCases) { plan in
          PricingLane(plan.laneTitle, annualPricePerMonth: plan.laneAnnualPricePerMonth) {
            "One-time payment"
          } features: {
            plan.laneFeatures
          } callToAction: {
            Button(color: .purple) {
              "Choose Gift"
            }
            .attribute("href", siteRouter.path(for: .gifts(.plan(plan))))
          }
        }
      }
      .linkUnderline(true)
    }

    WhatToExpect()
    FAQModule(faqs: .giftFaqs)
    WhatPeopleAreSaying()
    Companies()
    if currentUser == nil {
      GetStartedModule(style: .gradient)
    }
  }
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
        You are charged immediately, but the subscription does not start until the recipient \
        accepts your gift.
        """),
    .existingSubscriberRedeemGift,
    .combinedWithStudentDiscountsEtc,
  ]
}

extension Faq {
  static let existingSubscriberRedeemGift = Self(
    question: "Can I accept a gift if I already have a Point-Free subscription?",
    answer: """
      Yes! If you receive a gift and are currently a subscriber we will apply the credit to your \
      account and the amount will be applied to future invoices.
      """)

  static let combinedWithStudentDiscountsEtc = Self(
    question: """
      Can gift subscriptions be combined with student discounts, referrals, regional \
      discounts, etc.?
      """,
    answer: """
      Unfortunately not at this time. Gift subscriptions are charged at the full price of our \
      [regular](/pricing) subscriptions.
      """
  )
}

extension Gifts.Plan {
  fileprivate var laneTitle: String {
    switch self {
    case .threeMonths: "3 months"
    case .sixMonths: "6 months"
    case .year: "1 year"
    }
  }

  fileprivate var laneAnnualPricePerMonth: Dollars<Int> {
    amount.map(Double.init).dollars.map(Int.init)
  }

  @HTMLBuilder
  fileprivate var laneFeatures: some HTML {
    switch self {
    case .threeMonths:
      li { "Full access for 3 months" }
      baseFeatures
    case .sixMonths:
      li { "Full access for 6 months" }
      baseFeatures
    case .year:
      li { "22% off the 3 and 6 month gift options" }
        .color(.black)
        .backgroundColor(.yellow)
        .inlineStyle("margin", "-2px")
        .inlineStyle("padding", "2px")
      li { "Full access for 1 year" }
      baseFeatures
    }
  }

  @HTMLBuilder
  private var baseFeatures: some HTML {
    @Dependency(\.siteRouter) var siteRouter
    let stats = EpisodesStats()

    li { "All \(stats.allEpisodes) episodes with transcripts" }
    li {
      "Access to \""
      Link("The Point-Free Way", destination: .theWay)
      "\""
    }
    li {
      "Access to all past "
      Link(
        "livestreams",
        href: siteRouter.path(for: .collections(.collection("livestreams", .show)))
      )
      " at 1080p"
    }
    li { "Private RSS feed for offline viewing" }
    li { "Download all episode code samples" }
  }
}
