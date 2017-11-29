import Css
import CssReset
import Html
import HtmlCssSupport
import PlaygroundSupport
import Prelude
@testable import Styleguide
import WebKit

let sampleDocument = document([
  html([
    head([
      style(renderedNormalizeCss),
      style(styleguide),
      ]),

    body([
      gridRow([
        gridColumn(sizes: [.xs: 12, .md: 8], [
          div([`class`([Class.padding.all(4)])], [
            h1([`class`([Class.h1])], ["About Us"]),
            p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]),
            p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]),
            p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]),
            p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]),
            p(["Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."])

            ])
          ]),

        gridColumn(sizes: [.xs: 12, .md: 4], [
          div([`class`([Class.padding.top(4), Class.padding.right(4)])], [
            "menu"
            ])
          ])
        ])
      ])
    ])
  ])

let htmlString = render(sampleDocument, config: pretty)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 832, height: 700))
webView.loadHTMLString(htmlString, baseURL: nil)
PlaygroundPage.current.liveView = webView

