import Css
import Prelude

public let typography: Stylesheet =
  bodyStyles
    <> headerStyles
    <> paragraphStyles
    <> strongStyles
    <> hCaps % (
      textTransform(.uppercase)
        <> letterSpacing(.pt(0.54))
    )
    <> fwBold % fontWeight(.w700)

private let bodyStyles = body % (
  fontSize(.px(16))
    <> fontFamily(["-apple-system", "Helvetica Neue", "Helvetica", "Arial", "sans-serif"])
    <> lineHeight(1.45)
)

private let paragraphStyles = p % margin(topBottom: .rem(1))

private let strongStyles = strong % fontWeight(.w700)

private let headerStyles =
  (h1 | h2 | h3 | h4 | h5 | h6) % (
    margin(topBottom: .rem(1))
      <> fontWeight(.w700)
    )
    <> h1Class % fontSize(.rem(3.998))
    <> h2Class % fontSize(.rem(2.827))
    <> h3Class % fontSize(.rem(1.999))
    <> h4Class % fontSize(.rem(1.414))
    <> h5Class % fontSize(.rem(1.0))
    <> h6Class % fontSize(.rem(0.707))
    <> h1Class % lineHeight(1.15)
    <> (h2Class | h3Class) % lineHeight(1.25)
    <> (h4Class | h5Class) % lineHeight(1.35)

private let h1Class: CssSelector = ".h1"
private let h2Class: CssSelector = ".h2"
private let h3Class: CssSelector = ".h3"
private let h4Class: CssSelector = ".h4"
private let h5Class: CssSelector = ".h5"
private let h6Class: CssSelector = ".h6"
private let fwBold: CssSelector = ".fw-bold"
private let hCaps: CssSelector = ".h-caps"
