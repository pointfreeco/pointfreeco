import Html
import HtmlTestSupport
import HtmlPrettyPrint
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
@testable import HttpPipeline
import HttpPipelineTestSupport

class LaunchSignupTests: TestCase {
  func testHome() {
    let request = URLRequest(url: URL(string: "/")!)

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testHome_SuccessfulSignup() {
    let request = URLRequest(url: URL(string: "/?success=true")!)

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testSignup() {
    var request = URLRequest(url: URL(string: "/launch-signup")!)
    request.httpMethod = "POST"
    request.httpBody = "email=hello@pointfree.co".data(using: .utf8)

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }
}
