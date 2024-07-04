import Dependencies
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
        PricingLane("3 months", annualPricePerMonth: 54) {
          "One-time payment"
        } features: {
          baseFeatures
        } callToAction: {
          Button(color: .purple) {
            "Choose Gift"
          }
          .attribute("href", siteRouter.path(for: .gifts(.plan(.threeMonths))))
        }

        PricingLane("6 momths", annualPricePerMonth: 108) {
          "One-time payment"
        } features: {
          baseFeatures
        } callToAction: {
          Button(color: .purple) {
            "Choose Gift"
          }
          .attribute("href", siteRouter.path(for: .gifts(.plan(.sixMonths))))
        }

        PricingLane("1 year", annualPricePerMonth: 168) {
          "One-time payment"
        } features: {
          li { "22% off the 3 and 6 month gift options" }
            .color(.black)
            .backgroundColor(.yellow)
            .inlineStyle("margin", "-2px")
            .inlineStyle("padding", "2px")
          baseFeatures
        } callToAction: {
          Button(color: .purple) {
            "Choose Gift"
          }
          .attribute("href", siteRouter.path(for: .gifts(.plan(.year))))
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

  @HTMLBuilder
  var baseFeatures: some HTML {
    let stats = EpisodesStats()

    li { "Full access for 3 months" }
    li { "All \(stats.allEpisodes) episodes with transcripts" }
    li { "Over \(stats.allHours) hours of video" }
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

