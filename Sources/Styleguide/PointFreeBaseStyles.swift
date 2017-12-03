import Css
import Prelude

public enum Colors {
  public static let black = Color.other("#121212")
  public static let purple = Color.other("#974DFF")
  public static let blue = Color.other("#4CCCFF")
  public static let green = Color.other("#79F2B0")
  public static let yellow = Color.other("#FFF080")
}

extension Class {
  public enum pf {
    public enum colors {
      public enum bg {
        public static let black50 = CssSelector.class("bg-black-50")
        public static let dark = CssSelector.class("bg-dark")
        public static let light = CssSelector.class("bg-light")
        public static let white = CssSelector.class("bg-white")
        public static let black = CssSelector.class("bg-black")
        public static let purple = CssSelector.class("bg-purple")
      }
      public enum fg {
        public static let white = CssSelector.class("fg-white")
      }
    }
    public static func code(lang: String?) -> CssSelector {
      return _codeClass
        | .class(lang ?? "")
        | Class.layout.block
        | Class.padding.all(3)
        | Class.layout.overflowAuto(.x)
    }

    public static let inlineCode = CssSelector.class("inline-code")
    public static let opacity25 = CssSelector.class("opacity-25")
    public static let opacity50 = CssSelector.class("opacity-50")
    public static let opacity75 = CssSelector.class("opacity-75")
    public enum type {
      public static let largeTitle = CssSelector.class("pf-large-title")
      public static let title1 = CssSelector.class("pf-title-1")
      public static let title2 = CssSelector.class("pf-title-2")
      public static let title3 = CssSelector.class("pf-title-3")
      public static let headline = CssSelector.class("pf-headline")
      public static let subhead = CssSelector.class("pf-subhead")
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
  Class.pf.colors.bg.black50 % color(.other("#808080"))
    <> Class.pf.colors.fg.white % color(.other("#fff"))
    <> Class.pf.colors.bg.dark % backgroundColor(Colors.black)
    <> Class.pf.colors.bg.light % backgroundColor(.other("#888"))
    <> Class.pf.colors.bg.white % backgroundColor(.other("#fff"))
    <> Class.pf.colors.bg.black % backgroundColor(Colors.black)
    <> Class.pf.colors.bg.purple % backgroundColor(Colors.purple)

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

private let typeStyles =
  (Class.pf.type.largeTitle
    | Class.pf.type.title1
    | Class.pf.type.title2
    | Class.pf.type.title3
    | Class.pf.type.headline
    | Class.pf.type.subhead) % color(Color.black)

    <> (Class.pf.type.largeTitle
      | Class.pf.type.title1
      | Class.pf.type.title2
      | Class.pf.type.title3
      | Class.pf.type.subhead) % fontWeight(.w700)

    <> Class.pf.type.largeTitle % (fontSize(.rem(3.998)) <> lineHeight(1.15))
    <> Class.pf.type.title1 % (fontSize(.rem(2.827)) <> lineHeight(1.25))
    <> Class.pf.type.title2 % (fontSize(.rem(1.999)) <> lineHeight(1.25))
    <> Class.pf.type.title3 % (fontSize(.rem(1.414)) <> lineHeight(1.45))

    <> Class.pf.type.footnote % (fontSize(.rem(0.8125)) <> lineHeight(1.5))
    <> Class.pf.type.callout % (fontSize(.rem(1.1875)) <> lineHeight(1.5))

    <> Class.pf.type.headline % (
      fontSize(.rem(1))
        <> fontWeight(.w600)
        <> lineHeight(1.45)
    )
    <> Class.pf.type.subhead % (
      fontSize(.rem(0.707))
        <> lineHeight(1.5)
        <> letterSpacing(.pt(0.54))
        <> textTransform(.uppercase)
)

private let _navBar = CssSelector.class("pf-navbar")
private let navBarStyles =
  ((_navBar ** a) | (_navBar ** a & .pseudo(.link))) % color(.other("#fff"))
