import Either
import HttpPipeline
import Optics
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

Current = .mock
  |> \.database.fetchTeamInvite .~ const(pure(.some(.mock)))
  |> \.database.fetchUserById .~ const(pure(.some(.nonSubscriber)))

let teamInviteId = Database.TeamInvite.Id(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)

let req = request(to: .invite(.show(teamInviteId)), session: .loggedIn)
let result = siteMiddleware(connection(from: req)).perform()
let htmlString = String(
  data: result.data,
  encoding: .utf8
)!

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 376, height: 750))
webView.loadHTMLString(htmlString, baseURL: nil)
print(htmlString)

PlaygroundPage.current.liveView = webView
