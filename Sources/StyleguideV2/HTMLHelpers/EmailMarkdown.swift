import Markdown

public struct EmailMarkdown: HTML {
  public let markdown: String
  public let content: AnyHTML

  public init(@StringBuilder _ markdown: () -> String) {
    self.markdown = markdown()
    var visitor = Visitor()
    self.content = visitor.visit(Document(parsing: self.markdown, options: .parseBlockDirectives))
  }

  public var body: some HTML {
    content
  }
}

private struct Visitor: MarkupVisitor {
  typealias Result = AnyHTML
  private var ids: Set<Slug> = []

  @HTMLBuilder
  mutating func defaultVisit(_ markup: any Markup) -> AnyHTML {
    for child in markup.children {
      visit(child)
    }
  }

  @HTMLBuilder
  mutating func visitBlockDirective(_ blockDirective: Markdown.BlockDirective) -> AnyHTML {
    switch blockDirective.name {
    case "Button":
      TableRow {
        TableData {
          Button(color: .purple) {
            for child in blockDirective.children {
              visit(child)
            }
          }
          .href(blockDirective.argumentText.segments.map(\.trimmedText).joined(separator: " "))
          .inlineStyle("margin", "0.5rem 0")
        }
        .attribute("colspan", "99")
      }

    case "Comment":
      HTMLEmpty()

    default:
      for child in blockDirective.children {
        visit(child)
      }
    }
  }

  @HTMLBuilder
  mutating func visitBlockQuote(_ blockQuote: Markdown.BlockQuote) -> AnyHTML {
    let aside = Aside(blockQuote)
    if let level = DiagnosticLevel(aside: aside) {
      Diagnostic(level: level) {
        for child in aside.content {
          visit(child)
        }
      }
      .inlineStyle("padding", "0 1rem")
    } else {
      let style = BlockQuoteStyle(blockName: aside.kind.displayName)
      blockquote {
        Table {
          TableRow {
            TableData {
              strong {
                HTMLText(aside.kind.displayName)
              }
              .color(style.borderColor)
            }
          }

          for child in aside.content {
            TableRow {
              TableData {
                visit(child)
              }
            }
          }
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
    pre {
      code {
        HTMLText(codeBlock.code)
      }
      .attribute("class", language?.class)
      .linkUnderline(true)
    }
    .attribute("data-line", language?.dataLine)
    .backgroundColor(.offWhite.dark(.offBlack))
    .color(.black.dark(.gray900))
    .inlineStyle("margin", "0")
    .inlineStyle("margin-bottom", "0.5rem")
    .inlineStyle("overflow-x", "auto")
    .inlineStyle("padding", "1rem 1.5rem")
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
    let id = ids.slug(for: heading.plainText)

    a {}
      .attribute("id", id)
      .inlineStyle("display", "block")
      .inlineStyle("position", "relative")
      .inlineStyle("top", "-5em")
      .inlineStyle("top", "-0.5em", media: .desktop)
      .inlineStyle("visibility", "hidden")

    div {
      Header(heading.level + 2) {
        for child in heading.children {
          visit(child)
        }

        Link(href: "#\(id)") {
          SVG("Link") {
            """
            <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M432-288H288q-79.68 0-135.84-56.23Q96-400.45 96-480.23 96-560 152.16-616q56.16-56 135.84-56h144v72H288q-50 0-85 35t-35 85q0 50 35 85t85 35h144v72Zm-96-156v-72h288v72H336Zm192 156v-72h144q50 0 85-35t35-85q0-50-35-85t-85-35H528v-72h144q79.68 0 135.84 56.23 56.16 56.22 56.16 136Q864-400 807.84-344 751.68-288 672-288H528Z"/></svg>
            """
          }
        }
        .linkColor(.gray800.dark(.gray300))
        .inlineStyle("display", "none")
        .inlineStyle("display", "initial", pre: "article div:hover > * >")
        .inlineStyle("left", "0")
        .inlineStyle("position", "absolute")
        .inlineStyle("text-align", "center")
        .inlineStyle("top", "2px", media: .mobile)
        .inlineStyle("width", "2.5rem")
      }
      .color(.offBlack.dark(.offWhite))
    }
//    .inlineStyle("margin-left", "-2.25rem")
//    .inlineStyle("margin-left", "-2.5rem", media: .desktop)
//    .inlineStyle("padding-left", "2.25rem")
//    .inlineStyle("padding-left", "2.5rem", media: .desktop)
    .inlineStyle("padding", "1rem 0 0.5rem 0")
    .inlineStyle("position", "relative")
  }

  @HTMLBuilder
  mutating func visitHTMLBlock(_ html: Markdown.HTMLBlock) -> AnyHTML {
    HTMLRaw(html.rawHTML)
  }

  @HTMLBuilder
  mutating func visitImage(_ image: Markdown.Image) -> AnyHTML {
    if let source = image.source {
      Link(href: source) {
        Image(source: source, description: image.title ?? "")
          .inlineStyle("margin", "0 1rem")
          .inlineStyle("border-radius", "6px")
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
  }

  @HTMLBuilder
  mutating func visitOrderedList(_ orderedList: Markdown.OrderedList) -> AnyHTML {
    ol {
      for child in orderedList.children {
        visit(child)
      }
    }
    .inlineStyle("margin-bottom", "0")
    .inlineStyle("margin-top", "0")
    .inlineStyle("padding", "0 0 1rem 1rem")
  }

  @HTMLBuilder
  mutating func visitUnorderedList(_ unorderedList: Markdown.UnorderedList) -> AnyHTML {
    ul {
      for child in unorderedList.children {
        visit(child)
      }
    }
    .inlineStyle("margin-bottom", "0")
    .inlineStyle("margin-top", "0")
    .inlineStyle("padding", "0.5rem 0 0.5rem 1rem")
  }

  @HTMLBuilder
  mutating func visitParagraph(_ paragraph: Markdown.Paragraph) -> AnyHTML {
    p {
      for child in paragraph.children {
        visit(child)
      }
    }
    .color(.black)
    .fontStyle(.body(.regular))
    .inlineStyle("line-height", "1.5")
    .inlineStyle("padding", "0 0 0.5rem 0")
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
    columnAlignments: [Markdown.Table.ColumnAlignment?]
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
}

extension Markdown.Table.ColumnAlignment {
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

private func value(forArgument argument: String, block: BlockDirective) -> String? {
  block.argumentText.segments
    .compactMap {
      let text = $0.trimmedText.drop(while: { $0 == " " })
      return text.hasPrefix("\(argument): \"")
        ? text.dropFirst("\(argument): \"".count).prefix(while: { $0 != "\"" })
        : nil
    }
    .first
    .map(String.init)
}

extension DiagnosticLevel {
  fileprivate init?(aside: Aside) {
    switch aside.kind.rawValue {
    case "Error": self = .error
    case "Expected Failure": self = .knownIssue
    case "Failed": self = .issue
    case "Runtime Warning": self = .runtimeWarning
    case "Warning": self = .warning
    default: return nil
    }
  }
}

private struct Slug: Hashable {
  var name: String
  var generation: Int
}

extension Set<Slug> {
  fileprivate func slug(for string: String) -> String {
    var slug = Slug(name: string.slug(), generation: 0)
    while contains(slug) {
      slug.generation += 1
    }
    return "\(slug.name)\(slug.generation > 0 ? "-\(slug.generation)" : "")"
  }
}

extension String {
  fileprivate func slug() -> String {
    split(whereSeparator: { !$0.isLetter && !$0.isNumber }).joined(separator: "-").lowercased()
  }
}
