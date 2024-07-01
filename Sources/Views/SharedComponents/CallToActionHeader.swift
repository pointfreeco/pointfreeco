import StyleguideV2

public struct CallToActionHeader<PrimaryCTA: HTML>: HTML {
  var title: String
  var blurb: String
  let primaryCTA: PrimaryCTA
  var secondaryCTATitle: String?
  var secondaryCTAURL: String?
  var style: CallToActionHeaderStyle

  public init(
    title: String,
    blurb: String,
    secondaryCTATitle: String? = nil,
    secondaryCTAURL: String? = nil,
    style: CallToActionHeaderStyle,
    @HTMLBuilder primaryCTA: () -> PrimaryCTA
  ) {
    self.title = title
    self.blurb = blurb
    self.primaryCTA = primaryCTA()
    self.secondaryCTATitle = secondaryCTATitle
    self.secondaryCTAURL = secondaryCTAURL
    self.style = style
  }

  public init(
    title: String,
    blurb: String,
    ctaTitle: String,
    ctaURL: String,
    secondaryCTATitle: String? = nil,
    secondaryCTAURL: String? = nil,
    style: CallToActionHeaderStyle
  ) where PrimaryCTA == HTMLInlineStyle<_HTMLAttributes<Button<HTMLText>>> {
    self.title = title
    self.blurb = blurb
    self.primaryCTA = Button(color: .purple, size: .regular, style: .normal) {
      HTMLText(ctaTitle)
    }
    .attribute("href", ctaURL)
    .inlineStyle("display", "inline-block")
    self.secondaryCTATitle = secondaryCTATitle
    self.secondaryCTAURL = secondaryCTAURL
    self.style = style
  }

  public var body: some HTML {
    div {
      div {
        HTMLGroup {
          div {
            Header(2) { HTMLRaw(title) }
              .color(style.titleColor)
          }

          div {
            Paragraph(.big) { HTMLRaw(blurb) }
              .fontStyle(.body(.regular))
              .color(style.blurbColor)
              .inlineStyle("margin", "0 auto", media: .desktop)
              .inlineStyle("max-width", "40rem")
          }

          div {
            primaryCTA
              .inlineStyle("margin-top", "3rem")
          }

          if let secondaryCTAURL, let secondaryCTATitle {
            Link(secondaryCTATitle, href: secondaryCTAURL)
              .linkStyle(.init(color: style.secondaryCTAColor, underline: true))
              .fontStyle(.body(.small))
          }
        }
        .inlineStyle("text-align", "center", media: .desktop)
      }
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "1280px")
      .background(style.contentBackgroundColor)
      .padding(topBottom: .large, leftRight: .medium)
      .padding(.extraLarge, .desktop)
      .flexContainer(
        direction: "column",
        wrap: "wrap",
        rowGap: "0.5rem"
      )
      .inlineStyle("align-items", "center", media: .desktop)
    }
    .background(style.backgroundColor)
  }
}

public struct CallToActionHeaderStyle {
  var backgroundColor: PointFreeColor
  var contentBackgroundColor: PointFreeColor?
  var titleColor: PointFreeColor
  var blurbColor: PointFreeColor
  var secondaryCTAColor: PointFreeColor
  public static let gradient = Self(
    backgroundColor: PointFreeColor(rawValue: "linear-gradient(#121212, #291a40)"),
    titleColor: .white,
    blurbColor: .gray800,
    secondaryCTAColor: .gray650
  )
  public static let solid = Self(
    backgroundColor: .white.dark(.black),
    contentBackgroundColor: .offWhite.dark(.offBlack),
    titleColor: .black.dark(.white),
    blurbColor: .gray300.dark(.gray800),
    secondaryCTAColor: .gray650.dark(.gray400)
  )
}
