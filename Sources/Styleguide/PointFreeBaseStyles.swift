import Css
import Prelude

public enum Colors {
  public static let black = Color.other("#121212")
  public static let blue = Color.other("#4CCCFF")
  public static let gray900 = Color.other("#f6f6f6")
  public static let gray300 = Color.other("#555555")
  public static let gray850 = Color.other("#d8d8d8")
  public static let green = Color.other("#79F2B0")
  public static let purple = Color.other("#974DFF")
  public static let yellow = Color.other("#FFF080")
}

extension Class {
  public enum pf {
    public enum colors {
      public enum bg {
        public static let black = CssSelector.class("bg-black")
        public static let black50 = CssSelector.class("bg-black-50")
        public static let dark = CssSelector.class("bg-dark")
        public static let light = CssSelector.class("bg-light")
        public static let purple = CssSelector.class("bg-purple")
        public static let white = CssSelector.class("bg-white")
      }
      public enum border {
        public static let gray900 = CssSelector.class("border-gray-900")
      }
      public enum fg {
        public static let black = CssSelector.class("fg-black")
        public static let gray300 = CssSelector.class("fg-gray300")
        public static let gray850 = CssSelector.class("fg-gray850")
        public static let purple = CssSelector.class("fg-purple")
        public static let white = CssSelector.class("fg-white")
      }
    }

    private static let _codeClasses =
      _codeClass
        | Class.layout.block
        | Class.padding.all(3)
        | Class.layout.overflowAuto(.x)
    public static func code(lang: String?) -> CssSelector {
      return _codeClasses | .class(lang ?? "")
    }

    public static let divider = _dividerClass
      | Class.border.top
      | Class.margin.all(0)
      | Class.padding.all(0)
      | Class.pf.colors.bg.white

    public static let inlineCode = CssSelector.class("inline-code")
    public static let opacity25 = CssSelector.class("opacity-25")
    public static let opacity50 = CssSelector.class("opacity-50")
    public static let opacity75 = CssSelector.class("opacity-75")
    public enum type {
      public static let largeTitle =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h1
          | Class.type.lineHeight(0)

      public static let title1 =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h2
          | Class.type.lineHeight(1)

      public static let title2 =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h3
          | Class.type.lineHeight(1)

      public static let title3 =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h4
          | Class.type.lineHeight(2)

      public static let headline =
        _headline
          | Class.pf.colors.fg.black
          | Class.h5
          | Class.type.lineHeight(2)

      public static let subhead =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h6
          | Class.type.lineHeight(3)
          | Class.type.caps

      public static let footnote = CssSelector.class("pf-footnote")
      public static let callout = CssSelector.class("pf-callout")
    }

    public enum components {
      /// The standard nav bar style.
      public static let navBar =
        _navBar
          | Class.pf.colors.bg.purple
          | Class.padding.leftRight(2)
          | Class.type.lineHeight(rem: 4)
          | Class.size.height(rem: 4)

      /// A minimal nav bar style.
      public static let minimalNavBar =
        _navBar
          | Class.pf.colors.bg.black
          | Class.padding.leftRight(2)
          | Class.type.lineHeight(rem: 3)
          | Class.size.height(rem: 3)
    }
  }
}
 
public let pointFreeBaseStyles =
  (body | html) % height(.pct(100))
    <> bodyStyles
    <> resets
    <> colorStyles
    <> codeStyles
    <> inlineCodeStyles
    <> opacities
    <> buttonStyles
    <> aStyles
    <> typeStyles
    <> baseMarginStyles
    <> navBarStyles
    <> hrReset
    <> dividerStyles
    <> _borderStyles

private let bodyStyles =
  html % (
    fontSize(.px(14))
      <> fontFamily(["-apple-system", "Helvetica Neue", "Helvetica", "Arial", "sans-serif"])
      <> lineHeight(1.5)
      <> boxSizing(.borderBox)
    )
    <> queryOnly(screen, [minWidth(Breakpoint.md.minSize)]) {
      html % fontSize(.px(16))
}

private let resets =
  body % boxSizing(.borderBox)
    <> (.star | .star & .pseudoElem(.before) | .star & .pseudoElem(.after)) % boxSizing(.inherit)

