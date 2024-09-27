import Dependencies

public protocol EmailDocument: HTML {
}

extension EmailDocument {
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    @Dependency(\.emailPrinter) var emailPrinter
    var bodyPrinter = emailPrinter
    Content._render(html.body, into: &bodyPrinter)
    Email
      ._render(
        Email(stylesheet: bodyPrinter.stylesheet, bodyBytes: bodyPrinter.bytes),
        into: &printer
      )
  }
}

private struct Email: HTML {
  let stylesheet: String
  let bodyBytes: ContiguousArray<UInt8>

  var body: some HTML {
    html {
      tag("head") {
        BaseStyles()
        style {
          stylesheet
        }
      }
      tag("body") {
        HTMLRaw(bodyBytes)
      }
    }
  }
}
