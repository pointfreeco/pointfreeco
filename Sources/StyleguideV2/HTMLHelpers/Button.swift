public struct Button<Label: HTML>: HTML {
  let tagName: String
  let color: Color
  let size: Size
  let style: Style
  let label: Label

  public init(
    tag: HTMLTag = a,
    color: Color,
    size: Size = .regular,
    style: Style = .normal,
    @HTMLBuilder label: () -> Label
  ) {
    self.tagName = tag.rawValue
    self.color = color
    self.size = size
    self.style = style
    self.label = label()
  }

  public init(
    tag: HTMLVoidTag,
    color: Color,
    size: Size = .regular,
    style: Style = .normal
  ) where Label == HTMLEmpty {
    self.tagName = tag.rawValue
    self.color = color
    self.size = size
    self.style = style
    self.label = HTMLEmpty()
  }

  public var body: some HTML {
    tag(tagName) {
      label
    }
    .inlineStyle("border", "\(style.border) \(color.foregroundColor(for: style).rawValue)")
    .inlineStyle(
      "border",
      color.foregroundColor(for: style).darkValue.map { "\(style.border) \($0)" },
      media: .dark
    )
    .inlineStyle("border-radius", "0.5rem")
    .inlineStyle("box-shadow", "inset 0 0 0 20rem rgba(0,0,0,0.1)", pseudo: .hover)
    .inlineStyle("cursor", "pointer")
    .inlineStyle("font-weight", "500")
    .inlineStyle("text-decoration", style.textDecoration)
    .inlineStyle("text-decoration", style.textDecoration, media: nil, pseudo: .link)
    .inlineStyle("white-space", "nowrap")
    .inlineStyle("padding", "\(size.topBottomPadding)rem \(size.leftRightPadding)rem")
    .inlineStyle("transition", "0.3s")
    .backgroundColor(color.backgroundColor(for: style))
    .color(color.foregroundColor(for: style))
    .color(color.foregroundColor(for: style), .link)
    .color(color.foregroundColor(for: style), .visited)
    .fontScale(size.fontScale)
  }

  public enum Color {
    case black
    case purple
    case red
    case white

    fileprivate var rawValue: PointFreeColor {
      switch self {
      case .black: .black.dark(.white)
      case .purple: .purple
      case .red: .red
      case .white: .white.dark(.black)
      }
    }

    fileprivate func backgroundColor(for style: Style) -> PointFreeColor? {
      switch (style, self) {
      case (.normal, _): rawValue
      default: nil
      }
    }

    fileprivate func foregroundColor(for style: Style) -> PointFreeColor {
      switch (style, self) {
      case (.normal, .black), (.normal, .purple), (.normal, .red): .white
      case (.normal, .white): .black
      case (.outline, _), (.underline, _): rawValue
      }
    }
  }

  public enum Size {
    case small
    case regular
    case large

    fileprivate var leftRightPadding: Double {
      switch self {
      case .small: 1
      case .regular: 1.25
      case .large: 1.5
      }
    }
    fileprivate var topBottomPadding: Double {
      switch self {
      case .small: 0.75
      case .regular: 1
      case .large: 1.25
      }
    }

    fileprivate var fontScale: FontScale {
      switch self {
      case .small: .h6
      case .regular: .h5
      case .large: .h4
      }
    }
  }

  public enum Style {
    case normal
    case outline
    case underline

    fileprivate var border: String {
      switch self {
      case .normal, .underline: "none"
      case .outline: "1px solid"
      }
    }

    fileprivate var textDecoration: String {
      switch self {
      case .normal, .outline: "none"
      case .underline: "underline"
      }
    }
  }
}
