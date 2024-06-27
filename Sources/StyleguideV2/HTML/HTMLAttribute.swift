import OrderedCollections

extension HTML {
  public func attribute(_ name: String, _ value: String? = nil) -> _HTMLAttributes<Self> {
    _HTMLAttributes(content: self, attributes: [name: value])
  }
}

public struct _HTMLAttributes<Content: HTML>: HTML {
  let content: Content
  var attributes: OrderedDictionary<String, String?>

  public func attribute(_ name: String, _ value: String? = nil) -> _HTMLAttributes<Content> {
    var copy = self
    copy.attributes[name] = value
    return copy
  }

  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    let previousValue = printer.attributes  // TODO: should we optimize this?
    defer { printer.attributes = previousValue }
    printer.attributes.merge(html.attributes, uniquingKeysWith: { $1 })
    // TODO: append, replace, etc...
    Content._render(html.content, into: &printer)
  }
  public var body: Never { fatalError() }
}
