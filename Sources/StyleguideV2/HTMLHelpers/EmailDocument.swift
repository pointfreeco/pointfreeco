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
        Email(
          bodyBytes: bodyPrinter.bytes,
          stylesheet: bodyPrinter.stylesheet
        ),
        into: &printer
      )
  }
}

private struct Email: HTML {
  let bodyBytes: ContiguousArray<UInt8>
  let stylesheet: String

  var body: some HTML {
    html {
      tag("head") {
        BaseStyles()
        style {
          stylesheet
        }
        meta()
          .attribute("charset", "UTF-8")
        meta()
          .attribute("name", "viewport")
          .attribute("content", "width=device-width, initial-scale=1.0, viewport-fit=cover")
      }
      tag("body") {
        HTMLRaw(bodyBytes)
      }
      .attribute("bgcolor", "#ffffff")
    }
    .attribute("xmlns", "http://www.w3.org/1999/xhtml")
  }
}
