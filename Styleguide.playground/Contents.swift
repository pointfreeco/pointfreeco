import Css
import CssReset
import CssTestSupport
import Html
import HtmlCssSupport
import PlaygroundSupport
import Prelude
import SnapshotTesting
import Styleguide
import WebKit

let testStyles =
  ".grid" % (
    fontSize(.px(10))
    )
    <> ".col" % (
      background(Color.white(0.9, 1))
        <> borderWidth(all: .pt(1))
        <> borderStyle(all: .solid)
        <> borderColor(all: .white(0.75, 1))
        <> borderRadius(all: .px(6))
        <> color(.white(0.5, 1))
        <> padding(all: .px(5))
        <> minHeight(.px(30))
        <> textAlign(.center)
    )
    <> (".col" ** ".col") % (
      color(.white(0.9, 1))
        <> background(Color.white(0.25, 1))
        <> borderColor(all: .white(0, 1))
)

let columns12 =
  div([`class`([gridClass, paddingBottom1])],
      (1...12).map({
        div([`class`([colClass, col1Class])], [.text(encode("\($0)"))])
      })
)
let columns6 =
  div([`class`([gridClass, paddingBottom1])],
      (1...6).map({
        div([`class`([colClass, col2Class])], [.text(encode("\($0)"))])
      })
)

private let columns4 =
  div([`class`([gridClass, paddingBottom1])], [
    div([`class`([colClass, col3Class])], ["1"]),
    div([`class`([colClass, col3Class])], ["2"]),
    div([`class`([colClass, col3Class])], ["3"]),
    div([`class`([colClass, col3Class])], ["4"]),
    ])

private let columns3 =
  div([`class`([gridClass, paddingBottom1])], [
    div([`class`([colClass, col4Class])], ["1"]),
    div([`class`([colClass, col4Class])], ["2"]),
    div([`class`([colClass, col4Class])], ["3"]),
    ])

private let columns2 =
  div([`class`([gridClass, paddingBottom1])], [
    div([`class`([colClass, col6Class])], ["1"]),
    div([`class`([colClass, col6Class])], ["2"]),
    ])

private let nested =
  div([`class`([gridClass, paddingBottom1])], [
    div([`class`([colClass, col6Class])], [columns3]),
    div([`class`([colClass, col6Class])], [columns6]),
    ])

private let doc = document([
  html([
    head([
      style(
        reset
          <> testStyles
          <> grid
          <> spacing)
      ]),
    body([`class`([padding1])], [
      columns4,
      columns3,
      columns12,
      columns6,
      columns2,
      nested
      ])
    ])
  ])

let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
let htmlString = render(doc)
dump(htmlString)
webView.loadHTMLString(htmlString, baseURL: nil)
PlaygroundPage.current.liveView = webView
