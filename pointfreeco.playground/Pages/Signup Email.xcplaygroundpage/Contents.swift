import Css
import Either
import Html
import HtmlCssSupport
@testable import PointFree
import PointFreeTestSupport
import Prelude
import HtmlPrettyPrint
import PlaygroundSupport
@testable import Styleguide
import WebKit
PlaygroundPage.current.needsIndefiniteExecution = true

let emailNodes = launchSignupConfirmationEmailView.view(unit)

print(prettyPrint(nodes: emailNodes))
print("✅")

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 600, height: 800))
webView.loadHTMLString(render(emailNodes), baseURL: nil)
PlaygroundPage.current.liveView = webView
