import HttpPipeline
import PlaygroundSupport
@testable import PointFree
@testable import PointFreeTestSupport
import WebKit

func tocCount(episode: Episode) -> Int {
  return episode.transcriptBlocks.reduce(0) { count, block in
    if case .title = block.type { return count + 1 }
    return count
  }
}

Current.episodes().count

(allPublicEpisodes + allPrivateEpisodes).sorted { lhs, rhs in
  tocCount(episode: lhs) < tocCount(episode: rhs)
}
  .forEach { ep in
    print(ep.title, tocCount(episode: ep))
}

1

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
