import Css
import Prelude

public let typography: Stylesheet =
  htmlStyles
    <> headerStyles
    <> fwBold
    <> hCaps

private let htmlStyles = html % (
  fontSize(.px(16))
    <> fontFamily(["-apple-system", "Helvetica Neue", "Helvetica", "Arial", "sans-serif"])
    <> lineHeight(1.45)
)

private let headerStyles =
  (".h1" | ".h2" | ".h3" | ".h4" | ".h5") % lineHeight(1.2)
    <> ".h1" % fontSize(.rem(3.998))
    <> ".h2" % fontSize(.rem(2.827))
    <> ".h3" % fontSize(.rem(1.999))
    <> ".h4" % fontSize(.rem(1.414))
    <> ".h5" % fontSize(.rem(1.0))
    <> ".h6" % fontSize(.rem(0.707))

private let fwBold = ".fw-bold" % fontWeight(.w700)

private let hCaps = ".h-caps" % (
  textTransform(.uppercase)
    <> letterSpacing(.pt(0.54))
)
