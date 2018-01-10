import Css
import CssReset
import Foundation
import Html
import HtmlCssSupport
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

private let buttonStyle = input["type"=="submit"] % (
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
  let heroSignupSuccessStyle =  ".hero, .signup, .success" % columnStyle
  let successStyle = ".success" % responsiveSuccessStyle
  let htmlBodyHeroStyle = "html, body, .hero" % height(.pct(100))
  let logoStyle = ".logo" % margin(bottom: .px(40))

  return heroSignupSuccessStyle
    <> successStyle
    <> htmlBodyHeroStyle
    <> logoStyle
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

private let view: View<Bool?> = View { success in
  document(
    [
      html(
        [
          head(
            [
              title("Point-Free — A weekly video series on Swift and functional programming."),
              style(reset <> stylesheet),
              meta(viewport: .width(.deviceWidth), .initialScale(1))
            ]
          ),
          body(
            success == .some(true)
              ? [ successSectionNode, headerNode ]
              : [ headerNode, defaultSectionNode ]
          )
        ]
      )
    ]
  )
}

private let headerNode = header(
  [ `class`("hero") ],
  [
    div(
      [ `class`("container") ],
      [
        a(
          [href("/")],
          [img(base64: logoSvgBase64, mediaType: .image(.svg), alt: "Point Free", [`class`("logo")])]
        ),
        h1(["A new weekly Swift video series exploring functional programming and more."]),
        h2(["Coming really, really soon."]),
        footer(
          [
            p(
              [
                "Made by ",
                a(
                  [href(twitterUrl(to: .mbrandonw)), target(.blank)],
                  ["@mbrandonw"]
                ),
                " and ",
                a(
                  [href(twitterUrl(to: .stephencelis)), target(.blank)],
                  ["@stephencelis"]
                ),
                "."
              ]
            ),
            p(
              [
                "Built with ",
                a(
                  [href("https://swift.org"), target(.blank)],
                  ["Swift"]
                ),
                " and open-sourced on ",
                a(
                  [href(gitHubUrl(to: .repo(.pointfreeco))), target(.blank)],
                  ["GitHub"]
                ),
              ]
            )
          ]
        )
      ]
    )
  ]
)

private let successSectionNode = section(
  [`class`("success"), style("background-color: #79f2b0")],
  [
    div(
      [ `class`("container") ],
      [
        img(base64: checkmarkSvgBase64, mediaType: .image(.svg), alt: "", []),
        h1(["We'll be in touch."]),
        p(["Help spread the word about Point-Free!"]),
        twitterLink,
        facebookLink
      ]
    )
  ]
)

private let defaultSectionNode = section(
  [`class`("signup")],
  [
    form(
      [`class`("container"), action(path(to: .launchSignup(.init(unwrap: "")))), method(.post)],
      [
        h3(["Get notified when we launch"]),
        label([`for`("email")], ["Email address"] ),
        input(
          [
            type(.email),
            placeholder("hi@example.com"),
            name("email"),
            id("email")
          ]
        ),
        input(
          [
            type(.submit),
            value("Sign up")
          ]
        )
      ]
    )
  ]
)

private let twitterShareHref = { () -> String in
  var components = URLComponents(string: "https://twitter.com/intent/tweet")!
  components.queryItems = [
    URLQueryItem(name: "text", value: "A new weekly video series on Swift and functional programming is coming soon!"),
    URLQueryItem(name: "url", value: "http://www.pointfree.co"),
    URLQueryItem(name: "via", value: "pointfreeco"),
  ]
  return components.string!
}()

private let twitterLink = a(
  [ href(twitterShareHref), target(.blank), `class`("social-btn") ],
  [ img(base64: twitterIconSvgBase64, mediaType: .image(.svg), alt: "Share on Twitter", []) ]
)

private let facebookShareHref = "https://www.facebook.com/sharer/sharer.php?u=http%3A//www.pointfree.co"

private let facebookLink = a(
  [ href(facebookShareHref), target(.blank), `class`("social-btn") ],
  [ img(base64: facebookIconSvgBase64, mediaType: .image(.svg), alt: "Share on Facebook", []) ]
)

let launchSignupView =
  metaLayout(view.map(addGoogleAnalytics))
    .contramap(
      Metadata.create(
        description: "A weekly video series on Swift and functional programming. Each week we discuss a topic and then ask: “What’s the point!?”",
        image: "https://s3.amazonaws.com/pointfree.co/twitter-card-large.png",
        title: "Point-Free",
        twitterCard: .summaryLargeImage,
        twitterSite: "@pointfreeco",
        type: .website,
        url: "https://www.pointfree.co"
      )
)
