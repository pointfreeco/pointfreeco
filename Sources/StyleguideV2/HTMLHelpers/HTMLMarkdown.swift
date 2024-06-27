import Ccmark

public struct HTMLMarkdown: HTML {
  let markdown: String

  public init(_ markdown: String) {
    self.markdown = markdown
  }

  public init(_ markdown: () -> String) {
    self.markdown = markdown()
  }

  public var body: some HTML {
    div {
      HTMLText(unsafeCmark(markdown), raw: true)
    }
    .attribute("class", "md-ctn")
  }
}

private func unsafeCmark(_ markdown: String, options: Int32 = 0) -> String {
  guard
    let cString = cmark_markdown_to_html(
      markdown, markdown.utf8.count, CMARK_OPT_SMART | options
    )
  else { return markdown }
  defer { free(cString) }
  return String(cString: cString)
}
