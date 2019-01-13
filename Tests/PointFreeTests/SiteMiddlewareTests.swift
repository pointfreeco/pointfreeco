import Html
import HtmlSnapshotTesting
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
      matching: connection(from: secureRequest("https://pointfree.co"))
        |> siteMiddleware,
      as: .ioConn
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfree.co/episodes"))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testWithoutHeroku() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com"))
        |> siteMiddleware,
      as: .ioConn
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com/episodes"))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testWithWWW() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://www.pointfree.co"))
        |> siteMiddleware,
      as: .ioConn
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://www.pointfree.co"))
        |> siteMiddleware,
      as: .ioConn
    )
  }

  func testWithHttps() {
    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!))
        |> siteMiddleware,
      as: .ioConn,
      named: "1.redirects_to_https"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co/episodes")!))
        |> siteMiddleware,
      as: .ioConn,
      named: "2.redirects_to_https"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080/")!))
        |> siteMiddleware,
      as: .ioConn,
      named: "0.0.0.0_allowed"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://127.0.0.1:8080/")!))
        |> siteMiddleware,
      as: .ioConn,
      named: "127.0.0.0_allowed"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://localhost:8080/")!))
        |> siteMiddleware,
      as: .ioConn,
      named: "localhost_allowed"
    )
  }
}
