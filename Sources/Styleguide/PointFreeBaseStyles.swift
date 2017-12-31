import Css
import Prelude

public enum Colors {
  public static let black = Color.other("#121212")
  public static let blue = Color.other("#4CCCFF")
  public static let gray300 = Color.other("#555555")
  public static let gray400 = Color.other("#666666")
  public static let gray650 = Color.other("#a8a8a8")
  public static let gray800 = Color.other("#ccc")
  public static let gray850 = Color.other("#d8d8d8")
  public static let gray900 = Color.other("#f6f6f6")
  public static let green = Color.other("#79F2B0")
  public static let mint = Color.other("#79F2B0")
  public static let purple = Color.other("#974DFF")
  public static let purple150 = Color.other("#291a40")
  public static let red = Color.other("#eb1c26")
  public static let teal = Color.other("#4CCCFF")
  public static let yellow = Color.other("#FFF080")
  public static let white = Color.other("#fff")
}

extension Class {
  public enum pf {
    public enum colors {
      public enum bg {
        public static let black = CssSelector.class("bg-black")
        public static let dark = CssSelector.class("bg-dark")
        public static let gray650 = CssSelector.class("bg-gray650")
        public static let gray900 = CssSelector.class("bg-gray900")
        public static let green = CssSelector.class("bg-green")
        public static let inherit = CssSelector.class("bg-inherit")
        public static let purple = CssSelector.class("bg-purple")
        public static let purple150 = CssSelector.class("bg-purple150")
        public static let red = CssSelector.class("bg-red")
        public static let white = CssSelector.class("bg-white")
        public static let yellow = CssSelector.class("bg-yellow")
      }
      public enum border {
        public static let gray650 = CssSelector.class("border-gray-650")
        public static let gray800 = CssSelector.class("border-gray-800")
        public static let gray900 = CssSelector.class("border-gray-900")
      }
      public enum fg {
        public static let black = CssSelector.class("fg-black")
        public static let gray300 = CssSelector.class("fg-gray300")
        public static let gray400 = CssSelector.class("fg-gray400")
        public static let gray650 = CssSelector.class("fg-gray650")
        public static let gray850 = CssSelector.class("fg-gray850")
        public static let green = CssSelector.class("fg-green")
        public static let purple = CssSelector.class("fg-purple")
        public static let red = CssSelector.class("fg-red")
        public static let white = CssSelector.class("fg-white")
        public static let yellow = CssSelector.class("fg-yellow")
      }
      public enum link {
        public static let black = CssSelector.class("pf-link-black")
        public static let gray650 = CssSelector.class("pf-link-gray650")
        public static let green = CssSelector.class("pf-link-green")
        public static let purple = CssSelector.class("pf-link-purple")
        public static let red = CssSelector.class("pf-link-red")
        public static let white = CssSelector.class("pf-link-white")
        public static let yellow = CssSelector.class("pf-link-yellow")
      }
    }
    public static let inlineCode = CssSelector.class("inline-code")
    public static let opacity25 = CssSelector.class("opacity-25")
    public static let opacity50 = CssSelector.class("opacity-50")
    public static let opacity75 = CssSelector.class("opacity-75")
    public enum type {
      public static let title1 =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h1
          | Class.type.lineHeight(2)

      public static let title2 =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h2
          | Class.type.lineHeight(2)

      public static let title3 =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h3
          | Class.type.lineHeight(2)

      public static let title4 =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h4
          | Class.type.lineHeight(2)

      public static let title5 =
        Class.pf.colors.fg.black
          | Class.type.semiBold
          | Class.h5
          | Class.type.lineHeight(1)

      public static let title6 =
        Class.pf.colors.fg.black
          | Class.type.bold
          | Class.h6
          | Class.type.lineHeight(1)
          | Class.type.caps

      public enum body {
        public static let small =
          Class.pf.colors.fg.black
            | Class.type.normal
            | Class.h6
            | Class.type.lineHeight(4)

