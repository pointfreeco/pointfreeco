public struct Card<Content: HTML, Header: HTML, Footer: HTML>: HTML {
  let content: Content
  let header: Header
  let footer: Footer

  public init(
    @HTMLBuilder content: () -> Content,
    @HTMLBuilder header: () -> Header = { HTMLEmpty() },
    @HTMLBuilder footer: () -> Footer = { HTMLEmpty() }
  ) {
    self.content = content()
    self.header = header()
    self.footer = footer()
  }

  public var body: some HTML {
    VStack(spacing: 0) {
      header
        .inlineStyle("border-bottom", "1px solid #e8e8e8")
        .inlineStyle("border-bottom", "1px solid #3d3d3d", media: .dark)

      VStack(spacing: 0) {
        div { content }
          .grow()

        HStack(alignment: .center) {
          footer
        }
        .color(.gray650.dark(.gray400))
        .linkColor(.gray650.dark(.gray400))
      }
      .grow()
      .inlineStyle("padding", "1.5rem")
    }
    .backgroundColor(.white.dark(.gray150))
    .inlineStyle("border", "1px #353535 solid", media: .dark)
    .inlineStyle("box-shadow", "0 2px 10px -2px rgba(0,0,0,0.3)")
    .inlineStyle("border-radius", "5px")
    .inlineStyle("margin", "1rem 0 2rem 0")
    .inlineStyle("overflow", "hidden")
  }
}

public struct Label: HTML {
  let icon: SVG
  let title: String

  public init(_ title: String, icon: SVG) {
    self.icon = icon
    self.title = title
  }

  public var body: some HTML {
    HStack(alignment: .center, spacing: 0.25) {
      icon
      HTMLText(title)
    }
    .fontStyle(.body(.small))
  }
}
