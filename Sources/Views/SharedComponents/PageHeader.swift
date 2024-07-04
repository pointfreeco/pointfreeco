import StyleguideV2

public struct PageHeader<Title: HTML, Blurb: HTML, CallToAction: HTML>: HTML {
  var title: Title
  var blurb: Blurb
  var callToAction: CallToAction?

  public init(
    title: String,
    @HTMLBuilder blurb: () -> Blurb,
    @HTMLBuilder callToAction: () -> CallToAction? = { Never?.none }
  ) where Title == HTMLText {
    self.title = HTMLText(title)
    self.blurb = blurb()
    self.callToAction = callToAction()
  }

  public init(
    @HTMLBuilder title: () -> Title,
    @HTMLBuilder blurb: () -> Blurb,
    @HTMLBuilder callToAction: () -> CallToAction? = { Never?.none }
  ) {
    self.title = title()
    self.blurb = blurb()
    self.callToAction = callToAction()
  }

  public var body: some HTML {
    VStack {
      HStack(alignment: .center) {
        div {
          Header(2) { title }
            .color(.white)

          Paragraph(.big) { blurb }
            .fontStyle(.body(.regular))
            .color(.gray800)
        }
        .grow()

        div {
          callToAction
        }
        .color(.offWhite)
      }
      .inlineStyle("box-sizing", "border-box")
      .inlineStyle("flex-basis", "100%")
      .inlineStyle("max-width", "1280px")
      .inlineStyle("width", "100%")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("padding", "6rem 2rem")
      .inlineStyle("padding", "8rem 3rem", media: .desktop)
    }
    .inlineStyle("box-sizing", "border-box")
    .inlineStyle("background", "linear-gradient(#121212, #242424)")
  }
}
