import StyleguideV2

struct CalloutModule: HTML {
  let title: String
  let subtitle: String
  let ctaTitle: String
  let ctaURL: String
  var secondaryCTATitle: String?
  var secondaryCTAURL: String?
  var backgroundColor = PointFreeColor(rawValue: "#fafafa", darkValue: "#050505")
  var body: some HTML {
    div {
      VStack(alignment: .leading) {
        div {
          Header(3) { HTMLText(title) }
            .color(.gray150.dark(.gray850))
        }

        div {
          HTMLMarkdown(subtitle)
            .color(.gray150.dark(.gray800))
            .inlineStyle("max-width", "40rem", media: .desktop)
        }
        .color(.gray300.dark(.gray800))

        VStack(alignment: .center, spacing: 0.25) {
          Button(color: .purple, size: .regular, style: .normal) {
            HTMLText(ctaTitle)
          }
          .attribute("href", ctaURL)
          if let secondaryCTAURL, let secondaryCTATitle {
            Link(secondaryCTATitle, href: secondaryCTAURL)
              .linkStyle(.init(color: .gray150.dark(.gray800), underline: true))
              .fontStyle(.body(.small))
          }
        }
        .inlineStyle("margin-top", "1rem")
      }
      .inlineStyle("max-width", "1280px")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("align-items", "center", media: .desktop)
      .backgroundColor(backgroundColor)
      .inlineStyle("padding", "4rem 2rem")
      .inlineStyle("padding", "4rem 3rem", media: .desktop)
    }
    .inlineStyle("padding", "0 2rem", media: .desktop)
    .inlineStyle("max-width", "100%")
    .backgroundColor(.white.dark(.black))
  }
}
