import StyleguideV2

struct CalloutModule: HTML {
  let title: String
  let subtitle: String
  let ctaTitle: String
  let ctaURL: String
  var body: some HTML {
    div {
      VStack(alignment: .leading, spacing: 1) {
        div {
          Header(3) { HTMLText(title) }
            .color(.gray150.dark(.gray850))
        }

        div {
          Paragraph(.big) { HTMLText(subtitle) }
            .color(.gray300.dark(.gray800))
            .inlineStyle("max-width", "40rem", media: .desktop)
        }

        Button(color: .purple, size: .regular, style: .normal) {
          HTMLText(ctaTitle)
        }
        .attribute("href", ctaURL)
        .inlineStyle("margin-top", "1rem")
      }
      .inlineStyle("max-width", "1280px")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("align-items", "center", media: .desktop)
      .backgroundColor(.init(rawValue: "#fafafa").dark(.init(rawValue: "#050505")))
      .inlineStyle("padding", "4rem 2rem")
      .inlineStyle("padding", "4rem 3rem", media: .desktop)
    }
    .inlineStyle("padding", "0 2rem", media: .desktop)
    .inlineStyle("max-width", "100%")
    .backgroundColor(.white.dark(.black))
  }
}
