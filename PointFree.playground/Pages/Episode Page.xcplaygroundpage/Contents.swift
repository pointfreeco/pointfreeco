import Logger
import Models
@testable import Database
import Tagged

let db = Database.Client(
  databaseUrl: "postgres://pointfreeco:@localhost:5432/pointfreeco_development",
  logger: Logger()
)
db.migrate().run.perform()

db.execute("truncate search_episodes;", []).run.perform()

typealias Token = Tagged<((), token: ()), String>

let allEpisodes = allPublicEpisodes + allPrivateEpisodes

allEpisodes
  .forEach { episode in
    let body = episode
      .transcriptBlocks.map { block in
        block.content
    }.joined(separator: "\n\n")

    db.execute("insert into search_episodes (title, content) values ($1, $2)", [episode.title, body])
      .run.perform()
}

1
2


//import HttpPipeline
//import PlaygroundSupport
//@testable import PointFree
//@testable import PointFreeTestSupport
//import WebKit
//
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
