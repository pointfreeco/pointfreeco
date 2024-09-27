import StyleguideV2

struct CenterColumn<Content: HTML>: HTML {
  @HTMLBuilder let content: Content
  public var body: some HTML {
    blockTag("pf-center-column") {
      content
        .inlineStyle("max-width", "1280px")
        .inlineStyle("width", "100%")
        .inlineStyle("margin", "0 auto")
    }
    .inlineStyle("width", "100%")
    .inlineStyle("box-sizing", "border-box")
    .inlineStyle("display", "block")
  }
}
