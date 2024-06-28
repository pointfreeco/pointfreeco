public struct HTMLInlineStyle<Content: HTML>: HTML {
  let content: Content
  var styles: [(String, String, String?, String?)]

  init(
    content: Content,
    property: String,
    value: String?,
    mediaQuery: String?,
    pseudo: String?
  ) {
    self.content = content
    self.styles = value.map { [(property, $0, mediaQuery, pseudo)] } ?? []
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
      let uniqueID = "\(property)\(value)\(mediaQuery ?? "")\(pseudo ?? "")"
      let id = classes.withValue { classes in
        guard let index = classes.firstIndex(of: uniqueID)
        else {
          classes.append(uniqueID)
          return classes.count - 1
        }
        return index
      }

      #if DEBUG
        let className = "\(property)-\(id)"
      #else
        let className = "c\(id)"
      #endif
      let pseudo = "\(className)\(pseudo.map { ":\($0)" } ?? "")"

      if printer.styles[mediaQuery, default: [:]][pseudo] == nil {
        printer.styles[mediaQuery, default: [:]][pseudo] = "\(property):\(value)"
      }
      printer.attributes["class", default: ""]!.append("\(className) ")
    }
  }
}

import ConcurrencyExtras
import OrderedCollections
let classes = LockIsolated<OrderedSet<String>>([])

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
    if let value {
      copy.styles.append((property, value, mediaQuery, pseudo))
    }
    return copy
  }
}