        public static let regular =
          Class.pf.colors.fg.black
            | Class.type.normal
            | Class.h5
            | Class.type.lineHeight(4)

        public static let leading =
          bodyLeadingClass
            | Class.pf.colors.fg.black
            | Class.type.normal
            | Class.type.lineHeight(4)
      }
    }
  }
}

extension Class.pf {
  public enum components {

    public enum Color {
      case black
      case purple
      case red
      case white
    }

    public enum Size {
      case small
      case regular
      case large
    }

    public enum Style {
      case normal
      case outline
      case underline
    }

    public static func button(color: Color, size: Size = .regular, style: Style = .normal) -> CssSelector {
      let baseStyles =
        Class.type.medium
          | Class.cursor.pointer

      let borderStyles: CssSelector
      switch style {
      case .normal:
        borderStyles = baseNormalButtonClass
          | Class.border.rounded.all
          | Class.border.none
          | Class.type.textDecorationNone
      case .outline:
        borderStyles = Class.border.rounded.all
          | Class.border.none
          | Class.type.textDecorationNone
      case .underline:
        borderStyles = baseUnderlineButtonClass
          | Class.border.none
          | Class.type.underline
      }

      let colorStyles: CssSelector
      switch (style, color) {
      case (.normal, .black):
        colorStyles =
          Class.pf.colors.link.white
          | Class.pf.colors.fg.white
          | Class.pf.colors.bg.black
      case (.normal, .purple):
        colorStyles =
          Class.pf.colors.link.white
          | Class.pf.colors.fg.white
          | Class.pf.colors.bg.purple
      case (.normal, .red):
        colorStyles =
          Class.pf.colors.link.white
          | Class.pf.colors.fg.white
          | Class.pf.colors.bg.red
      case (.normal, .white):
        colorStyles =
          Class.pf.colors.link.black
          | Class.pf.colors.fg.black
          | Class.pf.colors.bg.white
      case (.outline, .black), (.underline, .black):
        colorStyles =
          Class.pf.colors.link.black
          | Class.pf.colors.fg.black
          | Class.pf.colors.bg.inherit
      case (.outline, .purple), (.underline, .purple):
        colorStyles =
          Class.pf.colors.link.purple
          | Class.pf.colors.fg.purple
          | Class.pf.colors.bg.inherit
      case (.outline, .red), (.underline, .red):
        colorStyles =
          Class.pf.colors.link.red
          | Class.pf.colors.fg.red
          | Class.pf.colors.bg.inherit
      case (.outline, .white), (.underline, .white):
        colorStyles =
          Class.pf.colors.link.white
          | Class.pf.colors.fg.white
          | Class.pf.colors.bg.inherit
      }

      let sizeStyles: CssSelector
      switch size {
      case .small:
        sizeStyles = Class.h6 | Class.padding([.mobile: [.leftRight: 1, .topBottom: 1]])
      case .regular:
        sizeStyles = Class.h5 | Class.padding([.mobile: [.leftRight: 2]])
      case .large:
        sizeStyles = Class.h4 | Class.padding([.mobile: [.leftRight: 2]])
      }

      return baseStyles | borderStyles | colorStyles | sizeStyles
    }

    private static let pricingTabBase =
      Class.layout.fit
        | Class.pf.type.title5
        | Class.type.medium
        | Class.padding([.mobile: [.leftRight: 2]])
        | Class.padding([.mobile: [.topBottom: 2]])
        | Class.border.none
        | Class.size.width50pct
        | Class.display.inlineBlock
    public static let pricingTabSelected =
      pricingTabBase
        | Class.pf.colors.bg.white
        | Class.pf.colors.fg.purple
    public static let pricingTab =
      pricingTabBase
        | Class.pf.colors.bg.purple
        | Class.pf.colors.fg.white

    private static let _codeClasses =
      _codeClass
        | Class.display.block
        | Class.padding([.mobile: [.all: 3]])
        | Class.layout.overflowAuto(.x)
    public static func code(lang: String?) -> CssSelector {
      return _codeClasses | .class(lang ?? "")
    }

