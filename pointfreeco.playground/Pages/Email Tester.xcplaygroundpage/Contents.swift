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

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 680, height: 750))
webView.loadHTMLString(htmlString, baseURL: nil)
print(htmlString)

PlaygroundPage.current.liveView = webView

//sendEmail(
//  to: [EmailAddress(unwrap: "mbw234@gmail.com")],
//  subject: "Foo 5",
//  content: inj2(htmlNodes)
//  )
//  .run
//  .perform()


