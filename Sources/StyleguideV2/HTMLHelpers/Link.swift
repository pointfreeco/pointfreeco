import Dependencies

public struct Link<Label: HTML>: HTML {
  @Dependency(\.linkColor) var linkColor
  let label: Label
  let href: String

  public init(href: String, @HTMLBuilder label: () -> Label) {
    self.href = href
    self.label = label()
  }

  public init(_ title: String, href: String) where Label == HTMLText {
    self.init(href: href) {
      HTMLText(title)
    }
  }

  public var body: some HTML {
    a { label }
      .attribute("href", href)
      .color(linkColor, .link)
      .color(linkColor, .visited)
      .inlineStyle("text-decoration", "underline", pseudo: "hover")
      .inlineStyle("text-decoration", "none", pseudo: "link")
      .inlineStyle("text-decoration", "none", pseudo: "visited")
  }
}

extension HTML {
  public func linkColor(_ linkColor: PointFreeColor?) -> some HTML {
    self.dependency(\.linkColor, linkColor)
  }
}

private enum LinkColorKey: DependencyKey {
  static var liveValue: PointFreeColor?
}

extension DependencyValues {
  public var linkColor: PointFreeColor? {
    get { self[LinkColorKey.self] }
    set { self[LinkColorKey.self] = newValue }
  }
}

extension HTML {
  public func dependency<Value>(
    _ keyPath: WritableKeyPath<DependencyValues, Value>,
    _ value: Value
  ) -> some HTML {
    DependencyWritingHTML(base: self, keyPath: keyPath, value: value)
  }
}

public struct DependencyWritingHTML<Base: HTML, Value>: HTML {
  let base: Base
  let keyPath: WritableKeyPath<DependencyValues, Value>
  let value: Value

  public static func _render(
    _ html: DependencyWritingHTML<Base, Value>,
    into printer: inout HTMLPrinter
  ) {
    withDependencies {
      $0[keyPath: html.keyPath] = html.value
    } operation: {
      Base._render(html.base, into: &printer)
    }
  }
  public var body: Never { fatalError() }
}
