import Ccmark
import Css
import FunctionalCss
import Html
import HtmlCssSupport
import PointFreePrelude
import Prelude
import Styleguide

extension Node {
  public static func markdownBlock(
    attributes: [Attribute<Tag.Div>] = [],
    _ markdown: String,
    options: Int32 = 0
    ) -> Node {
    return .div(
      attributes: _addClasses([markdownContainerClass], to: attributes),
      .raw(unsafeMark(from: markdown, options: options))
    )
  }
}

public func unsafeMark(from markdown: String, options: Int32 = 0) -> String {
  guard let cString = cmark_markdown_to_html(markdown, markdown.utf8.count, CMARK_OPT_SMART | options)
    else { return markdown }
  defer { free(cString) }
  return String(cString: cString)
}

private let markdownContainerClass = CssSelector.class("md-ctn")
public let markdownBlockStyles: Stylesheet =
  markdownContainerClass % (
    hrMarkdownStyles
      <> aMarkdownStyles
      <> ulMarkdownStyles
      <> blockquoteMarkdownStyles
      <> pMarkdownStyles
      <> codeMarkdownStyles
)

private let ulMarkdownStyles: Stylesheet =
  ul % margin(bottom: .rem(1.5))

private let pMarkdownStyles: Stylesheet =
  p % key("word-wrap", "break-word")
    <> (p & .pseudo(.not(.pseudo(.lastChild)))) % margin(bottom: .rem(1.5))

private let codeMarkdownStyles: Stylesheet =
  pre % (
    code % (
      padding(topBottom: .rem(0.5), leftRight: .rem(1))
        <> borderRadius(all: .px(6))
        <> display(.block)
        <> overflow(x: .auto)
        <> margin(bottom: .rem(1.5))
    )
    )
    <> code % (
      fontFamily(["monospace"])
        <> backgroundColor(.white(0, 0.02))
        <> borderColor(all: .white(0, 0.15))
        <> borderRadius(all: .px(3))
        <> borderStyle(all: .solid)
        <> borderWidth(all: .px(1))
        <> padding(topBottom: .px(1), leftRight: .px(5))
)

private let blockquoteMarkdownStyles: Stylesheet =
  blockquote % fontStyle(.italic)

private let aMarkdownStyles = Stylesheet.concat(
  a % key("text-decoration", "underline"),
  (a & CssSelector.pseudo(.link)) % color(Colors.purple150),
  (a & CssSelector.pseudo(.visited)) % color(Colors.purple150),
  (a & CssSelector.pseudo(.hover)) % color(Colors.black)
)

private let hrMarkdownStyles: Stylesheet =
  hr % (
    margin(top: .rem(2), right: .pct(30), bottom: .rem(2), left: .pct(30))
      <> borderStyle(top: .solid)
      <> borderWidth(top: .px(1))
      <> backgroundColor(.white)
      <> borderColor(top: Color.other("#ddd"))
      <> height(.px(0))
)
