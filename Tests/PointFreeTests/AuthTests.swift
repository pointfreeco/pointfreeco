import HttpPipeline
import HttpPipelineTestSupport
import Optics
@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

class AuthTests: TestCase {
  func testAuth() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/github-auth?code=deadbeef")!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testAuth_WithFetchAuthTokenFailure() {
    AppEnvironment.with(fetchAuthToken: mockFetchAuthToken(result: .left(unit))) {
      let request = URLRequest(url: URL(string: "http://localhost:8080/github-auth?code=deadbeef")!)
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
      ]

      let conn = connection(from: request)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result)
    }
  }

  func testAuth_WithFetchUserFailure() {
    AppEnvironment.with(fetchGitHubUser: mockFetchGithubUser(result: .left(unit))) {
      let request = URLRequest(url: URL(string: "http://localhost:8080/github-auth?code=deadbeef")!)
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
      ]

      let conn = connection(from: request)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result)
    }
  }

  func testLogin() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/login")!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testLogout() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/logout")!)
      |> \.allHTTPHeaderFields .~ [
        "Cookie": "github_session=deadbeef; HttpOnly; Secure",
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }
}
