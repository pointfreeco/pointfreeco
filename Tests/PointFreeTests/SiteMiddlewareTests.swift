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
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record=true
  }

  func testWithoutWWW() {
    assertSnapshot(
      of: .ioConn,
      matching: connection(from: secureRequest("https://pointfree.co"))
        |> siteMiddleware
    )

    assertSnapshot(
      of: .ioConn,
      matching: connection(from: secureRequest("https://pointfree.co/episodes"))
        |> siteMiddleware
    )
  }

  func testWithoutHeroku() {
    assertSnapshot(
      of: .ioConn,
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com"))
        |> siteMiddleware
    )

    assertSnapshot(
      of: .ioConn,
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com/episodes"))
        |> siteMiddleware
    )
  }

  func testWithWWW() {
    assertSnapshot(
      of: .ioConn,
      matching: connection(from: secureRequest("https://www.pointfree.co"))
        |> siteMiddleware
    )

    assertSnapshot(
      of: .ioConn,
      matching: connection(from: secureRequest("https://www.pointfree.co"))
        |> siteMiddleware
    )
  }

  func testWithHttps() {
    assertSnapshot(
      of: .ioConn,
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!))
        |> siteMiddleware,
      named: "1.redirects_to_https"
    )

    assertSnapshot(
      of: .ioConn,
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co/episodes")!))
        |> siteMiddleware,
      named: "2.redirects_to_https"
    )

    assertSnapshot(
      of: .ioConn,
      matching: connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080/")!))
        |> siteMiddleware,
      named: "0.0.0.0_allowed"
    )

    assertSnapshot(
      of: .ioConn,
      matching: connection(from: URLRequest(url: URL(string: "http://127.0.0.1:8080/")!))
        |> siteMiddleware,
      named: "127.0.0.0_allowed"
    )

    assertSnapshot(
      of: .ioConn,
      matching: connection(from: URLRequest(url: URL(string: "http://localhost:8080/")!))
        |> siteMiddleware,
      named: "localhost_allowed"
    )
  }
}
