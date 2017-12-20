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
    case .black:  return Class.pf.components.buttons.black
    case .white:  return Class.pf.components.buttons.white
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
        mediaType: .image(.svg),
        alt: "",
        [
          `class`([Class.margin([.mobile: [.right: 1]])]),
          style(margin(bottom: .px(-4))),
          width(20),
          height(20)]
      ),
      span([.text(encode(text))])
    ]
  )
}
