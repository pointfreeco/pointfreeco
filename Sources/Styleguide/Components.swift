import Css
import FunctionalCss
import HtmlCssSupport
import Foundation
import Html
import Prelude

public enum GitHubLinkType {
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

public func gitHubLink(text: String, type: GitHubLinkType, href: String?) -> Node {
  return a(
    [
      Html.href(href ?? ""),
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

public func twitterShareLink(text: String, url: String, via: String? = nil) -> Node {

  var components = URLComponents(string: "https://twitter.com/intent/tweet")!
  components.queryItems = [
    URLQueryItem(name: "text", value: text),
    URLQueryItem(name: "url", value: url),
    via.map { URLQueryItem(name: "via", value: $0) }
    ]
    .compactMap { $0 }
  let tweetHref = components.url?.absoluteString ?? ""

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
        [
          style(twitterButtonTextStyle),
          `class`([twitterButtonTextClass])
        ],
        ["Tweet"]
      )
    ]
  )
}

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

private let twitterLogoSvg = Data(
  """
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 72 72"><path fill="none" d="M0 0h72v72H0z"/><path class="icon" fill="#fff" d="M68.812 15.14c-2.348 1.04-4.87 1.744-7.52 2.06 2.704-1.62 4.78-4.186 5.757-7.243-2.53 1.5-5.33 2.592-8.314 3.176C56.35 10.59 52.948 9 49.182 9c-7.23 0-13.092 5.86-13.092 13.093 0 1.026.118 2.02.338 2.98C25.543 24.527 15.9 19.318 9.44 11.396c-1.125 1.936-1.77 4.184-1.77 6.58 0 4.543 2.312 8.552 5.824 10.9-2.146-.07-4.165-.658-5.93-1.64-.002.056-.002.11-.002.163 0 6.345 4.513 11.638 10.504 12.84-1.1.298-2.256.457-3.45.457-.845 0-1.666-.078-2.464-.23 1.667 5.2 6.5 8.985 12.23 9.09-4.482 3.51-10.13 5.605-16.26 5.605-1.055 0-2.096-.06-3.122-.184 5.794 3.717 12.676 5.882 20.067 5.882 24.083 0 37.25-19.95 37.25-37.25 0-.565-.013-1.133-.038-1.693 2.558-1.847 4.778-4.15 6.532-6.774z"/></svg>
  """.utf8
  )
  .base64EncodedString()

public func gitHubSvgBase64(fill: String) -> String {
  return Data("""
    <svg fill="\(fill)" aria-labelledby="simpleicons-github-icon" role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title id="simpleicons-github-icon">GitHub icon</title><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>
    """.utf8).base64EncodedString()
}
