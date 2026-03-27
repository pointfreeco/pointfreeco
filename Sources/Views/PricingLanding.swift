import Dependencies
import Models
import StyleguideV2
import Transcripts

public struct PricingLanding: HTML {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  public init() {}

  public var body: some HTML {
    PageHeader {
      "Become a member"
    } blurb: {
      "Plans for you and your whole team."
    } callToAction: {
      if subscriberState.isActiveSubscriber {
        VStack(alignment: .center) {
          "You’re already a member!"
          Button(color: .white) {
            "Manage your membership"
          }
          .attribute("href", siteRouter.path(for: .account()))
        }
      }
    }

    let stats = EpisodesStats()
    let proFeatures = Pricing.proFeaturesMarkdown(
      allVideosCount: stats.allEpisodes,
      theWayPath: siteRouter.path(for: .theWay),
      livestreamsPath: siteRouter.path(for: .live(.current)),
      regionalDiscountPath: siteRouter.path(
        for: .subscribeConfirmation(
          lane: .personal,
          billing: .monthly,
          plan: .pro,
          referralCode: nil,
          useRegionalDiscount: true
        )
      ),
      educationalDiscountPath: siteRouter.path(for: .blog(.show(.post0010_studentDiscounts)))
    )
    let maxFeatures = Pricing.maxFeaturesMarkdown(
      allVideosCount: stats.allEpisodes,
      theWayPath: siteRouter.path(for: .theWay),
      betasPath: siteRouter.path(for: .betas()),
      livestreamsPath: siteRouter.path(for: .live(.current)),
      regionalDiscountPath: siteRouter.path(
        for: .subscribeConfirmation(
          lane: .personal,
          billing: .yearly,
          plan: .max,
          referralCode: nil,
          useRegionalDiscount: true
        )
      ),
      educationalDiscountPath: siteRouter.path(for: .blog(.show(.post0010_studentDiscounts)))
    )

    PageModule(theme: .content) {
      div {
        input()
          .attribute("id", pricingModeIndividualInputID)
          .attribute("type", "radio")
          .attribute("name", "pricing-mode")
          .attribute("checked", "")
          .inlineStyle("opacity", "0")
          .inlineStyle("pointer-events", "none")
          .inlineStyle("position", "absolute")

        input()
          .attribute("id", pricingModeTeamInputID)
          .attribute("type", "radio")
          .attribute("name", "pricing-mode")
          .inlineStyle("opacity", "0")
          .inlineStyle("pointer-events", "none")
          .inlineStyle("position", "absolute")

        VStack(alignment: .center, spacing: 1.5) {
          HStack(alignment: .center, spacing: 0.25) {
            label { "Individual" }
              .attribute("for", pricingModeIndividualInputID)
              .inlineStyle("background-color", "#111")
              .inlineStyle("background-color", "transparent", pre: teamPricingCheckedSelector)
              .inlineStyle("border", "1px solid #111")
              .inlineStyle("border-radius", "999px")
              .inlineStyle("color", "#fff")
              .inlineStyle("color", "#111", pre: teamPricingCheckedSelector)
              .inlineStyle("cursor", "pointer")
              .inlineStyle("font-size", "0.875rem")
              .inlineStyle("font-weight", "500")
              .inlineStyle("padding", "0.5rem 0.875rem")
            label { "Team" }
              .attribute("for", pricingModeTeamInputID)
              .inlineStyle("background-color", "transparent")
              .inlineStyle("background-color", "#111", pre: teamPricingCheckedSelector)
              .inlineStyle("border", "1px solid #111")
              .inlineStyle("border-radius", "999px")
              .inlineStyle("color", "#111")
              .inlineStyle("color", "#fff", pre: teamPricingCheckedSelector)
              .inlineStyle("cursor", "pointer")
              .inlineStyle("font-size", "0.875rem")
              .inlineStyle("font-weight", "500")
              .inlineStyle("padding", "0.5rem 0.875rem")
          }

          LazyVGrid(columns: [.desktop: [1, 1, 1, 1]]) {
            PricingLane("Free") {
              Price(amount: 0)
            } features: {
              li { "Weekly newsletter access" }
              li { "\(stats.freeEpisodes) free videos with transcripts" }
              li { "1 free credit to redeem any members only video" }
              li { "Download all video code samples" }
            } callToAction: {
              if currentUser == nil {
                Button(color: .purple) {
                  "Choose plan"
                }
                .attribute(
                  "href",
                  siteRouter.path(
                    for: .auth(.authLanding(kind: .signUp, redirect: siteRouter.url(for: currentRoute)))
                  )
                )
              } else if subscriberState.isNonSubscriber {
                Button(color: .purple, style: .outline) {
                  "Your plan"
                }
                .inlineStyle("cursor", "not-allowed")
              }
            }

            PricingLane("Pro") {
              ToggleablePrice(
                individualAmount: 24,
                individualDetails: "per month",
                teamAmount: 16,
                teamDetails: "per member/month*"
              )
            } features: {
              li { HTMLText(Pricing.proTeamSavingsFeature) }
                .inlineStyle("display", "none")
                .inlineStyle("display", "list-item", pre: teamPricingCheckedSelector)
              for feature in proFeatures {
                li { HTMLMarkdown(feature) }
              }
            } callToAction: {
              if subscriberState.isNonSubscriber {
                Button(color: .purple) {
                  "Choose plan"
                }
                .attribute(
                  "href",
                  siteRouter.path(
                    for: .subscribeConfirmation(
                      lane: .personal,
                      billing: .monthly,
                      plan: .pro
                    )
                  )
                )
                .inlineStyle("display", "inline-flex")
                .inlineStyle("display", "none", pre: teamPricingCheckedSelector)
                Button(color: .purple) {
                  "Choose plan"
                }
                .attribute(
                  "href",
                  siteRouter.path(
                    for: .subscribeConfirmation(
                      lane: .team,
                      billing: .yearly,
                      plan: .pro
                    )
                  )
                )
                .inlineStyle("display", "none")
                .inlineStyle("display", "inline-flex", pre: teamPricingCheckedSelector)
              }
            }

            PricingLane("Max") {
              ToggleablePrice(
                individualAmount: 349,
                individualDetails: "per year",
                teamAmount: 329,
                teamDetails: "per member/year"
              )
            } features: {
              li { HTMLText(Pricing.maxTeamSavingsFeature) }
                .inlineStyle("display", "none")
                .inlineStyle("display", "list-item", pre: teamPricingCheckedSelector)
              for feature in maxFeatures {
                li { HTMLMarkdown(feature) }
              }
            } callToAction: {
              if subscriberState.isNonSubscriber {
                Button(color: .purple) {
                  "Choose plan"
                }
                .attribute(
                  "href",
                  siteRouter.path(
                    for: .subscribeConfirmation(
                      lane: .personal,
                      billing: .yearly,
                      plan: .max
                    )
                  )
                )
                .inlineStyle("display", "inline-flex")
                .inlineStyle("display", "none", pre: teamPricingCheckedSelector)
                Button(color: .purple) {
                  "Choose plan"
                }
                .attribute(
                  "href",
                  siteRouter.path(
                    for: .subscribeConfirmation(
                      lane: .team,
                      billing: .yearly,
                      plan: .max
                    )
                  )
                )
                .inlineStyle("display", "none")
                .inlineStyle("display", "inline-flex", pre: teamPricingCheckedSelector)
              }
            }

            PricingLane("Enterprise") {
              li { "For large teams" }
              li { "Unlimited, company-wide access to all content" }
              li { "Hassle-free team management" }
              li { "Custom sign up landing page for your company" }
              li { "Invoiced billing" }
            } callToAction: {
              if !subscriberState.isEnterpriseSubscriber {
                Button(color: .black, style: .outline) {
                  "Contact us"
                }
                .attribute("href", "mailto:support@pointfree.co")
                .linkColor(.black.dark(.white))
              } else {
                Button(color: .black, style: .outline) {
                  "Your plan"
                }
                .inlineStyle("cursor", "not-allowed")
              }
            }
          }
          .linkUnderline(true)

          small {
            "*All team memberships billed annually."
          }
          .color(.gray500)
          .inlineStyle("display", "none")
          .inlineStyle("display", "block", pre: teamPricingCheckedSelector)
          .inlineStyle("font-size", "0.875rem")
          .inlineStyle("text-align", "center")
        }
        .attribute("class", pricingModeContentClass)
      }
      .inlineStyle("width", "100%")
    }

    WhatToExpect()
    FAQModule(faqs: .allFaqs)
    WhatPeopleAreSaying()
    Companies()
    if currentUser == nil {
      GetStartedModule(style: .gradient)
    }
  }
}

