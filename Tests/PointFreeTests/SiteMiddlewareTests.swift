import Html
import HtmlTestSupport
import HtmlPrettyPrint
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
@testable import HttpPipeline
import HttpPipelineTestSupport

class SiteMiddlewareTests: TestCase {
  func testWithoutWWW() {
    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "https://pointfree.co")!)) |> siteMiddleware
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "https://pointfree.co/episodes")!)) |> siteMiddleware
    )
  }

  func testWithoutHeroku() {
    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "https://pointfreeco.herokuapp.com")!)) |> siteMiddleware
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "https://pointfreeco.herokuapp.com/episodes")!)) |> siteMiddleware
    )
  }

  func testWithWWW() {
    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "https://www.pointfree.co")!)) |> siteMiddleware
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "https://www.pointfree.co/episodes")!)) |> siteMiddleware
    )
  }

  func testWithHttps() {
    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!)) |> siteMiddleware
    )

    assertSnapshot(
      matching: connection(from: URLRequest(url: URL(string: "http://www.pointfree.co/episodes")!)) |> siteMiddleware
    )
  }
}
