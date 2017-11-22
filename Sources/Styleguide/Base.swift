import Css
import Prelude

extension Class {
  public enum pf {
    public static let bgDark = CssSelector.class("bg-dark")
    public static let bgWhite = CssSelector.class("bg-white")
    public static let code = CssSelector.class("code")
  }
}

public let pointFreeBaseStyles =
  (body | html) % height(.pct(100))
    <> bodyStyles
    <> resets
    <> colorStyles
    <> codeStyles

private let bodyStyles =
  body % (
    fontSize(.px(16))
      <> fontFamily(["-apple-system", "Helvetica Neue", "Helvetica", "Arial", "sans-serif"])
      <> lineHeight(1.5)
      <> boxSizing(.borderBox)
)

private let resets =
  body % boxSizing(.borderBox)
    <> (.star | .star & .pseudoElem(.before) | .star & .pseudoElem(.after)) % boxSizing(.inherit)

private let colorStyles =
  Class.pf.bgDark % backgroundColor(.other("#222"))
    <> Class.pf.bgWhite % backgroundColor(.other("#fff"))

private let codeStyles =
  Class.pf.code % (
    display(.block)
      <> backgroundColor(.other("#fafafa"))
      <> fontFamily(["monospace"])
      <> padding(all: .rem(2))
      <> overflow(x: .auto)
)
