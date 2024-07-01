import StyleguideV2

public struct PageHeader<Title: HTML, Blurb: HTML>: HTML {
  var title: Title
  @HTMLBuilder var blurb: Blurb

  public init(
    title: String,
    @HTMLBuilder blurb: () -> Blurb
  ) where Title == HTMLText {
    self.title = HTMLText(title)
    self.blurb = blurb()
  }

  public init(
    @HTMLBuilder title: () -> Title,
    @HTMLBuilder blurb: () -> Blurb
  ) {
    self.title = title()
    self.blurb = blurb()
  }

  public var body: some HTML {
    VStack(alignment: .center) {
      div {
        Header(2) { title }
          .color(.white)

        Paragraph(.big) { blurb }
          .fontStyle(.body(.regular))
          .color(.gray800)
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
