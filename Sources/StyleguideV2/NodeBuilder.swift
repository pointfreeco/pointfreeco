import Dependencies
import Html

extension Node {
  public init<T: HTML>(@HTMLBuilder content: () -> T) {
    @Dependency(\.htmlPrinter) var htmlPrinter
    var printer = htmlPrinter
    T._render(content(), into: &printer)
    self = .fragment([
      .element("style", [], .raw(printer.stylesheet)),
      .raw(String(decoding: printer.bytes, as: UTF8.self)),
    ])
  }
}