    public static let divider = dividerClass
      | Class.border.top
      | Class.margin([.mobile: [.all: 0]])
      | Class.pf.colors.bg.white

    /// The standard nav bar style.
    public static let navBar =
      _navBar
        | Class.pf.colors.bg.purple
        | Class.padding([.mobile: [.leftRight: 2]])
        | Class.type.lineHeight(rem: 4)
        | Class.size.height(rem: 4)

    /// A minimal nav bar style.
    public static let minimalNavBar =
      _navBar
        | Class.pf.colors.bg.black
        | Class.padding([.mobile: [.leftRight: 2]])
        | Class.type.lineHeight(rem: 3)
        | Class.size.height(rem: 3)

    public static let videoTimeLink =
      videoTimeLinkClass
        | Class.type.textDecorationNone
        | Class.pf.colors.bg.gray650
        | Class.pf.colors.link.white
        | Class.border.rounded.all
        | Class.h6

    public static let heroLogo = CssSelector.class("hero-logo")
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
    <> aStyles
    <> typeStyles
    <> baseMarginStyles
    <> hrReset
    <> dividerStyles
    <> navBarStyles
    <> baseButtonStyles
    <> heroLogoStyles
    <> videoTimeLinkStyles

private let bodyStyles =
  html % (
    fontSize(.px(14))
      <> fontFamily(["-apple-system", "Helvetica Neue", "Helvetica", "Arial", "sans-serif"])
      <> lineHeight(1.5)
      <> boxSizing(.borderBox)
    )
    <> Breakpoint.desktop.querySelfAndBigger(only: screen) {
      html % fontSize(.px(16))
}

private let resets =
  body % boxSizing(.borderBox)
    <> (.star | .star & .pseudoElem(.before) | .star & .pseudoElem(.after)) % boxSizing(.inherit)

private let colorStyles: Stylesheet =
  Class.pf.colors.bg.black % backgroundColor(Colors.black)
    <> Class.pf.colors.bg.dark % backgroundColor(Colors.black)
    <> Class.pf.colors.bg.gray650 % backgroundColor(Colors.gray650)
    <> Class.pf.colors.bg.gray900 % backgroundColor(Colors.gray900)
    <> Class.pf.colors.bg.green % backgroundColor(Colors.green)
    <> Class.pf.colors.bg.inherit % backgroundColor(.inherit)
    <> Class.pf.colors.bg.purple % backgroundColor(Colors.purple)
    <> Class.pf.colors.bg.purple150 % backgroundColor(Colors.purple150)
    <> Class.pf.colors.bg.red % backgroundColor(Colors.red)
    <> Class.pf.colors.bg.white % backgroundColor(.other("#fff"))
    <> Class.pf.colors.bg.yellow % backgroundColor(Colors.yellow)

    <> Class.pf.colors.border.gray650 % borderColor(all: Colors.gray650)
    <> Class.pf.colors.border.gray800 % borderColor(all: Colors.gray800)    
    <> Class.pf.colors.border.gray900 % borderColor(all: Colors.gray900)

    <> Class.pf.colors.fg.black % color(Colors.black)
    <> Class.pf.colors.fg.gray300 % color(Colors.gray300)
    <> Class.pf.colors.fg.gray400 % color(Colors.gray400)
    <> Class.pf.colors.fg.gray650 % color(Colors.gray650)
    <> Class.pf.colors.fg.gray850 % color(Colors.gray850)
    <> Class.pf.colors.fg.green % color(Colors.green)
    <> Class.pf.colors.fg.purple % color(Colors.purple)
    <> Class.pf.colors.fg.red % color(Colors.red)
    <> Class.pf.colors.fg.yellow % color(Colors.yellow)
    <> Class.pf.colors.fg.white % color(.other("#fff"))

