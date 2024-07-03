import Markdown

public struct HTMLMarkdown: HTML {
  let markdown: String

  public init(_ markdown: String) {
    self.markdown = markdown
  }

  public init(_ markdown: () -> String) {
    self.markdown = markdown()
  }

  public var body: some HTML {
    tag("pf-markdown") {
      var converter = HTMLConverter()
      converter.visit(Document(parsing: markdown))
    }
    .inlineStyle("display", "block")
  }
}

private struct HTMLConverter: MarkupVisitor {
  typealias Result = AnyHTML

  @HTMLBuilder
  mutating func defaultVisit(_ markup: any Markup) -> AnyHTML {
    for child in markup.children {
      visit(child)
    }
  }

  // https://apple.github.io/swift-markdown/documentation/markdown/blockdirectives/
  // TODO: Support `@Custom { … }` directives (`@Timestamp(00:00:00)`, `@Speaker(Brandon) { … }`)
  // TODO: `Document(parsing: …, options: .parseBlockDirectives)`
  // @HTMLBuilder
  // mutating func visitBlockDirective(_ blockDirective: Markdown.BlockDirective) -> AnyHTML {
  // }

  @HTMLBuilder
  mutating func visitBlockQuote(_ blockQuote: Markdown.BlockQuote) -> AnyHTML {
    // TODO: `let aside = Aside(blockQuote)`
    blockquote {
      for child in blockQuote.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitCodeBlock(_ codeBlock: Markdown.CodeBlock) -> AnyHTML {
    pre {
      code {
        HTMLText(codeBlock.code)
      }
      .attribute("class", codeBlock.language.map { "language-\($0)" })
    }
  }

  @HTMLBuilder
  mutating func visitEmphasis(_ emphasis: Markdown.Emphasis) -> AnyHTML {
    em {
      for child in emphasis.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitHeading(_ heading: Markdown.Heading) -> AnyHTML {
    Header(heading.level) {
      for child in heading.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitHTMLBlock(_ html: Markdown.HTMLBlock) -> AnyHTML {
    HTMLRaw(html.rawHTML)
  }

  @HTMLBuilder
  mutating func visitImage(_ image: Markdown.Image) -> AnyHTML {
    if let source = image.source {
      Image(source: source, description: image.title ?? "")
    }
  }

  @HTMLBuilder
  mutating func visitInlineCode(_ inlineCode: Markdown.InlineCode) -> AnyHTML {
    code {
      HTMLText(inlineCode.code)
    }
  }

  @HTMLBuilder
  mutating func visitInlineHTML(_ inlineHTML: Markdown.InlineHTML) -> AnyHTML {
    HTMLRaw(inlineHTML.rawHTML)
  }

  @HTMLBuilder
  mutating func visitLineBreak(_ lineBreak: Markdown.LineBreak) -> AnyHTML {
    br()
  }

  @HTMLBuilder
  mutating func visitLink(_ link: Markdown.Link) -> AnyHTML {
    Link(href: link.destination ?? "#") {
      for child in link.children {
        visit(child)
      }
    }
    .attribute("title", link.title)
  }

  @HTMLBuilder
  mutating func visitListItem(_ listItem: Markdown.ListItem) -> AnyHTML {
    li {
      for child in listItem.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitOrderedList(_ orderedList: Markdown.OrderedList) -> AnyHTML {
    ol {
      for child in orderedList.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitParagraph(_ paragraph: Markdown.Paragraph) -> AnyHTML {
    Paragraph {
      for child in paragraph.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitSoftBreak(_ softBreak: Markdown.SoftBreak) -> AnyHTML {
    " "
  }

  @HTMLBuilder
  mutating func visitStrikethrough(_ strikethrough: Markdown.Strikethrough) -> AnyHTML {
    s {
      for child in strikethrough.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitStrong(_ strong: Markdown.Strong) -> AnyHTML {
    tag("strong") {
      for child in strong.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitTable(_ table: Markdown.Table) -> AnyHTML {
    tag("table") {
      if !table.head.isEmpty {
        thead {
          tr {
            render(tag: th, cells: table.head.cells, columnAlignments: table.columnAlignments)
          }
        }
      }
      if !table.body.isEmpty {
        tbody {
          for row in table.body.rows {
            tr {
              render(tag: td, cells: row.cells, columnAlignments: table.columnAlignments)
            }
          }
        }
      }
    }
  }

  @HTMLBuilder
  private mutating func render(
    tag: HTMLTag,
    cells: some Sequence<Markdown.Table.Cell>,
    columnAlignments: [Table.ColumnAlignment?]
  ) -> AnyHTML {
    var column = 0
    for cell in cells {
      if cell.colspan > 0 && cell.rowspan > 0 {
        tag {
          for child in cell.children {
            visit(child)
          }
        }
        .attribute("align", columnAlignments[column]?.attributeValue)
        .attribute("colspan", cell.colspan == 1 ? nil : "\(cell.colspan)")
        .attribute("rowspan", cell.rowspan == 1 ? nil : "\(cell.rowspan)")

        let _ = column += Int(cell.colspan)
      }
    }
  }

  @HTMLBuilder
  mutating func visitText(_ text: Markdown.Text) -> AnyHTML {
    HTMLText(text.string)
  }

  @HTMLBuilder
  mutating func visitThematicBreak(_ thematicBreak: Markdown.ThematicBreak) -> AnyHTML {
    Divider()
  }

  @HTMLBuilder
  mutating func visitUnorderedList(_ unorderedList: Markdown.UnorderedList) -> AnyHTML {
    ul {
      for child in unorderedList.children {
        visit(child)
      }
    }
  }
}

extension Table.ColumnAlignment {
  fileprivate var attributeValue: String {
    switch self {
    case .center: "center"
    case .left: "left"
    case .right: "right"
    }
  }
}

extension HTMLBuilder {
  @_disfavoredOverload
  fileprivate static func buildExpression(_ expression: any HTML) -> AnyHTML {
    AnyHTML(expression)
  }

  @_disfavoredOverload
  fileprivate static func buildFinalResult(_ component: some HTML) -> AnyHTML {
    AnyHTML(component)
  }
}

private struct AnyHTML: HTML {
  let base: any HTML
  init(_ base: any HTML) {
    self.base = base
  }
  static func _render(_ html: AnyHTML, into printer: inout HTMLPrinter) {
    func render<T: HTML>(_ html: T) {
      T._render(html, into: &printer)
    }
    render(html.base)
  }
  var body: Never { fatalError() }
}
