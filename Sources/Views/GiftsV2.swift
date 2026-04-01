import Dependencies
import Models
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
      Purchase a Point-Free membership for a friend, colleague or loved one.
      """
    }

    PageModule(theme: .content) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        HTMLForEach(Gifts.Plan.allCases) { plan in
          PricingLane(plan.laneTitle) {
            Header(3) { "$\(plan.amount.rawValue / 100)" }
              .inlineStyle("font-size", "2rem")
              .inlineStyle("font-weight", "300")
            div { "one-time payment" }
              .inlineStyle("font-size", "0.75rem")
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
        Nope. A gift membership is a one-time payment and you will not be charged again.
        """
    ),
    Faq(
      question: "When am I charged and when does access start?",
      answer: """
        You are charged immediately, but the membership does not start until the recipient \
        accepts your gift.
        """
    ),
    .existingSubscriberRedeemGift,
    .combinedWithStudentDiscountsEtc,
  ]
}

extension Faq {
  static let existingSubscriberRedeemGift = Self(
    question: "Can I accept a gift if I already have a Point-Free membership?",
    answer: """
      Yes! If you receive a gift and are currently a member we will apply the credit to your \
      account and the amount will be applied to future invoices.
      """
  )

  static let combinedWithStudentDiscountsEtc = Self(
    question: """
      Can gifts be combined with student discounts, referrals, regional discounts, etc.?
      """,
    answer: """
      Unfortunately not at this time. Gifts are charged at the full price of our \
      [regular](/pricing) memberships.
      """
  )
}

extension Gifts.Plan {
  public var laneTitle: String {
    switch self {
    case .sixMonthsPro: "6 Months Pro"
    case .yearlyPro: "1 Year Pro"
    case .yearlyMax: "1 Year Max"
    }
  }

  var duration: String {
    switch self {
    case .sixMonthsPro: "6 months"
    case .yearlyPro: "1 year"
    case .yearlyMax: "1 year"
    }
  }
  var tier: String {
    switch self {
    case .sixMonthsPro, .yearlyPro: "Pro"
    case .yearlyMax: "Max"
    }
  }

  @HTMLBuilder
  fileprivate var laneFeatures: some HTML {
    @Dependency(\.siteRouter) var siteRouter
    let stats = EpisodesStats()

    switch self {
    case .sixMonthsPro:
      li { "Full Pro access for 6 months" }
    case .yearlyPro:
      li { "Full Pro access for 1 year" }
    case .yearlyMax:
      li { "Full Max access for 1 year" }
    }
    li { "All \(stats.allEpisodes) videos with transcripts" }
    if self == .yearlyMax {
      li {
        Link("Early access", href: siteRouter.path(for: .betas()))
        " to new libraries and AI skills"
      }
      li { "Attend office hours and private livestreams" }
    }
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
    li { "Download all video code samples" }
  }
}
