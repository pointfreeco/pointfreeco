public protocol HTMLDocument: HTML {
  associatedtype Head: HTML
  @HTMLBuilder
  var head: Head { get }
  static func _render(_ html: consuming Self, into printer: inout HTMLPrinter)
}

extension HTMLDocument {
  public static func _render(_ html: consuming Self, into printer: inout HTMLPrinter) {
    var bodyPrinter = HTMLPrinter()
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
    html {
      tag("head") {
        head
        style {
          stylesheet
        }
      }
      tag("body") {
        HTMLBytes(bodyBytes)
      }
    }
  }
}

struct HTMLBytes: HTML {
  let bytes: ContiguousArray<UInt8>
  init(_ bytes: ContiguousArray<UInt8>) {
    self.bytes = bytes
  }
  static func _render(_ html: consuming HTMLBytes, into printer: inout HTMLPrinter) {
    printer.bytes.append(contentsOf: html.bytes)
  }
  var body: Never { fatalError() }
}
