import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import WebKit

Current = .mock
let post = Current.blogPosts().first!

let req = request(to: .blog(.show(.right(post.id))), session: .loggedOut)
let result = siteMiddleware(connection(from: req)).perform().response.body
let htmlStr = String(decoding: result, as: UTF8.self)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 400, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)

PlaygroundPage.current.liveView = webView
