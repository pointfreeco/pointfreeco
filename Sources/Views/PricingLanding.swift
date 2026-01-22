import Dependencies
import StyleguideV2
import TaggedMoney
import Transcripts

public struct PricingLanding: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.episodes) var episodes
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  public init() {}

  public var body: some HTML {
    PageHeader {
      "Pricing"
    } blurb: {
      "Plans for you and your whole team."
    } callToAction: {
      if subscriberState.isActiveSubscriber {
        VStack(alignment: .center) {
          "You’re already a subscriber!"
          Button(color: .white) {
            "Manage your subscription"
          }
          .attribute("href", siteRouter.path(for: .account()))
        }
      }
    }

    let stats = EpisodesStats()

    PageModule(theme: .content) {
      LazyVGrid(columns: [.desktop: [1, 1, 1, 1]]) {
        PricingLane("Free", annualPricePerMonth: 0) {
          li { "Weekly newsletter access" }
          li { "\(stats.freeEpisodes) free episodes with transcripts" }
          li { "1 free credit to redeem any subscriber-only episode" }
          li { "Download all episode code samples" }
        } callToAction: {
          if currentUser == nil {
            Button(color: .purple) {
              "Choose plan"
            }
            .attribute(
              "href",
              siteRouter.path(for: .auth(.signUp(redirect: siteRouter.url(for: currentRoute))))
            )
          } else if subscriberState.isNonSubscriber {
            Button(color: .purple, style: .outline) {
              "Your plan"
            }
            .inlineStyle("cursor", "not-allowed")
          }
        }
        PricingLane("Individual", annualPricePerMonth: 14) {
          "per month,"
          br()
          "billed annually"
        } features: {
          li { "All \(stats.allEpisodes) episodes with transcripts" }
          if currentUser.hasAccess(to: .thePointFreeWay) {
            li {
              "Access to \""
              Link("The Point-Free Way", destination: .theWay)
              "\""
            }
          }
          li {
            "Watch past "
            Link("livestreams", destination: .live(.current))
          }
          li { "Private podcast feed for offline viewing" }
          li {
            Link(
              "Regional",
              destination: .subscribeConfirmation(
                lane: .personal,
                referralCode: nil,  // TODO?
                useRegionalDiscount: true
              )
            )
            " and "
            Link(
              "educational",
              destination: .blog(.show(.post0010_studentDiscounts))
            )
            " discounts available"
          }
        } callToAction: {
          if subscriberState.isNonSubscriber {
            Button(color: .purple) {
              "Choose plan"
            }
            .attribute("href", siteRouter.path(for: .subscribeConfirmation(lane: .personal)))
          }
        }
        PricingLane("Team", annualPricePerMonth: 12) {
          "per member, per month,"
          br()
          "billed annually"
        } features: {
          li { "All individual plan features" }
          li { "For teams of 2 or more" }
          li { "Add teammates at any time with prorated billing" }
          li { "Reassign team mates at any time" }
        } callToAction: {
          // TODO: Would be nice to upsell here for personal subscriptions
          if subscriberState.isNonSubscriber {
            Button(color: .purple) {
              "Choose plan"
            }
            .attribute("href", siteRouter.path(for: .subscribeConfirmation(lane: .team)))
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

      VStack(alignment: .center) {
        small {
          "Prices shown with annual billing. When billed month to month, the "
          br()
          strong { "Personal" }
          " plan is $18, and the "
          strong { "Team" }
          " plan is $16 per member per month."
        }
        .color(.gray500)
        .inlineStyle("font-size", "0.875rem")
        .inlineStyle("text-align", "center")
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
