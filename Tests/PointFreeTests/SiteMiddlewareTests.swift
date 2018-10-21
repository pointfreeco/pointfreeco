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
      matching: connection(from: secureRequest("https://pointfree.co"))
        |> siteMiddleware,
      with: .ioConn
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfree.co/episodes"))
        |> siteMiddleware,
      with: .ioConn
    )
  }

  func testWithoutHeroku() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com"))
        |> siteMiddleware,
      with: .ioConn
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://pointfreeco.herokuapp.com/episodes"))
        |> siteMiddleware,
      with: .ioConn
    )
  }

  func testWithWWW() {
    assertSnapshot(
      matching: connection(from: secureRequest("https://www.pointfree.co"))
        |> siteMiddleware,
      with: .ioConn
    )

    assertSnapshot(
      matching: connection(from: secureRequest("https://www.pointfree.co"))
        |> siteMiddleware,
      with: .ioConn
    )
  }

  func testWithHttps() {
    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!))
        |> siteMiddleware,
      with: .ioConn,
      named: "1.redirects_to_https"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co/episodes")!))
        |> siteMiddleware,
      with: .ioConn,
      named: "2.redirects_to_https"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080/")!))
        |> siteMiddleware,
      with: .ioConn,
      named: "0.0.0.0_allowed"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://127.0.0.1:8080/")!))
        |> siteMiddleware,
      with: .ioConn,
      named: "127.0.0.0_allowed"
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://localhost:8080/")!))
        |> siteMiddleware,
      with: .ioConn,
      named: "localhost_allowed"
    )
  }
}
