import Dependencies
import StyleguideV2
import TaggedMoney

public struct PricingV2: HTML {
  struct Lane<Features: HTML, CallToAction: HTML>: HTML {
    var name: String
    var annualPricePerMonth: Dollars<Int>?
    var priceDetails: String?
    var features: Features
    var callToAction: CallToAction

    init(
      _ name: String,
      annualPricePerMonth: Dollars<Int>? = nil,
      priceDetails: String? = nil,
      @HTMLBuilder features: () -> Features,
      @HTMLBuilder callToAction: () -> CallToAction = { DefaultCallToAction() }
    ) {
      self.name = name
      self.annualPricePerMonth = annualPricePerMonth
      self.priceDetails = priceDetails
      self.features = features()
      self.callToAction = callToAction()
    }

    var body: some HTML {
      Card {
        VStack {
          Header(4) { HTMLText(name) }
          if let annualPricePerMonth {
            HStack(alignment: .center) {
              span { HTMLText("\(annualPricePerMonth)") }
              if let priceDetails {
                HTMLText(priceDetails)
              }
            }
          }
          ul {
            features
          }
          .listStyle(.reset)
        }
      } footer: {
        callToAction
          .flexContainer(justification: "center")
      }
    }
  }

  struct DefaultCallToAction: HTML {
    var body: some HTML {
      Button(color: .purple) {
        "Choose plan"
      }
      .attribute("href", "#TODO")
    }
  }

  @Dependency(\.currentUser) var currentUser

  public init() {}

  public var body: some HTML {
    PageHeader {
      "Pricing"
    } blurb: {
      "Plans for you and your whole team."
    }

    PageModule(theme: .content) {
      LazyVGrid(columns: [.desktop: [1, 1, 1, 1]]) {
        Lane("Free", annualPricePerMonth: 0) {
          li { "Weekly newsletter access" }
          li { "(free episode count) free episodes with transcripts" }
          li { "1 free credit to redeem any subscriber-only episode" }
          li { "Download all episode sample code" }
        }
        Lane("Individual", annualPricePerMonth: 14, priceDetails: "per month, billed annually") {
          li { "All (episode count) episodes with transcripts" }
          li { "Over (hour count) hours of video" }
          li { "Personal podcast feed for offline viewing" }
          li { "Download all episode sample code" }
        }
        Lane(
          "Team", annualPricePerMonth: 12, priceDetails: "per member, per month, billed annually"
        ) {
          li { "All personal plan features" }
          li { "For teams of 2 or more" }
          li { "Add teammates at any time with prorated billing" }
          li { "Remove and reassign team mates at any time" }
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
        }
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

private struct PricingFAQ: HTML {
  var body: some HTML {
    PageModule(title: "FAQ", theme: .informational) {
      VStack {
        for faq in [Faq].allFaqs {
          Header(4) {
            HTMLText(faq.question)
          }
          Paragraph {
            HTMLMarkdown(faq.answer)
          }
        }
      }
//      .inlineStyle("padding", "2rem")
//      .inlineStyle("padding", "4rem", media: .desktop)
    }
  }
}
