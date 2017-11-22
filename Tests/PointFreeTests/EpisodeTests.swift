import Html
import HtmlTestSupport
import HtmlPrettyPrint
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
@testable import HttpPipeline
import HttpPipelineTestSupport
import Optics

class EpisodeTests: TestCase {
//  func testHome() {
//    let request = URLRequest(url: URL(string: "https://localhost:8080/episodes/ep6-the-algebra-of-predicates-and-sorting-functions")!)
//      |> \.allHTTPHeaderFields .~ [
//        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
//    ]
//
//    let conn = connection(from: request)
//    let result = conn |> siteMiddleware
//
//    assertSnapshot(matching: result.perform(), record: true)
//    assertWebPageSnapshot(matching: result.perform(), record: true)
//  }

  func testEpisodeHtml() {
    assertSnapshot(matching: prettyPrint(nodes: episodeView.view(episodes.last!)), pathExtension: "html", record: true)
  }
}
