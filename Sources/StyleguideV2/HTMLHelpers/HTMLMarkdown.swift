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
    HTMLRaw(unsafeCmark(markdown))
  }
}

private func unsafeCmark(_ markdown: String, options: Int32 = 0) -> ContiguousArray<UInt8> {
  guard
    let cString = cmark_markdown_to_html(
      markdown, markdown.utf8.count, CMARK_OPT_SMART | options
    )
  else { return ContiguousArray(markdown.utf8) }
  defer { free(cString) }

  return ContiguousArray(String(cString: cString).utf8)
}
