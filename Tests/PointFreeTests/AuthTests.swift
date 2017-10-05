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

  func testLogin_WithRedirect() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/login?redirect=%2Fhome")!)
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

  func testSecretHome_LoggedOut() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/home")!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }

  func testSecretHome_LoggedIn() {
    let sessionCookie = """
    8ec59947a58e227d0901ff96530b96c9b1e419ddd6781c6bacf97acdf784529d\
    bd79e710821f29430d5df62438730123873e105aacaa6374bd5db7f4e937432c\
    c9e0837bc28d511d5f8cde122ed8e18be42e2148cfb2ed1620bcd3418a6c93a6\
    a801ee0c463888e40a0838d0ebc94c7fc1e30e130423b84edfcdccbdde146731\
    45a2cf192aed0443ceee4ca5d283e12a2319a0a733c66f9f83514ec9622db1f8\
    f864744d82395e50e1e4f5f480d28af3182f782db235c45a9d68cb8876328f33
    """

    let request = URLRequest(url: URL(string: "http://localhost:8080/home")!)
      |> \.allHTTPHeaderFields .~ [
        "Cookie": "github_session=\(sessionCookie)",
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result)
  }
}
