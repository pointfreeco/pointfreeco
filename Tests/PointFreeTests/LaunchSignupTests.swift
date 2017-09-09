import Html
import HtmlTestSupport
import HtmlPrettyPrint
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
@testable import HttpPipeline
import HttpPipelineTestSupport

private let authorizationHeader = [
  "Authorization": "Basic " + "point:free".data(using: .utf8)!.base64EncodedString()
]

class LaunchSignupTests: TestCase {
  func testHome() {
    var request = URLRequest(url: URL(string: "/")!)
    request.allHTTPHeaderFields = authorizationHeader

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testHome_SuccessfulSignup() {
    var request = URLRequest(url: URL(string: "/?success=true")!)
    request.allHTTPHeaderFields = authorizationHeader

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testSignup() {
    var request = URLRequest(url: URL(string: "/launch-signup")!)
    request.httpMethod = "POST"
    request.httpBody = "email=hello@pointfree.co".data(using: .utf8)
    request.allHTTPHeaderFields = authorizationHeader

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }
}
