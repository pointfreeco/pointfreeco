public struct HTMLInlineStyle<Content: HTML>: HTML {
  let content: Content
  var styles: [(String, String?, String?, String?)]

  init(
    content: Content,
    property: String,
    value: String?,
    mediaQuery: String?,
    pseudo: String?
  ) {
    self.content = content
    self.styles = [(property, value, mediaQuery, pseudo)]
  }

  public var body: Never {
    fatalError()
  }

  public static func _render(_ html: HTMLInlineStyle<Content>, into printer: inout HTMLPrinter) {
//    let previousClass = printer.attributes["class"]  // TODO: should we optimize this?
//    defer {
//      printer.attributes["class"] = previousClass
//    }
    defer {
      Content._render(html.content, into: &printer)
    }

    for (property, value, mediaQuery, pseudo) in html.styles {
      guard let value = value
      else {
        continue
      }

      // TODO: better hashing/compression (lossless)
      let className = "\(property)-\(value.hashValue)-\(mediaQuery?.hashValue ?? 0)"
      let pseudo = "\(className)\(pseudo.map { ":\($0)" } ?? "")"

      if printer.styles[mediaQuery, default: [:]][pseudo] == nil {
        printer.styles[mediaQuery, default: [:]][pseudo] = "\(property):\(value)"
      }
      printer.attributes["class", default: ""]!.append("\(className) ")
    }
  }
}

extension HTML {
  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: String? = nil,
    pseudo: String? = nil
  ) -> HTMLInlineStyle<Self> {
    HTMLInlineStyle(
      content: self,
      property: property,
      value: value,
      mediaQuery: mediaQuery,
      pseudo: pseudo
    )
  }
}

extension HTMLInlineStyle {
  public func inlineStyle(
    _ property: String,
    _ value: String?,
    media mediaQuery: String? = nil,
    pseudo: String? = nil
  ) -> HTMLInlineStyle {
    var copy = self
    copy.styles.append((property, value, mediaQuery, pseudo))
    return copy
  }
}
