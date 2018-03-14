import Either
import Html
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

PlaygroundPage.current.needsIndefiniteExecution = true

let htmlNodes = freeEpisodeEmail.view((typeSafeHtml, .mock))
let htmlString = render(htmlNodes, config: compact)

let webView = WKWebView(
  frame: .init(x: 0, y: 0, width: 400, height: 750)
)
webView.loadHTMLString(htmlString, baseURL: nil)
print(htmlString)

PlaygroundPage.current.liveView = webView

sendEmail(
  to: [.init(unwrap: "mbw234@gmail.com")],
  subject: "Email test: \(arc4random())",
  unsubscribeData: (.init(unwrap: UUID()), .newEpisode),
  content: inj2(htmlNodes)
  )
  .run
  .perform()
