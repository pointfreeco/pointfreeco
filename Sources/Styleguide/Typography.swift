import Css
import Prelude

public let headers: Stylesheet =
  (h1 | ".h1") % (fontSize(.rem(1.5)))
    <> (h2 | ".h2") % (fontSize(.rem(1.25)))
    <> (h3 | ".h3") % (fontSize(.rem(1.1875)))
    <> (h4 | ".h4") % (fontSize(.rem(1.125)))
    <> (h5 | ".h5") % (fontSize(.rem(1.0625)))
    <> (h6 | ".h6") % (fontSize(.rem(1)))
    <> (h1 | h2 | h3 | h4 | h5 | h6 | ".h1" | ".h2" | ".h3" | ".h4" | ".h5" | ".h6") % (
      color(.rgb(0x48, 0x48, 0x48))
        <> fontFamily(["Open Sans", "Helvetica Neue", "Arial", "Helvetica", "Verdana", "sans-serif"])
        <> fontWeight(.w600)
        <> lineHeight(1.4)
        <> margin(top: 0, bottom: .em(0.5))
)