private let pricingModeIndividualInputID = "pricing-mode-individual"
private let pricingModeTeamInputID = "pricing-mode-team"
private let pricingModeContentClass = "pricing-mode-content"
private let teamPricingCheckedSelector =
  "#\(pricingModeTeamInputID):checked ~ .\(pricingModeContentClass)"

private struct Price: HTML {
  let amount: Int
  let details: String?

  init(amount: Int, details: String? = nil) {
    self.amount = amount
    self.details = details
  }

  var body: some HTML {
    HStack(alignment: .center) {
      div {
        Header(3) { "$\(amount)" }
          .inlineStyle("font-size", "2rem")
          .inlineStyle("font-weight", "300")
      }
      if let details {
        div {
          HTMLText(details)
        }
        .inlineStyle("font-size", "0.75rem")
      }
    }
  }
}

private struct ToggleablePrice: HTML {
  let individualAmount: Int
  let individualDetails: String
  let teamAmount: Int
  let teamDetails: String

  var body: some HTML {
    HTMLGroup {
      Price(amount: individualAmount, details: individualDetails)
        .inlineStyle("display", "flex")
        .inlineStyle("display", "none", pre: teamPricingCheckedSelector)
      Price(amount: teamAmount, details: teamDetails)
        .inlineStyle("display", "none")
        .inlineStyle("display", "flex", pre: teamPricingCheckedSelector)
    }
  }
}
