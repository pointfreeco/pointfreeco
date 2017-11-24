@testable import Css
import Prelude

extension Class {
  public enum pf {
    public enum colors {
      public enum fg {
        public static let dark = CssSelector.class("fg-dark")
        public static let light = CssSelector.class("fg-light")
        public static let white = CssSelector.class("fg-white")
      }
      public enum bg {
        public static let dark = CssSelector.class("bg-dark")
        public static let light = CssSelector.class("bg-light")
        public static let white = CssSelector.class("bg-white")
      }
    }
    public static let code = CssSelector.class("code")
    public static let inlineCode = CssSelector.class("inline-code")
  }
}
 
public let pointFreeBaseStyles =
  (body | html) % height(.pct(100))
    <> bodyStyles
    <> resets
    <> colorStyles
    <> codeStyles
    <> inlineCodeStyles

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
  Class.pf.colors.bg.dark % backgroundColor(.other("#222"))
    <> Class.pf.colors.bg.light % backgroundColor(.other("#888"))
    <> Class.pf.colors.bg.white % backgroundColor(.other("#fff"))
    <> Class.pf.colors.fg.dark % color(.other("#222"))
    <> Class.pf.colors.fg.light % backgroundColor(.other("#888"))
    <> Class.pf.colors.fg.white % color(.other("#fff"))

private let codeStyles =
  Class.pf.code % (
    display(.block)
      <> backgroundColor(.other("#fafafa"))
      <> fontFamily(["monospace"])
      <> padding(all: .rem(2))
      <> overflow(x: .auto)
)

private let inlineCodeStyles =
  Class.pf.inlineCode % (
    fontFamily(["monospace"])
      <> padding(topBottom: .px(1), leftRight: .px(5))
      <> borderWidth(all: .px(1))
      <> borderRadius(all: .px(3))
      <> backgroundColor(Color.other("#fafafa"))
)
