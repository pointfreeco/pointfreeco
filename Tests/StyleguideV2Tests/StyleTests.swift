#if canImport(Testing)
  import Testing
  @testable import StyleguideV2

  @Suite
  struct StyleTests {
    @Test
    func orderOfStyles() {
      struct CustomComponent: HTML {
        var body: some HTML {
          div()
            .inlineStyle("margin", "1rem")
        }
      }

      let response = CustomComponent()
        .inlineStyle("margin", "2rem")
        .render()

      print(response.styles)
      print(response.body)
    }
  }

  extension HTML {
    func render() -> Response {
      var printer = HTMLPrinter()
      Self._render(self, into: &printer)
      return Response(
        body: String(decoding: printer.bytes, as: UTF8.self),
        styles: printer.stylesheet
      )
    }
  }

  struct Response {
    var body: String
    var styles: String
  }
#endif
