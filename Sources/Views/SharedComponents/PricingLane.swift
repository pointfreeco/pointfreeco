import StyleguideV2
import Tagged
import TaggedMoney

struct PricingLane<PriceDetails: HTML, Badge: HTML, Features: HTML, CallToAction: HTML>: HTML {
  var name: String
  var priceDetails: PriceDetails?
  var badge: Badge?
  var features: Features
  var callToAction: CallToAction

  init(
    _ name: String,
    @HTMLBuilder priceDetails: () -> PriceDetails = { Never?.none },
    @HTMLBuilder badge: () -> Badge = { Never?.none },
    @HTMLBuilder features: () -> Features,
    @HTMLBuilder callToAction: () -> CallToAction
  ) {
    self.name = name
    self.priceDetails = priceDetails()
    self.badge = badge()
    self.features = features()
    self.callToAction = callToAction()
  }

  var body: some HTML {
    Card {
      VStack {
        if let badge {
          div { badge }
            .inlineStyle("position", "absolute")
            .inlineStyle("top", "0.75rem")
            .inlineStyle("right", "0.75rem")
        }
        Header(4) { HTMLText(name) }
          .inlineStyle("margin-top", "1.5rem")
        if let priceDetails {
          div {
            priceDetails
          }
          .inlineStyle("font-size", "0.75rem")
        }
        ul {
          features
        }
        .color(.gray500.dark(.gray800))
        .linkColor(.gray150.dark(.gray900))
        .flexContainer(direction: "column", rowGap: "0.5rem")
        .inlineStyle("font-size", "0.875rem")
        .inlineStyle("list-style", "disc")
        .inlineStyle("margin", "0 0 1.5rem")
        .inlineStyle("padding-left", "1.25rem")
      }
      .color(.black.dark(.white))
      .inlineStyle("position", "relative")
    } footer: {
      callToAction
        .flexContainer(justification: "center")
    }
  }
}
