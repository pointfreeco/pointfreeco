import Css
import Prelude

let baseFontStyle = fontFamily(["-apple-system", "Helvetica Neue", "Helvetica", "Arial", "sans-serif"])

let logoStyle = ".logo" % (
  width(.pct(100))
    <> margin(bottom: .px(40))
    <> objectFit(.contain)
)

let heroHeadingStyle = baseFontStyle
  <> lineHeight(1.4)
  <> fontSize(.px(22))

let h1Style = h1 % (
  heroHeadingStyle
    <> color(.white(0, 1))
    <> padding(bottom: .px(16))
)

let h2Style = h2 % (
  heroHeadingStyle
    <> color(.white(0.6, 1))
    <> padding(bottom: .px(120))
)

let h3Style = h3 % (
  baseFontStyle
    <> fontSize(.px(20))
    <> fontWeight(.w600)
    <> lineHeight(1.29)
    <> margin(bottom: .px(20))
)

let baseInputStyle =
  borderWidth(all: .px(1))
    <> borderColor(all: .white(0, 0.25))
    <> borderStyle(all: .solid)
    <> borderRadius(all: .px(4))
    <> boxShadow(
      stroke: .inset,
      hShadow: 0,
      vShadow: .px(1),
      blurRadius: .px(2),
      spreadRadius: 0,
      color: .rgba(0, 0, 0, 0.25)
    )
    <> outlineStyle(all: .none)
    <> baseFontStyle
    <> fontSize(.px(14))
    <> color(.white(0, 1))
    <> boxSizing(.borderBox)

let labelStyle = label % (
  baseFontStyle
    <> fontSize(.px(14))
    <> fontWeight(.w700)
    <> display(.block)
    <> margin(bottom: .px(12))
)

let focusInputStyle =
  borderColor(all: #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1))

let inputStyle = input["type"=="email"] % (
  baseInputStyle
    <> width(.pct(100))
    <> padding(topBottom: .px(10), leftRight: .px(10))
    <> .pseudo(.focus) & (
      focusInputStyle
  )
)

let buttonStyle = input["type"=="submit"] % (
  baseInputStyle
    <> borderRadius(all: .px(6))
    <> borderWidth(all: 0)
    <> margin(top: .px(24))
    <> color(.white(1))
    <> background(Color.white(0))
    <> padding(topBottom: 0, leftRight: .px(40))
    <> lineHeight(.px(36))
    <> height(.px(36))
    <> textTransform(.uppercase)
    <> appearance(.none)
    <> fontSize(.px(12))
    <> fontWeight(.w700)
)

let containerStyle = ".container" % (
  padding(topBottom: .px(40), leftRight: .px(30))
    <> maxWidth(.px(435))
    <> margin(topBottom: 0, leftRight: .auto)
    <> boxSizing(.borderBox)
)

let heroStyle = ".hero" % (
  background(Color.white(1))
    <> (footer ** p) % (
      baseFontStyle
        <> color(.white(0,0.3))
        <> fontSize(.px(12))
        <> lineHeight(1.4)
    )
    <> (footer ** a) % (
      fontWeight(.w600)
        // TODO: add css `text-decoration: none`
        <> color(.white(0,0.6))
    )
    <> ".container" % (
      padding(top: .px(80))
  )
)

let responsiveHeroContainer = ".hero .container" % (
  height(.px(420))
    <> position(.absolute)
    <> top(.pct(50))
    <> left(0)
    <> right (0)
    <> margin(top: .px(-(210+140)))
)

let responsiveSuccessContainer = ".success .container" % (
  position(.absolute)
    <> top(.pct(50))
    <> left(0)
    <> right (0)
    <> margin(top: .px(-200))
)

let responsiveH1Style = h1 % fontSize(.px(19))
let responsiveH2Style = h2 % fontSize(.px(19))

let responsiveHeroStyle = responsiveHeroContainer
  <> ".hero" % position(.relative)
  <> responsiveH1Style
  <> responsiveH2Style

let columnStyle = width(.pct(50))
  <> display(.inlineBlock)
  <> verticalAlign(.middle)

let responsiveSuccessStyle =
  position(.absolute)
    <> top(0)
    <> right(0)
    <> bottom(0)

let responsiveStyle = queryOnly(screen, [minWidth(.px(800))]) {
  ".hero, .signup, .success" % (
    columnStyle
    )
    <> ".success" % (
      responsiveSuccessStyle
    )
    <> "html, body, .hero" % (
      height(.pct(100))
    )
    <> ".logo" % (
      margin(bottom: .px(40))
    )
    <> responsiveHeroStyle
    <> responsiveSuccessContainer
}

let signupStyle = ".signup" % (
  padding(bottom: .px(40))
)

let successStyle = ".success" % (
  textAlign(.center)
    <> ".container" % (
      padding(top: .px(120))
    )
    <> p % (
      baseFontStyle
        <> fontSize(.px(13))
        <> margin(top: .px(120), right: .auto, bottom: .px(24), left: .auto)
  )
)

let socialCss = ".social-btn" % (
  display(.inlineBlock)
    <> verticalAlign(.middle)
    <> lineHeight(.px(32))
    <> textAlign(.center)
    <> width(.px(82))
    <> height(.px(32))
    <> background(Color.white(1, 1))
    <> borderRadius(all: .px(3))
    <> margin(topBottom: 0, leftRight: .px(5))
    <> img % (
      verticalAlign(.middle)
  )
)

let stylesheet = inputStyle
  <> labelStyle
  <> buttonStyle
  <> containerStyle
  <> heroStyle
  <> logoStyle
  <> signupStyle
  <> successStyle
  <> h1Style
  <> h2Style
  <> h3Style
  <> body % (
    background(Color.white(0.98, 1))
  )
  <> responsiveStyle
  <> socialCss
