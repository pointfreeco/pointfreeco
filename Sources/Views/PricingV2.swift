import Dependencies
import StyleguideV2
import TaggedMoney
import Transcripts

public struct PricingV2: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.episodes) var episodes
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  public init() {}

  public var body: some HTML {
    // TODO: Recapture "You‘re already a subscriber! [Manage your account]"
    PageHeader {
      "Pricing"
    } blurb: {
      "Plans for you and your whole team."
    }

    let stats = EpisodesStats()

    PageModule(theme: .content) {
      VStack(alignment: .center) {
        LazyVGrid(columns: [.desktop: [1, 1, 1, 1]]) {
          Lane("Free", annualPricePerMonth: 0) {
            li { "Weekly newsletter access" }
            li { "\(stats.freeEpisodes) free episodes with transcripts" }
            li { "1 free credit to redeem any subscriber-only episode" }
            li { "Download all episode code samples" }
          } callToAction: {
            Button(color: .purple) {
              "Choose plan"
            }
            .attribute("href", siteRouter.path(for: .signUp(redirect: siteRouter.url(for: currentRoute))))
          }
          Lane("Individual", annualPricePerMonth: 14) {
            "per month,"
            br()
            "billed annually"
          } features: {
            li { "All \(stats.allEpisodes) episodes with transcripts" }
            li { "Over \(stats.allHours) hours of video" }
            li {
              "Watch past "
              Link("livestreams", href: siteRouter.path(for: .live(.current)))
            }
            li { "Personal podcast feed for offline viewing" }
            li { "Download all episode code samples" }
            li {
              Link(
                "Regional",
                href: siteRouter.path(
                  for: .subscribeConfirmation(
                    lane: .personal,
                    referralCode: nil, // TODO?
                    useRegionalDiscount: true
                  )
                )
              )
              " and "
              Link(
                "educational",
                href: siteRouter.path(for: .blog(.show(slug: post0010_studentDiscounts.slug)))
              )
              " discounts available"
            }
          } callToAction: {
            Button(color: .purple) {
              "Choose plan"
            }
            .attribute("href", siteRouter.path(for: .subscribeConfirmation(lane: .personal)))
          }
          Lane("Team", annualPricePerMonth: 12) {
            "per member, per month,"
            br()
            "billed annually"
          } features: {
            li { "All personal plan features" }
            li { "For teams of 2 or more" }
            li { "Add teammates at any time with prorated billing" }
            li { "Reassign team mates at any time" }
          } callToAction: {
            Button(color: .purple) {
              "Choose plan"
            }
            .attribute("href", siteRouter.path(for: .subscribeConfirmation(lane: .team)))
          }
          Lane("Enterprise") {
            li { "For large teams" }
            li { "Unlimited, company-wide access to all content" }
            li { "Hassle-free team management" }
            li { "Custom sign up landing page for your company" }
            li { "Invoiced billing" }
          } callToAction: {
            Button(color: .black, style: .outline) {
              "Contact us"
            }
            .attribute("href", "mailto:support@pointfree.co")
            .linkColor(.black.dark(.white))
          }
        }
        .linkUnderline(true)

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
