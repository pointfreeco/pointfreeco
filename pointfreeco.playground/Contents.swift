import Prelude
import HttpPipeline
import Html
import Css
import HtmlCssSupport
import CssReset
@testable import PointFree
import WebKit
import PlaygroundSupport

AppEnvironment.push(
  env: .init(
    airtableStuff: mockCreateRow(result: .left(unit))
  )
)

var request = URLRequest(url: URL(string: "/")!)
request.allHTTPHeaderFields = [
  "Authorization": "Basic " + "point:free".data(using: .utf8)!.base64EncodedString()
]

let conn = connection(from: request)
let result = conn |> siteMiddleware
let htmlStr = result.data.flatMap { String(data: $0,  encoding: .utf8) }

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
