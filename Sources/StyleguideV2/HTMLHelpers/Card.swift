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
    GridColumn {
      div {
        header
          .inlineStyle("border-bottom", "1px solid #e8e8e8")
          .inlineStyle("border-bottom", "1px solid #3d3d3d", media: .dark)
        div {
          content

          Grid {
            footer
          }
          .color(.gray650.dark(.gray400))
          .grid(alignment: .center)
        }
        .inlineStyle("padding", "0.5rem 1.5rem 1.5rem 1.5rem")
      }
      .backgroundColor(.white.dark(.gray150))
      .inlineStyle("border", "1px #353535 solid", media: .dark)
      .inlineStyle("box-shadow", "0 2px 10px -2px rgba(0,0,0,0.3)")
      .inlineStyle("border-radius", "5px")
      .inlineStyle("margin", "1rem 0 2rem 0")
      .inlineStyle("overflow", "hidden")
    }
    .column(count: 12)
    .column(count: 4, media: .desktop)
    .inlineStyle("padding-left", "0.75rem")
    .inlineStyle("padding-right", "0.75rem")
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
    Grid {
      icon

      span {
        HTMLText(title)
      }
      .inlineStyle("padding", "0 0.5rem 0 0.25rem")
    }
    .fontStyle(.body(.small))
    .grid(alignment: .center)
  }
}
