import Css
import CssReset
import Html
import HtmlCssSupport
import HttpPipeline
import PlaygroundSupport
@testable import PointFree
import Prelude
import WebKit

AppEnvironment.push(
  env: .init(
    airtableStuff: mockCreateRow(result: .left(unit))
  )
)

var request = URLRequest(url: URL(string: "http://localhost/")!)

let conn = connection(from: request)
let result = conn |> siteMiddleware
let htmlStr = result.data
  .flatMap {
    String(data: $0,  encoding: .utf8)
}

let liveView: NSView
if let htmlStr = htmlStr {
  let webView = WKWebView(frame: .init(x: 0, y: 0, width: 375, height: 667))
  webView.loadHTMLString(htmlStr, baseURL: nil)
  liveView = webView  
} else {
  let responseLabel = NSTextField(frame: .init(x: 0, y: 0, width: 375, height: 667))
  responseLabel.stringValue = result.response.body.flatMap { String(data: $0, encoding: .utf8) } ?? ""
  liveView = responseLabel
}

PlaygroundPage.current.liveView = liveView
