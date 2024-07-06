import Markdown

extension String {
  public init(stripping markup: any Markup) {
    var walker = PlainTextWalker()
    walker.visit(markup)
    self = walker.text
  }

  public init(stripping markdown: String) {
    self.init(stripping: Document(parsing: markdown))
  }
}

private struct PlainTextWalker: MarkupWalker {
  var text = ""
  mutating func visitEmphasis(_ emphasis: Markdown.Emphasis) {
    text.append(emphasis.plainText)
  }
  mutating func visitHeading(_ heading: Markdown.Heading) {
    text.append(heading.plainText)
  }
  mutating func visitInlineCode(_ inlineCode: Markdown.InlineCode) {
    text.append(inlineCode.code)
  }
  mutating func visitLineBreak(_ lineBreak: Markdown.LineBreak) {
    text.append(" ")
  }
  mutating func visitLink(_ link: Markdown.Link) {
    text.append(link.plainText)
  }
  mutating func visitListItem(_ listItem: ListItem) {
    for child in listItem.children { visit(child) }
  }
  mutating func visitSoftBreak(_ softBreak: Markdown.SoftBreak) {
    text.append(" ")
  }
  mutating func visitStrong(_ strong: Markdown.Strong) {
    text.append(strong.plainText)
  }
  mutating func visitText(_ text: Markdown.Text) {
    self.text.append(text.plainText)
  }
  mutating func visitUnorderedList(_ unorderedList: UnorderedList) {
    for child in unorderedList.children { visit(child) }
  }
}
