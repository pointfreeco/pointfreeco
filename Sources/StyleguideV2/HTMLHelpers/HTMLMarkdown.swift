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
      VStack(spacing: 0.5) {
        var converter = HTMLConverter()
        converter.visit(Document(parsing: markdown, options: .parseBlockDirectives))
      }
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
  @HTMLBuilder
  mutating func visitBlockDirective(_ blockDirective: Markdown.BlockDirective) -> AnyHTML {
    switch blockDirective.name {
    case "Button":
      VStack(alignment: .center) {
        Button(color: .purple) {
          for child in blockDirective.children {
            visit(child)
          }
        }
        .href(blockDirective.argumentText.segments.map { $0.trimmedText }.joined(separator: " "))
        .inlineStyle("margin", "0.5rem 0")
      }

    default:
      for child in blockDirective.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitBlockQuote(_ blockQuote: Markdown.BlockQuote) -> AnyHTML {
    let aside = Aside(blockQuote)
    switch aside.kind.rawValue {
    case "Error":
      Diagnostic(level: .error) {
        for child in aside.content {
          visit(child)
        }
      }
      .inlineStyle("padding", "0 1rem")

    case "Expected Failure":
      Diagnostic(level: .knownIssue) {
        for child in aside.content {
          visit(child)
        }
      }
      .inlineStyle("padding", "0 1rem")

    case "Failed":
      Diagnostic(level: .issue) {
        for child in aside.content {
          visit(child)
        }
      }
      .inlineStyle("padding", "0 1rem")

    case "Runtime Warning":
      Diagnostic(level: .runtimeWarning) {
        for child in aside.content {
          visit(child)
        }
      }
      .inlineStyle("padding", "0 1rem")

    default:
      let style = BlockQuoteStyle(blockName: aside.kind.displayName)
      blockquote {
        strong {
          HTMLText(aside.kind.displayName)
        }
        .color(style.borderColor)
        .inlineStyle("margin-bottom", "0.25rem")
        .inlineStyle("display", "block")

        for child in aside.content {
          visit(child)
        }
      }
      .color(.offBlack.dark(.offWhite))
      .backgroundColor(style.backgroundColor)
      .inlineStyle("border", "2px solid \(style.borderColor.rawValue)")
      .inlineStyle("border", "2px solid \(style.borderColor.darkValue!)", media: .dark)
      .inlineStyle("border-radius", "6px")
      .inlineStyle("margin", "0.5rem 0")
      .inlineStyle("padding", "1rem 1.5rem")
    }
  }

  @HTMLBuilder
  mutating func visitCodeBlock(_ codeBlock: Markdown.CodeBlock) -> AnyHTML {
    let language: (class: String, dataLine: String?)? = codeBlock.language.map {
      let languageInfo = $0.split(separator: ":", maxSplits: 2)
      let language = languageInfo[0]
      let dataLine = languageInfo.dropFirst().first
      let highlightColor = languageInfo.dropFirst(2).first
      return (
        class: "language-\(language)\(highlightColor.map { " highlight-\($0)" } ?? "")",
        dataLine: dataLine.map { String($0) }
      )
    }
    div {
      pre {
        code {
          HTMLText(codeBlock.code)
        }
        .attribute("class", language?.class)
        .color(.black.dark(.offWhite))
        .linkUnderline(true)
      }
      .attribute("data-line", language?.dataLine)
      .inlineStyle("margin", "0")
      .inlineStyle("padding-right", "1rem")
    }
    .backgroundColor(.offWhite.dark(.offBlack))
    .inlineStyle("margin-bottom", "0.5rem")
    .inlineStyle("padding", "1rem 0 1rem 1.5rem")
    .inlineStyle("border-radius", "6px")
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
    Header(heading.level + 2) {
      for child in heading.children {
        visit(child)
      }
    }
    .color(.offBlack.dark(.offWhite))
  }

  @HTMLBuilder
  mutating func visitHTMLBlock(_ html: Markdown.HTMLBlock) -> AnyHTML {
    HTMLRaw(html.rawHTML)
  }

  @HTMLBuilder
  mutating func visitImage(_ image: Markdown.Image) -> AnyHTML {
    if let source = image.source {
      VStack(alignment: .center) {
        Link(href: source) {
          Image(source: source, description: image.title ?? "")
            .inlineStyle("margin", "0 1rem")
            .inlineStyle("border-radius", "6px")
        }
      }
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
    .inlineStyle("margin-top", "0.5rem")
  }

  @HTMLBuilder
  mutating func visitOrderedList(_ orderedList: Markdown.OrderedList) -> AnyHTML {
    ol {
      for child in orderedList.children {
        visit(child)
      }
    }
    .inlineStyle("margin-top", "0.5rem", pseudo: .not(.firstChild))
  }

  @HTMLBuilder
  mutating func visitParagraph(_ paragraph: Markdown.Paragraph) -> AnyHTML {
    p {
      for child in paragraph.children {
        visit(child)
      }
    }
    .inlineStyle("line-height", "1.5")
    .inlineStyle("padding", "0")
    .inlineStyle("margin", "0")
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
    div {
      Divider()
    }
    .inlineStyle("margin", "1rem 0 2rem")
  }

  @HTMLBuilder
  mutating func visitUnorderedList(_ unorderedList: Markdown.UnorderedList) -> AnyHTML {
    ul {
      for child in unorderedList.children {
        visit(child)
      }
    }
    .inlineStyle("margin-top", "0.5rem")
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

private struct BlockQuoteStyle {
  var backgroundColor: PointFreeColor
  var borderColor: PointFreeColor
  init(blockName: String) {
    switch blockName {
    case "Warning", "Correction":
      self.backgroundColor = PointFreeColor(rawValue: "#FDF2F4").dark(.init(rawValue: "#2E0402"))
      self.borderColor = PointFreeColor(rawValue: "#D02C1E").dark(.init(rawValue: "#EB4642"))
    case "Important":
      self.backgroundColor = PointFreeColor(rawValue: "#FEFBF3").dark(.init(rawValue: "#291F04"))
      self.borderColor = PointFreeColor(rawValue: "#966922").dark(.init(rawValue: "#F4B842"))
    case "Announcement", "Tip":
      self.backgroundColor = PointFreeColor(rawValue: "#FBFFFF").dark(.init(rawValue: "#0F2C2B"))
      self.borderColor = PointFreeColor(rawValue: "#4B767C").dark(.init(rawValue: "#9FFCE5"))
    case "Preamble":
      self.backgroundColor = PointFreeColor(rawValue: "#FBF8FF").dark(.init(rawValue: "#1e1925"))
      self.borderColor = PointFreeColor(rawValue: "#8D51F6").dark(.init(rawValue: "#8D51F6"))
    default:
      self.backgroundColor = PointFreeColor(rawValue: "#f5f5f5").dark(.init(rawValue: "#323232"))
      self.borderColor = PointFreeColor(rawValue: "#696969").dark(.init(rawValue: "#9a9a9a"))
    }
  }
}
