public struct Button<Label: HTML>: HTML {
  let tag: HTMLTag
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
    self.tag = tag
    self.color = color
    self.size = size
    self.style = style
    self.label = label()
  }

  public var body: some HTML {
    tag {
      label
    }
    .inlineStyle("border", style.border)
    .inlineStyle("box-shadow", "inset 0 0 0 20rem rgba(0,0,0,0.1)", pseudo: "hover")
    .inlineStyle("cursor", "pointer")
    .inlineStyle("font-weight", "500")
    .inlineStyle("text-decoration", style.textDecoration)
    .inlineStyle("text-decoration", style.textDecoration, media: nil, pseudo: "link")
    .inlineStyle("white-space", "nowrap")
    .backgroundColor(color.backgroundColor(for: style))
    .color(color.foregroundColor(for: style))
    .color(color.foregroundColor(for: style), .link)
    .color(color.foregroundColor(for: style), .visited)
    .fontScale(size.fontScale)
    .padding(size.padding)
  }

  public enum Color {
    case black
    case purple
    case red
    case white

    fileprivate var rawValue: PointFreeColor {
      switch self {
      case .black: .black
      case .purple: .purple
      case .red: .red
      case .white: .white
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

    fileprivate var padding: Padding {
      switch self {
      case .small: Padding(topBottom: 1, leftRight: 1)
      case .regular, .large: Padding(topBottom: 1, leftRight: 2)
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
      case .outline: "rounded"
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
