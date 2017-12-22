import Either
import Html
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

PlaygroundPage.current.needsIndefiniteExecution = true

let htmlNodes = launchSignupConfirmationEmailView.view(unit)
let htmlString = render(htmlNodes, config: pretty)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 400, height: 750))
webView.loadHTMLString(htmlString, baseURL: nil)
print(htmlString)

PlaygroundPage.current.liveView = webView

sendEmail(
  to: [.init(unwrap: "saa@shoparc.com")],
  subject: "Invite email with image \(arc4random())",
  content: inj2(htmlNodes)
  )
  .run
  .perform()

