import Dependencies

public struct Link<Label: HTML>: HTML {
  @Dependency(\.linkStyle) var linkStyle
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
      .color(linkStyle.color, .visited)
      .color(linkStyle.color, .link)
      .inlineStyle(
        "text-decoration", linkStyle.underline == true ? "underline" : "none", pseudo: "visited"
      )
      .inlineStyle(
        "text-decoration", linkStyle.underline == true ? "underline" : "none", pseudo: "link"
      )
      .inlineStyle(
        "text-decoration", linkStyle.underline == false ? "none" : "underline", pseudo: "hover"
      )
  }
}

extension HTML {
  public func linkColor(_ linkColor: PointFreeColor?) -> some HTML {
    dependency(\.linkStyle.color, linkColor)
  }
  public func linkUnderline(_ linkUnderline: Bool?) -> some HTML {
    dependency(\.linkStyle.underline, linkUnderline)
  }
  public func linkStyle(_ linkStyle: LinkStyle) -> some HTML {
    dependency(\.linkStyle, linkStyle)
  }
}

public struct LinkStyle {
  var color: PointFreeColor?
  var underline: Bool?
  public init(
    color: PointFreeColor? = nil,
    underline: Bool? = nil
  ) {
    self.color = color
    self.underline = underline
  }
}

private enum LinkStyleKey: DependencyKey {
  static let liveValue = LinkStyle()
}

extension DependencyValues {
  public var linkStyle: LinkStyle {
    get { self[LinkStyleKey.self] }
    set { self[LinkStyleKey.self] = newValue }
  }
}
