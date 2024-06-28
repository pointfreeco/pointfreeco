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
    div {
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
      .inlineStyle("margin", "0 auto")
      .inlineStyle("padding", "6rem 2rem")
      .inlineStyle("padding", "8rem 3rem", media: .desktop)
    }
    .inlineStyle("box-sizing", "border-box")
    .grid(alignment: .center)
    .inlineStyle("background", "linear-gradient(#121212, #242424)")
  }
}
