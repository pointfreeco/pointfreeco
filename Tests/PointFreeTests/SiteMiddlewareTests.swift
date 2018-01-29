import Html
import HtmlTestSupport
import HtmlPrettyPrint
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
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
      matching: connection(from: secureRequest("https://pointfree.co"))
        |> siteMiddleware
        |> Prelude.perform
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfree.co/episodes"))
        |> siteMiddleware
        |> Prelude.perform
    )
  }

  func testWithoutHeroku() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com"))
        |> siteMiddleware
        |> Prelude.perform
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com/episodes"))
        |> siteMiddleware
        |> Prelude.perform
    )
  }

  func testWithWWW() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://www.pointfree.co"))
        |> siteMiddleware
        |> Prelude.perform
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://www.pointfree.co"))
        |> siteMiddleware
        |> Prelude.perform
    )
  }

  func testWithHttps() {
    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!))
        |> siteMiddleware
        |> Prelude.perform,
      named: "1.redirects_to_https"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co/episodes")!))
        |> siteMiddleware
        |> Prelude.perform,
      named: "2.redirects_to_https"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080/")!))
        |> siteMiddleware
        |> Prelude.perform,
      named: "0.0.0.0_allowed"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://127.0.0.1:8080/")!))
        |> siteMiddleware
        |> Prelude.perform,
      named: "127.0.0.0_allowed"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://localhost:8080/")!))
        |> siteMiddleware
        |> Prelude.perform,
      named: "localhost_allowed"
    )
  }
}
