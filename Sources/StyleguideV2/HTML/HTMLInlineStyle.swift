struct HTMLInlineStyle<Content: HTML>: HTML {
  let content: Content
  let property: String
  let value: String?
  let mediaQuery: String?
  let pseudo: String?

  var body: Never {
    fatalError()
  }
  static func _render(_ html: HTMLInlineStyle<Content>, into printer: inout HTMLPrinter) {
//    let previousClass = printer.attributes["class"]  // TODO: should we optimize this?
//    defer {
//      printer.attributes["class"] = previousClass
//    }
    defer {
      Content._render(html.content, into: &printer)
    }

    guard let value = html.value else {
      return
    }

    // TODO: better hashing/compression (lossless)
    let className = "\(html.property)-\(value.hashValue)-\(html.mediaQuery?.hashValue ?? 0)"
    let pseudo = "\(className)\(html.pseudo.map { ":\($0)" } ?? "")"

    if printer.styles[html.mediaQuery, default: [:]][pseudo] == nil {
      printer.styles[html.mediaQuery, default: [:]][pseudo] = "\(html.property):\(value)"
    }
    printer.attributes["class", default: ""]!.append("\(className) ")
  }
}

extension HTML {
  @HTMLBuilder
  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: String? = nil,
    pseudo: String? = nil
  ) -> some HTML {
    if let value {
      HTMLInlineStyle(
        content: self,
        property: property,
        value: value,
        mediaQuery: mediaQuery,
        pseudo: pseudo
      )
    } else {
      self
    }
  }
}
