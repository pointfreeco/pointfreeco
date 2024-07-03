import Css
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Markdown
import PointFreePrelude
import Prelude
import Styleguide

extension Node {
  public static func markdownBlock(
    attributes: [Attribute<Tag.Div>] = [],
    _ markdown: String,
    darkBackground: Bool = false
  ) -> Node {
    return .div(
      attributes: _addClasses(
        [darkBackground ? darkMarkdownContainerClass : markdownContainerClass],
        to: attributes
      ),
      .raw(unsafeMark(from: markdown))
    )
  }
}

private struct UnsafeMark: MarkupWalker {
  var html = ""
  func quoteAttribute(_ string: String) -> String {
    var quoted = "\""
    quoted.unicodeScalars.reserveCapacity(string.unicodeScalars.count)
    for scalar in string.unicodeScalars {
      switch scalar {
      case "\"":
        quoted.append("&quot;")
      case "'":
        quoted.append("&#39;")
      default:
        quoted.unicodeScalars.append(scalar)
      }
    }
    quoted.append("\"")
    return quoted
  }
  func escape(_ string: String) -> String {
    var escaped = ""
    escaped.unicodeScalars.reserveCapacity(string.unicodeScalars.count)
    for scalar in string.unicodeScalars {
      switch scalar {
      case "&":
        escaped.append("&amp;")
      case "<":
        escaped.append("&lt;")
      case ">":
        escaped.append("&gt;")
      default:
        escaped.unicodeScalars.append(scalar)
      }
    }
    return escaped
  }
  mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
    html.append("<blockquote>\n")
    defer { html.append("</blockquote>\n") }
    for child in blockQuote.children { visit(child) }
  }
  mutating func visitCodeBlock(_ codeBlock: Markdown.CodeBlock) {
    html.append("<pre><code")
    if let language = codeBlock.language {
      html.append(" class=")
      html.append(quoteAttribute("language-\(language)"))
    }
    html.append(">\(escape(codeBlock.code))</code></pre>\n")
  }
  mutating func visitEmphasis(_ emphasis: Markdown.Emphasis) {
    html.append("<em>")
    defer { html.append("</em>") }
    for child in emphasis.children { visit(child) }
  }
  mutating func visitHeading(_ heading: Markdown.Heading) {
    html.append("<h\(heading.level)>")
    defer { html.append("</h\(heading.level)>") }
    for child in heading.children { visit(child) }
  }
  mutating func visitHTMLBlock(_ html: Markdown.HTMLBlock) {
    self.html.append(html.rawHTML)
  }
  mutating func visitImage(_ image: Markdown.Image) {
    if let source = image.source {
      html.append("<img src=")
      html.append(quoteAttribute(source))
      if let title = image.title {
        html.append(" title=")
        html.append(quoteAttribute(title))
      }
      html.append(">")
    }
  }
  mutating func visitInlineCode(_ inlineCode: Markdown.InlineCode) {
    html.append("<code>")
    defer { html.append("</code>") }
    html.append(escape(inlineCode.code))
  }
  mutating func visitInlineHTML(_ inlineHTML: Markdown.InlineHTML) {
    html.append(inlineHTML.rawHTML)
  }
  mutating func visitLineBreak(_ lineBreak: Markdown.LineBreak) {
    html.append("<br>")
  }
  mutating func visitLink(_ link: Markdown.Link) {
    html.append("<a href=")
    html.append(quoteAttribute(link.destination ?? "#"))
    if let title = link.title {
      html.append(" title=")
      html.append(quoteAttribute(title))
    }
    html.append(">")
    defer { html.append("</a>") }
    for child in link.children { visit(child) }
  }
  mutating func visitListItem(_ listItem: Markdown.ListItem) {
    html.append("<li>\n")
    defer { html.append("</li>\n") }
    for child in listItem.children { visit(child) }
  }
  mutating func visitOrderedList(_ orderedList: Markdown.OrderedList) {
    html.append("<ol>\n")
    defer { html.append("</ol>\n") }
    for child in orderedList.children { visit(child) }
  }
  mutating func visitParagraph(_ paragraph: Markdown.Paragraph) {
    html.append("<p>")
    defer { html.append("</p>\n") }
    for child in paragraph.children { visit(child) }
  }
  mutating func visitSoftBreak(_ softBreak: Markdown.SoftBreak) {
    html.append("\n")
  }
  mutating func visitStrikethrough(_ strikethrough: Markdown.Strikethrough) {
    html.append("<s>")
    defer { html.append("</s>") }
    for child in strikethrough.children { visit(child) }
  }
  mutating func visitStrong(_ strong: Markdown.Strong) {
    html.append("<strong>")
    defer { html.append("</strong>") }
    for child in strong.children { visit(child) }
  }
  mutating func visitTable(_ table: Markdown.Table) {
    assertionFailure()
  }
  mutating func visitText(_ text: Markdown.Text) {
    html.append(escape(text.string))
  }
  mutating func visitThematicBreak(_ thematicBreak: Markdown.ThematicBreak) {
    html.append("<hr>")
  }
  mutating func visitUnorderedList(_ unorderedList: Markdown.UnorderedList) {
    html.append("<ul>\n")
    defer { html.append("</ul>\n") }
    for child in unorderedList.children { visit(child) }
  }
}

