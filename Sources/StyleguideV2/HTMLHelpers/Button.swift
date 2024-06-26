public struct Button<Label: HTML>: HTML {
  let tag: HTMLTag
  let color: PointFreeColor?
  let size: Size
  let style: Style
  let label: Label

  public init(
    tag: HTMLTag = a,
    color: PointFreeColor? = nil,
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
    .inlineStyle("cursor", "pointer")
    .inlineStyle("font-weight", "medium")
    .inlineStyle("white-space", "nowrap")
    .backgroundColor(color)
    .color(.black)
    .fontStyle(.body(.small))
    .padding(size.padding)
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

    // var typeScale: TypeScale {
    //
  }

  public enum Style {
    case normal
    case outline
    case underline
  }
}

//  let sizeStyles: CssSelector
//  switch size {
//  case .small:
//    sizeStyles = Class.h6 | Class.padding([.mobile: [.leftRight: 1, .topBottom: 1]])
//  case .regular:
//    sizeStyles = Class.h5 | Class.padding([.mobile: [.leftRight: 2]])
//  case .large:
//    sizeStyles = Class.h4 | Class.padding([.mobile: [.leftRight: 2]])
//  }


// TODO:
//  switch style {
//  case .normal:
//    borderStyles =
//      baseNormalButtonClass
//      | Class.border.none
//      | Class.type.textDecorationNone
//  case .outline:
//    borderStyles =
//      Class.border.rounded.all
//      | Class.border.all
//      | Class.type.textDecorationNone
//  case .underline:
//    borderStyles =
//      baseUnderlineButtonClass
//      | Class.border.none
//      | Class.type.underline
//  }
//
//  let colorStyles: CssSelector
//  switch (style, color) {
//  case (.normal, .black):
//    colorStyles =
//      Class.pf.colors.link.white
//      | Class.pf.colors.fg.white
//      | Class.pf.colors.bg.black
//  case (.normal, .purple):
//    colorStyles =
//      Class.pf.colors.link.white
//      | Class.pf.colors.fg.white
//      | Class.pf.colors.bg.purple
//  case (.normal, .red):
//    colorStyles =
//      Class.pf.colors.link.white
//      | Class.pf.colors.fg.white
//      | Class.pf.colors.bg.red
//  case (.normal, .white):
//    colorStyles =
//      Class.pf.colors.link.black
//      | Class.pf.colors.fg.black
//      | Class.pf.colors.bg.white
//  case (.outline, .black), (.underline, .black):
//    colorStyles =
//      Class.pf.colors.link.black
//      | Class.pf.colors.fg.black
//      | Class.pf.colors.bg.inherit
//  case (.outline, .purple), (.underline, .purple):
//    colorStyles =
//      Class.pf.colors.link.purple
//      | Class.pf.colors.fg.purple
//      | Class.pf.colors.bg.inherit
//  case (.outline, .red), (.underline, .red):
//    colorStyles =
//      Class.pf.colors.link.red
//      | Class.pf.colors.fg.red
//      | Class.pf.colors.bg.inherit
//  case (.outline, .white), (.underline, .white):
//    colorStyles =
//      Class.pf.colors.link.white
//      | Class.pf.colors.fg.white
//      | Class.pf.colors.bg.inherit
//  }
//
//  let sizeStyles: CssSelector
//  switch size {
//  case .small:
//    sizeStyles = Class.h6 | Class.padding([.mobile: [.leftRight: 1, .topBottom: 1]])
//  case .regular:
//    sizeStyles = Class.h5 | Class.padding([.mobile: [.leftRight: 2]])
//  case .large:
//    sizeStyles = Class.h4 | Class.padding([.mobile: [.leftRight: 2]])
//  }
//
//  return baseStyles | borderStyles | colorStyles | sizeStyles
//}
