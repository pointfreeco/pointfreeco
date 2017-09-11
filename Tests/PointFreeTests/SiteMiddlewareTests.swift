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

private func secureRequest(_ urlString: String) -> URLRequest {
  return URLRequest(url: URL(string: urlString)!)
    |> \.allHTTPHeaderFields .~ ["X-Forwarded-Proto": "https"]
}

class SiteMiddlewareTests: TestCase {
  func testWithoutWWW() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfree.co")) |> siteMiddleware
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfree.co/episodes")) |> siteMiddleware
    )
  }

  func testWithoutHeroku() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com")) |> siteMiddleware
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com/episodes")) |> siteMiddleware
    )
  }

  func testWithWWW() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://www.pointfree.co")) |> siteMiddleware
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://www.pointfree.co/episodes")) |> siteMiddleware
    )
  }

  func testWithHttps() {
    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!)) |> siteMiddleware,
      named: "1.redirects_to_https"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co/episodes")!)) |> siteMiddleware,
      named: "2.redirects_to_https"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080/")!)) |> siteMiddleware,
      named: "0.0.0.0_allowed"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://127.0.0.1:8080/")!)) |> siteMiddleware,
      named: "127.0.0.0_allowed"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://localhost:8080/")!)) |> siteMiddleware,
      named: "localhost_allowed"
    )
  }
}