public func unsafeMark(from markdown: String) -> String {
  var walker = UnsafeMark()
  walker.visit(Document(parsing: markdown))
  return walker.html
}

private let markdownContainerClass = CssSelector.class("md-ctn")
private let darkMarkdownContainerClass = CssSelector.class("md-ctn-dark")
private let baseMarkdownBlockStyles: Stylesheet =
  markdownContainerClass
  % (hrMarkdownStyles
    <> ulMarkdownStyles
    <> blockquoteMarkdownStyles
    <> pMarkdownStyles
    <> codeMarkdownStyles)

public let markdownBlockStyles: Stylesheet = .concat(
  baseMarkdownBlockStyles,
  markdownContainerClass % aMarkdownStyles,
  darkMarkdownContainerClass % darkAnchorMarkdownStyles,
  (Class.pf.colors.bg.black ** markdownContainerClass ** a) % color(Colors.white),
  (Class.pf.colors.bg.black ** markdownContainerClass ** (a & .pseudo(.link)))
    % color(Colors.white),
  (Class.pf.colors.bg.black ** markdownContainerClass ** (a & .pseudo(.visited)))
    % color(Colors.white),
  (Class.pf.colors.bg.black ** markdownContainerClass ** (a & .pseudo(.hover)))
    % color(Colors.white)
)

private let ulMarkdownStyles: Stylesheet =
  ul % margin(bottom: .rem(1.5))

private let pMarkdownStyles: Stylesheet =
  p % key("word-wrap", "break-word")
  <> (p & .pseudo(.not(.pseudo(.lastChild)))) % margin(bottom: .rem(1.5))

private let codeMarkdownStyles: Stylesheet =
  pre
  % (code
    % (padding(topBottom: .rem(0.5), leftRight: .rem(2))
      <> backgroundColor(.white(0, 0.02))
      <> borderColor(all: .white(0, 0.15))
      <> borderRadius(all: .px(6))
      <> display(.block)
      <> margin(bottom: .rem(1.5))))
  <> pre % overflow(x: .auto)
  <> code
  % (fontFamily(["ui-monospace", "monospace"]))

private let blockquoteMarkdownStyles: Stylesheet =
  blockquote
  % (color(Colors.gray300)
    <> borderColor(left: Colors.gray850)
    <> borderRadius(all: .px(2))
    <> borderStyle(left: .solid)
    <> borderWidth(left: .px(3))
    <> margin(right: .rem(0), bottom: .rem(2), left: .rem(0))
    <> padding(leftRight: .rem(2)))

private let aMarkdownStyles = Stylesheet.concat(
  a % key("text-decoration", "underline"),
  (a & CssSelector.pseudo(.link)) % color(Colors.purple150),
  (a & CssSelector.pseudo(.visited)) % color(Colors.purple150),
  (a & CssSelector.pseudo(.hover)) % color(Colors.black)
)
private let darkAnchorMarkdownStyles = Stylesheet.concat(
  a % key("text-decoration", "underline"),
  (a & CssSelector.pseudo(.link)) % color(Colors.white),
  (a & CssSelector.pseudo(.visited)) % color(Colors.white),
  (a & CssSelector.pseudo(.hover)) % color(Colors.white)
)

private let hrMarkdownStyles: Stylesheet =
  hr
  % (margin(top: .rem(2), right: .pct(30), bottom: .rem(2), left: .pct(30))
    <> borderStyle(top: .solid)
    <> borderWidth(top: .px(1))
    <> backgroundColor(.white)
    <> borderColor(top: Color.other("#ddd"))
    <> height(.px(0)))
