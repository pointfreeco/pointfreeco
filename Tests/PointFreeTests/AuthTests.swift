import Html
import HtmlTestSupport
import HtmlPrettyPrint
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
@testable import HttpPipeline
import HttpPipelineTestSupport

class AuthTests: TestCase {
  func testAuth() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/github-auth?code=deadbeef")!)

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testLogin() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/login")!)

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testLogout() {
    var request = URLRequest(url: URL(string: "http://localhost:8080/logout")!)
    request.allHTTPHeaderFields = [
      "Cookie": "github_session=deadbeef; HttpOnly; Secure"
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }
}
