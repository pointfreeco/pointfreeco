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
    _ markdown: String
    ) -> Node {
    return .div(
      attributes: _addClasses([markdownContainerClass], to: attributes),
      .raw(unsafeMark(from: markdown))
    )
  }
}

public func unsafeMark(from markdown: String) -> String {
  guard let cString = cmark_markdown_to_html(markdown, markdown.utf8.count, CMARK_OPT_SMART)
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
      padding(top: .rem(2), right: .rem(2), bottom: .rem(2), left: .rem(2))
        <> display(.block)
        <> overflow(x: .auto)
    )
    )
    <> code % (
      fontFamily(["monospace"])
        <> padding(topBottom: .px(1), leftRight: .px(5))
        <> borderWidth(all: .px(1))
        <> borderRadius(all: .px(3))
        <> backgroundColor(Color.other("#f7f7f7"))
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
