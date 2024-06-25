struct HTMLInlineStyle<Content: HTML>: HTML {
  let content: Content
  let property: String  // margin-top
  let value: String     // 8px          ~~~~> mt-8px
  let mediaQuery: String?

  var body: Never {
    fatalError()
  }
  static func _render(_ html: consuming HTMLInlineStyle<Content>, into printer: inout HTMLPrinter) {
    let previousClass = printer.attributes["class"]  // TODO: should we optimize this?
    defer {
      printer.attributes["class"] = previousClass
    }

    // TODO: better hashing/compression (lossless)
    let className = "\(html.property)-\(html.value.hashValue)-\(html.mediaQuery?.hashValue ?? 0)"

    if printer.styles[html.mediaQuery, default: [:]][className] == nil {
      printer.styles[html.mediaQuery, default: [:]][className] = "\(html.property):\(html.value)"
    }
    printer.attributes["class", default: ""]!.append("\(className) ")

    Content._render(html.content, into: &printer)
  }
}

extension HTML {
  public func inlineStyle(_ property: String, _ value: String, media mediaQuery: String? = nil) -> some HTML {
    HTMLInlineStyle(content: self, property: property, value: value, mediaQuery: mediaQuery)
  }
}
