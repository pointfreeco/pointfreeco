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
    PricingFAQ()
    WhatPeopleAreSaying()
    Companies()
    if currentUser == nil {
      GetStartedModule(style: .gradient)
    }
  }
}

private struct Lane<PriceDetails: HTML, Features: HTML, CallToAction: HTML>: HTML {
  var name: String
  var annualPricePerMonth: Dollars<Int>?
  var priceDetails: PriceDetails?
  var features: Features
  var callToAction: CallToAction

  init(
    _ name: String,
    annualPricePerMonth: Dollars<Int>? = nil,
    @HTMLBuilder priceDetails: () -> PriceDetails = { Never?.none },
    @HTMLBuilder features: () -> Features,
    @HTMLBuilder callToAction: () -> CallToAction
  ) {
    self.name = name
    self.annualPricePerMonth = annualPricePerMonth
    self.priceDetails = priceDetails()
    self.features = features()
    self.callToAction = callToAction()
  }

  var body: some HTML {
    Card {
      VStack {
        Header(4) { HTMLText(name) }
          .inlineStyle("margin-top", "1.5rem")
        if let annualPricePerMonth {
          HStack(alignment: .center) {
            div {
              Header(3) { HTMLText("$\(annualPricePerMonth)") }
                .inlineStyle("font-size", "2rem")
                .inlineStyle("font-weight", "300")
            }

            if let priceDetails {
              div {
                priceDetails
              }
              .inlineStyle("font-size", "0.75rem")
            }
          }
        }
        ul {
          features
        }
        .color(.gray500.dark(.gray800))
        .linkColor(.gray150.dark(.gray900))
        .flexContainer(direction: "column", rowGap: "0.5rem")
        .listStyle(.reset)
        .inlineStyle("font-size", "0.875rem")
        .inlineStyle("margin", "0 0 1.5rem")
      }
      .color(.black.dark(.white))
    } footer: {
      callToAction
        .flexContainer(justification: "center")
    }
  }
}

private struct EpisodesStats {
  var allEpisodes: Int = 0
  var allHours: Int = 0
  var freeEpisodes: Int = 0

  init() {
    @Dependency(\.episodes) var episodes
    @Dependency(\.envVars.emergencyMode) var emergencyMode
    @Dependency(\.date.now) var now

    var allSeconds = 0
    for episode in episodes() {
      guard episode.publishedAt < now else { continue }
      allEpisodes += 1
      allSeconds += episode.length.rawValue
      if !episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode) {
        freeEpisodes += 1
      }
    }
    allHours = allSeconds / 3600
  }
}

private struct PricingFAQ: HTML {
  var body: some HTML {
    PageModule(title: "FAQ", theme: .content) {
      VStack(spacing: 1.5) {
        HTMLForEach([Faq].allFaqs) { faq in
          Header(5) {
            HTMLText(faq.question)
          }
          .color(.black.dark(.offWhite))

          HTMLMarkdown(faq.answer)
        }
      }
      .color(.gray300.dark(.gray850))
      .linkColor(.gray150.dark(.gray900))
      .linkUnderline(true)
      .inlineStyle("margin", "0 auto")
      .inlineStyle("width", "50%", media: .desktop)
    }
  }
}
