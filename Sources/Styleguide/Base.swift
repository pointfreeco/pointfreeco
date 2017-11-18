import Css
import Prelude

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
  ".bg-dark" % backgroundColor(.other("#222"))
    <> ".bg-white" % backgroundColor(.other("#fff"))

private let codeStyles =
  ".code" % (
    display(.block)
      <> backgroundColor(.other("#fafafa"))
      <> fontFamily(["monospace"])
      <> padding(all: .rem(2))
      <> overflow(x: .auto)
)
