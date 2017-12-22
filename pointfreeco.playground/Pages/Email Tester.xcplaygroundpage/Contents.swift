import Either
import Html
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

PlaygroundPage.current.needsIndefiniteExecution = true

//AppEnvironment.push(const(.mock))

let htmlNodes = teamInviteEmailView.view((.mock, .mock))
let htmlString = render(htmlNodes, config: pretty)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 400, height: 750))
webView.loadHTMLString(htmlString, baseURL: nil)
print(htmlString)

PlaygroundPage.current.liveView = webView

sendEmail(
  to: [EmailAddress(unwrap: "saa@shoparc.com")],
  subject: "Foo 7",
  content: inj2(htmlNodes)
  )
  .run
  .perform()
//
