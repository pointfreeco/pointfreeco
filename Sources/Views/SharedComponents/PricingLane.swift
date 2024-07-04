import StyleguideV2
import Tagged
import TaggedMoney

struct Lane<PriceDetails: HTML, Features: HTML, CallToAction: HTML>: HTML {
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
