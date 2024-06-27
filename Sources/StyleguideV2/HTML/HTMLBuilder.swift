@resultBuilder
public enum HTMLBuilder {
  public static func buildArray<Element: HTML>(_ components: [Element]) -> _HTMLArray<Element> {
    _HTMLArray(elements: components)
  }

  public static func buildBlock<Content: HTML>(_ content: Content) -> Content {
    content
  }

  public static func buildBlock<each Content: HTML>(
    _ content: repeat each Content
  ) -> _HTMLTuple<repeat each Content> {
    _HTMLTuple(content: repeat each content)
  }

  public static func buildEither<First: HTML, Second: HTML>(
    first component: First
  ) -> _HTMLConditional<First, Second> {
    .first(component)
  }

  public static func buildEither<First: HTML, Second: HTML>(
    second component: Second
  ) -> _HTMLConditional<First, Second> {
    .second(component)
  }

  public static func buildExpression<T: HTML>(_ expression: T) -> T {
    expression
  }

  public static func buildExpression(_ expression: HTMLText) -> HTMLText {
    expression
  }

  public static func buildOptional<T: HTML>(_ component: T?) -> T? {
    component
  }
}

public struct _HTMLArray<Element: HTML>: HTML {
  let elements: [Element]
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    for element in html.elements {
      Element._render(element, into: &printer)
    }
  }
  public var body: Never { fatalError() }
}

public enum _HTMLConditional<First: HTML, Second: HTML>: HTML {
  case first(First)
  case second(Second)
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    switch html {
    case let .first(first):
      First._render(first, into: &printer)
    case let .second(second):
      Second._render(second, into: &printer)
    }
  }
  public var body: Never { fatalError() }
}

public struct HTMLText: HTML {
  let text: String
  public init(_ text: String) {
    self.text = text
  }
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    printer.bytes.reserveCapacity(printer.bytes.count + html.text.utf8.count)
    for byte in html.text.utf8 {
      switch byte {
      case UInt8(ascii: "&"):
        printer.bytes.append(contentsOf: "&amp;".utf8)
      case UInt8(ascii: "<"):
        printer.bytes.append(contentsOf: "&lt;".utf8)
      default:
        printer.bytes.append(byte)
      }
    }
  }
  public var body: Never { fatalError() }

  public static func + (lhs: Self, rhs: Self) -> Self {
    HTMLText(lhs.text + rhs.text)
  }
}

extension HTMLText: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(value)
  }
}

extension HTMLText: ExpressibleByStringInterpolation {}

public struct _HTMLTuple<each Content: HTML>: HTML {
  let content: (repeat each Content)
  public init(content: repeat each Content) {
    self.content = (repeat each content)
  }
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    func render<T: HTML>(_ html: T) {
      let oldAttributes = printer.attributes
      defer { printer.attributes = oldAttributes }
      T._render(html, into: &printer)
    }
    repeat render(each html.content)
  }
  public var body: Never { fatalError() }
}

extension Optional: HTML where Wrapped: HTML {
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    guard let html else { return }
    Wrapped._render(html, into: &printer)
  }
  public var body: Never { fatalError() }
}
