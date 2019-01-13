import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Optics
import Styleguide
import Prelude

enum GitHubLinkType {
  case black
  case white

  fileprivate var iconFillColor: String {
    switch self {
    case .white:  return "#000"
    case .black:  return "#fff"
    }
  }

  fileprivate var buttonClass: CssSelector {
    switch self {
    case .black:  return Class.pf.components.button(color: .black)
    case .white:  return Class.pf.components.button(color: .white)
    }
  }
}

func gitHubLink(text: String, type: GitHubLinkType, redirectRoute: Route?) -> Node {
  return gitHubLink(text: text, type: type, redirect: redirectRoute.map(url(to:)))
}

func gitHubLink(text: String, type: GitHubLinkType, redirect: String?) -> Node {
  return a(
    [
      href(path(to: .login(redirect: redirect))),
      `class`([type.buttonClass])
    ],
    [
      img(
        base64: gitHubSvgBase64(fill: type.iconFillColor),
        type: .image(.svg),
        alt: "",
        [
          `class`([Class.margin([.mobile: [.right: 1]])]),
          style(margin(bottom: .px(-4))),
          width(20),
          height(20)
        ]
      ),
      span([.text(text)])
    ]
  )
}

func twitterShareLink(text: String, url: String, via: String? = nil) -> Node {

  let tweetHref = (
    URLComponents(string: "https://twitter.com/intent/tweet")!
      |> (\URLComponents.queryItems) .~ [
        URLQueryItem(name: "text", value: text),
        URLQueryItem(name: "url", value: url),
        via.map { URLQueryItem(name: "via", value: $0) }
        ].compactMap(id)
      |> ^\.url?.absoluteString
    )
    ?? ""

  return a(
    [
      href(tweetHref),
      onclick(unsafe: """
      window.open(
        "\(tweetHref)",
        "newwindow",
        "width=500,height=500"
      );
      """),
      target(.blank),
      rel(.init(rawValue: "noopener noreferrer")),
      `class`([twitterLinkButtonClass]),
      style(twitterLinkButtonStyle)
    ],
    [
      img(
        base64: twitterLogoSvg,
        type: .image(.svg),
        alt: "",
        [
          style(twitterButtonIconStyle),
          `class`([twitterButtonIconClass])
        ]
      ),
      span(
        [style(twitterButtonTextStyle), `class`([twitterButtonTextClass])],
        ["Tweet"]
      )
    ]
  )
}

private let twitterLogoSvg = Data(
  """
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 72 72"><path fill="none" d="M0 0h72v72H0z"/><path class="icon" fill="#fff" d="M68.812 15.14c-2.348 1.04-4.87 1.744-7.52 2.06 2.704-1.62 4.78-4.186 5.757-7.243-2.53 1.5-5.33 2.592-8.314 3.176C56.35 10.59 52.948 9 49.182 9c-7.23 0-13.092 5.86-13.092 13.093 0 1.026.118 2.02.338 2.98C25.543 24.527 15.9 19.318 9.44 11.396c-1.125 1.936-1.77 4.184-1.77 6.58 0 4.543 2.312 8.552 5.824 10.9-2.146-.07-4.165-.658-5.93-1.64-.002.056-.002.11-.002.163 0 6.345 4.513 11.638 10.504 12.84-1.1.298-2.256.457-3.45.457-.845 0-1.666-.078-2.464-.23 1.667 5.2 6.5 8.985 12.23 9.09-4.482 3.51-10.13 5.605-16.26 5.605-1.055 0-2.096-.06-3.122-.184 5.794 3.717 12.676 5.882 20.067 5.882 24.083 0 37.25-19.95 37.25-37.25 0-.565-.013-1.133-.038-1.693 2.558-1.847 4.778-4.15 6.532-6.774z"/></svg>
  """.utf8
  )
  .base64EncodedString()

private let twitterLinkButtonClass: CssSelector =
  Class.type.lineHeight(1)
    | Class.position.relative
    | Class.type.medium
    | Class.display.inlineBlock
    | Class.align.top

private let twitterLinkButtonStyle: Stylesheet =
  boxSizing(.borderBox)
    <> color(.white)
    <> backgroundColor(.rgba(12, 122, 191, 1))
    <> height(.px(20))
    <> padding(top: .px(1), right: .px(8), bottom: .px(1), left: .px(6))
    <> borderRadius(all: .px(3))
    <> fontSize(.px(16))

private let twitterButtonTextClass: CssSelector =
  Class.display.inlineBlock
    | Class.align.top

private let twitterButtonTextStyle: Stylesheet =
  fontFamily(["'Helvetica Neue',Arial,sans-serif"])
    <> fontSize(.px(11))
    <> lineHeight(.px(18))
    <> margin(left: .px(3))

private let twitterButtonIconClass: CssSelector =
  Class.position.relative
    | Class.display.inlineBlock

private let twitterButtonIconStyle: Stylesheet =
  width(.px(14))
    <> height(.px(14))
    <> fontSize(.px(16))
    <> top(.px(1))
