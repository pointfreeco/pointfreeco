import Dependencies

public protocol HTMLDocument: HTML {
  associatedtype Head: HTML
  @HTMLBuilder
  var head: Head { get }
  static func _render(_ html: Self, into printer: inout HTMLPrinter)
}

extension HTMLDocument {
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    @Dependency(\.htmlPrinter) var htmlPrinter
    var bodyPrinter = htmlPrinter
    Content._render(html.body, into: &bodyPrinter)
    Document
      ._render(
        Document(head: html.head, stylesheet: bodyPrinter.stylesheet, bodyBytes: bodyPrinter.bytes),
        into: &printer
      )
  }
}

private struct Document<Head: HTML>: HTML {
  let head: Head
  let stylesheet: String
  let bodyBytes: ContiguousArray<UInt8>

  var body: some HTML {
    Doctype()
    html {
      tag("head") {
        head
        style {
          stylesheet
        }
      }
      tag("body") {
        HTMLRaw(bodyBytes)
      }
    }
    .attribute("lang", "en")
  }
}