private let colorStyles =
  Class.pf.colors.bg.black % backgroundColor(Colors.black)
  <> Class.pf.colors.bg.black50 % color(.other("#808080"))
    <> Class.pf.colors.bg.dark % backgroundColor(Colors.black)
    <> Class.pf.colors.bg.light % backgroundColor(.other("#888"))
    <> Class.pf.colors.bg.purple % backgroundColor(Colors.purple)
    <> Class.pf.colors.bg.white % backgroundColor(.other("#fff"))
    <> Class.pf.colors.fg.black % color(Colors.black)
    <> Class.pf.colors.fg.gray300 % color(Colors.gray300)
    <> Class.pf.colors.fg.gray850 % color(Colors.gray850)
    <> Class.pf.colors.fg.purple % color(Colors.purple)
    <> Class.pf.colors.fg.white % color(.other("#fff"))

private let _codeClass = CssSelector.class("code")
private let codeStyles =
  _codeClass % (
    backgroundColor(.other("#fafafa"))
      <> fontFamily(["monospace"])
)

private let inlineCodeStyles =
  Class.pf.inlineCode % (
    fontFamily(["monospace"])
      <> padding(topBottom: .px(1), leftRight: .px(5))
      <> borderWidth(all: .px(1))
      <> borderRadius(all: .px(3))
      <> backgroundColor(Color.other("#fafafa"))
)

private let opacities =
  Class.pf.opacity25 % opacity(0.25)
    <> Class.pf.opacity50 % opacity(0.50)
    <> Class.pf.opacity75 % opacity(0.75)

private let buttonStyles =
  baseButtonStyles
    <> btnHoverStyles
    <> btnFocusStyles

private let baseButtonStyles: Stylesheet =
  Class.btn.base % (
    appearance(.none)
      <> backgroundColor(.transparent)
      <> borderColor(all: .transparent)
      <> borderStyle(all: .solid)
      <> borderWidth(all: .px(1))
      <> color(.inherit)
      <> key("cursor", "pointer")
      <> display(.inlineBlock)
      <> fontFamily(.inherit)
      <> fontSize(.inherit)
      <> fontWeight(.bold)
      <> height(.auto)
      <> lineHeight(.rem(1.125))
      <> margin(all: 0)
      <> padding(all: .rem(1))
      <> key("text-decoration", "none")
      <> verticalAlign(.middle)
)

private let btnHoverStyles: Stylesheet =
  (Class.btn.base & .pseudo(.hover)) % key("text-decoration", "none")

private let btnFocusStyles: Stylesheet =
  (Class.btn.base & .pseudo(.focus)) % (
    outlineStyle(all: .none)
      <> borderColor(all: .rgba(0, 0, 0, 0.125))
      <> boxShadow(hShadow: 0, vShadow: 0, blurRadius: 0, spreadRadius: .px(3), color: .rgba(0, 0, 0, 0.25))
)

extension Class {
  public static let btn = (
    base: CssSelector.class("btn"),
    primary: CssSelector.class("btn-pr")
  )
}

private let aStyles =
  (a | a & .pseudo(.link) | a & .pseudo(.visited)) % (
    color(Colors.black)
      <> key("text-decoration", "none")
  )
  <> (a & .pseudo(.hover) | a & .pseudo(.active)) % (
    key("text-decoration", "underline")
)

private let baseMarginStyles =
  (h1 | h2 | h3 | h4 | h5 | h6 | p | ul | ol) % margin(topBottom: .rem(0.5), leftRight: 0)

private let _headline = CssSelector.class("pf-headline")

private let typeStyles =
  _headline % fontWeight(.w600)
    <> Class.pf.type.footnote % (fontSize(.rem(0.8125)) <> lineHeight(1.5))
    <> Class.pf.type.callout % (fontSize(.rem(1.1875)) <> lineHeight(1.5))


private let _navBar = CssSelector.class("pf-navbar")
private let navBarStyles =
  ((_navBar ** a) | (_navBar ** a & .pseudo(.link))) % color(.other("#fff"))

private let hrReset =
  hr % (borderColor(all: .none) <> borderStyle(all: .none) <> borderWidth(all: .none))

private let _dividerClass = CssSelector.class("pf-divider")
private let dividerStyles =
  _dividerClass % (
    borderColor(top: Color.other("#ddd"))
      <> height(.px(1))
)

private let _borderStyles =
  Class.pf.colors.border.gray900 % borderColor(all: Colors.gray900)
