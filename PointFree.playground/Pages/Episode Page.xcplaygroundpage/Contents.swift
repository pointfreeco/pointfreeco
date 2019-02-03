import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import WebKit

//Current = .mock
//
//let req = request(to: Route.episode(.right(1)))
//let result = siteMiddleware(connection(from: req)).perform()
//let htmlStr = String(decoding: result.response.body, as: UTF8.self)
//
//let webView = WKWebView(frame: .init(x: 0, y: 0, width: 832, height: 750))
//webView.loadHTMLString(htmlStr, baseURL: nil)
//print(htmlStr)
//
//PlaygroundPage.current.liveView = webView

try PointFree.bootstrap().run.perform()

//(1001...2000).forEach { idx in
//  Current.database.registerUser(
//    GitHub.UserEnvelope(
//      accessToken: GitHub.AccessToken(
//        accessToken: "deadbeef\(idx)"
//      ),
//      gitHubUser: GitHub.User(
//        id: GitHub.User.Id.init(rawValue: 123 + idx),
//        name: "Blob \(idx)"
//      )
//    ),
//    EmailAddress.init(rawValue: "test-\(idx)@pointfree.co")
//    ).run.perform()
//}