    <> (a & .pseudo(.link) & Class.pf.colors.link.black) % color(Colors.black)
    <> (a & .pseudo(.visited) & Class.pf.colors.link.black) % color(Colors.black)
    <> (a & .pseudo(.link) & Class.pf.colors.link.gray650) % color(Colors.gray650)
    <> (a & .pseudo(.visited) & Class.pf.colors.link.gray650) % color(Colors.gray650)
    <> (a & .pseudo(.link) & Class.pf.colors.link.green) % color(Colors.green)
    <> (a & .pseudo(.visited) & Class.pf.colors.link.green) % color(Colors.green)
    <> (a & .pseudo(.link) & Class.pf.colors.link.purple) % color(Colors.purple)
    <> (a & .pseudo(.visited) & Class.pf.colors.link.purple) % color(Colors.purple)
    <> (a & .pseudo(.link) & Class.pf.colors.link.red) % color(Colors.red)
    <> (a & .pseudo(.visited) & Class.pf.colors.link.red) % color(Colors.red)
    <> (a & .pseudo(.link) & Class.pf.colors.link.white) % color(Colors.white)
    <> (a & .pseudo(.visited) & Class.pf.colors.link.white) % color(Colors.white)
    <> (a & .pseudo(.link) & Class.pf.colors.link.yellow) % color(Colors.yellow)
    <> (a & .pseudo(.visited) & Class.pf.colors.link.white) % color(Colors.white)

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

private let bodyLeadingClass = CssSelector.class("body-leading")
private let typeStyles =
  bodyLeadingClass % fontSize(.rem(1.1875))

private let hrReset =
  hr % (borderColor(all: .none) <> borderStyle(all: .none) <> borderWidth(all: .none))

private let dividerClass = CssSelector.class("pf-divider")
private let dividerStyles =
  dividerClass % (
    borderColor(top: Color.other("#ddd"))
      <> height(.px(0))
)

private let _navBar = CssSelector.class("pf-navbar")
private let navBarStyles =
  ((_navBar ** a) | (_navBar ** a & .pseudo(.link))) % color(.other("#fff"))

private let baseButtonStyles =
  baseNormalButtonStyles
    <> baseUnderlineButtonStyles

private let baseNormalButtonClass = CssSelector.class("btn-normal")
private let baseNormalButtonStyles: Stylesheet =
  (baseNormalButtonClass & .pseudo(.hover)) % darken1
    <> (a & .pseudo(.active) & baseNormalButtonClass) % darken3
    <> (a & .pseudo(.link) & baseNormalButtonClass) % key("text-decoration", "none")
    <> baseNormalButtonClass % padding(topBottom: .rem(0.75))

private let baseUnderlineButtonClass = CssSelector.class("btn-outline")
private let baseUnderlineButtonStyles: Stylesheet =
  (baseUnderlineButtonClass & .pseudo(.hover)) % key("text-decoration", "none !important")
    <> baseUnderlineButtonClass % key("text-decoration", "underline !important")

private let darken1 = boxShadow(
  stroke: .inset,
  hShadow: 0,
  vShadow: 0,
  blurRadius: 0,
  spreadRadius: .rem(20),
  color: Color.rgba(0, 0, 0, 0.1)
)

private let darken2 = boxShadow(
  stroke: .inset,
  hShadow: 0,
  vShadow: 0,
  blurRadius: 0,
  spreadRadius: .rem(20),
  color: Color.rgba(0, 0, 0, 0.2)
)

private let darken3 = boxShadow(
  stroke: .inset,
  hShadow: 0,
  vShadow: 0,
  blurRadius: 0,
  spreadRadius: .rem(20),
  color: Color.rgba(0, 0, 0, 0.3)
)

private let heroLogoStyles =
  Breakpoint.mobile.query(only: screen) {
    Class.pf.components.heroLogo % maxWidth(.px(160))
}

private let videoTimeLinkClass = CssSelector.class("vid-time-link")
private let videoTimeLinkStyles =
  videoTimeLinkClass % (
    padding(all: .rem(0.25))
      <> margin(right: .rem(0.25))
)
