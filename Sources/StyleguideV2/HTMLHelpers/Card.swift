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
          div {
            content
          }
          .inlineStyle("flex-grow", "1")

          Grid {
            footer
          }
          .color(.gray650.dark(.gray400))
          .grid(alignment: .center)
        }
        .inlineStyle("display", "flex")
        .inlineStyle("flex-direction", "column")
        .inlineStyle("flex-grow", "1")
        .inlineStyle("padding", "0.5rem 1.5rem 1.5rem 1.5rem")
      }
      .backgroundColor(.white.dark(.gray150))
      .inlineStyle("border", "1px #353535 solid", media: .dark)
      .inlineStyle("box-shadow", "0 2px 10px -2px rgba(0,0,0,0.3)")
      .inlineStyle("border-radius", "5px")
      .inlineStyle("display", "flex")
      .inlineStyle("flex-direction", "column")
      .inlineStyle("margin", "1rem 0 2rem 0")
      .inlineStyle("overflow", "hidden")
    }
    .column(count: 12)
    .column(count: 4, media: .desktop)
    .inlineStyle("display", "flex")
    .inlineStyle("padding-left", "0.75rem")
    .inlineStyle("padding-right", "0.75rem")
  }
}

public struct Label: HTML {
  let icon: SVG
  let title: String
  let fontStyle: FontStyle

  public init(_ title: String, icon: SVG, fontStyle: FontStyle = .body(.small)) {
    self.icon = icon
    self.title = title
    self.fontStyle = fontStyle
  }

  public var body: some HTML {
    div {
      icon
        .inflexible()
      span {
        HTMLText(title)
      }
      .inflexible()
    }
    .flexContainer(
      direction: "row",
      wrap: "nowrap",
      justification: "center",
      itemAlignment: "center",
      columnGap: columnGap
    )
    .fontStyle(fontStyle)
  }

  var columnGap: String {
    switch fontStyle {
    case .body(.small):   "0.25rem"
    case .body(.regular): "0.25rem"
    }
  }
}
