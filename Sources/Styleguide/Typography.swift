import Css
import Prelude

public let typography: Stylesheet =
  htmlStyles
    <> headerStyles
    <> fwBold % fontWeight(.w700)
    <> hCaps % (
      textTransform(.uppercase)
        <> letterSpacing(.pt(0.54))
)

private let htmlStyles = html % (
  fontSize(.px(16))
    <> fontFamily(["-apple-system", "Helvetica Neue", "Helvetica", "Arial", "sans-serif"])
    <> lineHeight(1.45)
)

private let h1: CssSelector = ".h1"
private let h2: CssSelector = ".h2"
private let h3: CssSelector = ".h3"
private let h4: CssSelector = ".h4"
private let h5: CssSelector = ".h5"
private let h6: CssSelector = ".h6"
private let fwBold: CssSelector = ".fw-bold"
private let hCaps: CssSelector = ".h-caps"

private let headerStyles =
  (h1 | h2 | h3 | h4 | h5) % lineHeight(1.2)
    <> h1 % fontSize(.rem(3.998))
    <> h2 % fontSize(.rem(2.827))
    <> h3 % fontSize(.rem(1.999))
    <> h4 % fontSize(.rem(1.414))
    <> h5 % fontSize(.rem(1.0))
    <> h6 % fontSize(.rem(0.707))
