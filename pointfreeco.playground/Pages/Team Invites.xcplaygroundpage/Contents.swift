import Css
import CssReset
import Either
import Html
import HtmlCssSupport
import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit
import Optics
import SnapshotTesting

AppEnvironment.push(const(.mock))
AppEnvironment.push(\.database.fetchTeamInvite .~ const(throwE(unit)))

let teamInviteId = Database.TeamInvite.Id(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)

let htmlString = String(
  data: connection(from: unauthedRequest(to: .invite(.show(teamInviteId))))
    |> siteMiddleware
    |> Prelude.perform
    |> ^\.data,
  encoding: .utf8
)!

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 600, height: 750))
webView.loadHTMLString(htmlString, baseURL: nil)
print(htmlString)

PlaygroundPage.current.liveView = webView
