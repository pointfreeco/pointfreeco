import Either
import HttpPipeline
import Models
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import Prelude
import WebKit

Current = .mock
Current.database.fetchTeamInvite = const(pure(.some(.mock)))
Current.database.fetchUserById = const(pure(.some(.nonSubscriber)))

let teamInviteId = TeamInvite.ID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!

let req = request(to: .invite(.show(teamInviteId)), session: .loggedIn)
let result = siteMiddleware(connection(from: req)).perform()
let htmlStr = String(decoding: result.response.body, as: UTF8.self)

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 376, height: 750))
webView.loadHTMLString(htmlStr, baseURL: nil)
print(htmlStr)

PlaygroundPage.current.liveView = webView
