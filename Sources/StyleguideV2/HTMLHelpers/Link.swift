public struct Link<Label: HTML>: HTML {
  let color: PointFreeColor?
  let label: Label
  let href: String

  public init(color: PointFreeColor? = nil, href: String, @HTMLBuilder label: () -> Label) {
    self.color = color
    self.href = href
    self.label = label()
  }

  public init(_ title: String, color: PointFreeColor? = nil, href: String) where Label == HTMLText {
    self.init(color: color, href: href) {
      HTMLText(title)
    }
  }

  public var body: some HTML {
    a { label }
      .attribute("href", href)
      .color(color, .link)
      .color(color, .visited)
  }
}
