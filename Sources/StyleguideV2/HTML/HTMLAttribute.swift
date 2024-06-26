extension HTML {
  public func attribute(_ name: String, _ value: String) -> some HTML {
    HTMLAttribute(content: self, name: name, value: value)
  }
}

private struct HTMLAttribute<Content: HTML>: HTML {
  let content: Content
  let name: String
  let value: String

  static func _render(_ html: HTMLAttribute, into printer: inout HTMLPrinter) {
    let previousValue = printer.attributes[html.name]  // TODO: should we optimize this?
    defer {
      printer.attributes[html.name] = previousValue
    }
    printer.attributes[html.name] = html.value  // TODO: append, replace, etc...
    Content._render(html.content, into: &printer)
  }
  var body: Never { fatalError() }
}
