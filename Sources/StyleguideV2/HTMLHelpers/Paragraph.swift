public struct Paragraph<Content: HTML>: HTML {
  let size: Size
  @HTMLBuilder let content: Content
  public init(_ size: Size = .regular, @HTMLBuilder content: () -> Content) {
    self.size = size
    self.content = content()
  }

  public var body: some HTML {
    tag("p") {
      content
    }
    .inlineStyle("padding-bottom", "0.5rem", pseudo: "not(:last-child)")
    .inlineStyle("padding-top", "0")
    .inlineStyle("padding-left", "0")
    .inlineStyle("padding-right", "0")
    .inlineStyle("margin", "0")
    .inlineStyle("line-height", "1.5")
  }

  public enum Size {
    case big
    case regular
    case small
    var fontSize: Double {
      switch self {
      case .big: 19/16
      case .regular: 16/16
      case .small: 14/16
      }
    }
    var lineHeight: Double {
      switch self {
      case .big: 28/16
      case .regular: 24/16
      case .small: 21/16
      }
    }
  }
}
