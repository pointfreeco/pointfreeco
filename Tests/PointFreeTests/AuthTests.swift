import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
  import WebKit
#endif

class AuthTests: TestCase {
  func testAuth() {
    // NB: It seems that the result of OpenSSL crypto on Linux is not deterministic, although its decryption
    //     is, so we cannot do snapshot tests on encrypted values :/ We will still run these tests on
    //     macOS at least.
    #if !os(Linux)
      let request = URLRequest(url: URL(string: "http://localhost:8080/github-auth?code=deadbeef")!)
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
      ]

      let conn = connection(from: request)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    #endif
  }

  func testAuth_WithFetchAuthTokenFailure() {
    AppEnvironment.with(\.gitHub.fetchAuthToken .~ (unit |> throwE >>> const)) {
      let request = URLRequest(url: URL(string: "http://localhost:8080/github-auth?code=deadbeef")!)
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
      ]

      let conn = connection(from: request)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testAuth_WithFetchUserFailure() {
    AppEnvironment.with(\.gitHub.fetchUser .~ (unit |> throwE >>> const)) {
      let request = URLRequest(url: URL(string: "http://localhost:8080/github-auth?code=deadbeef")!)
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
      ]

      let conn = connection(from: request)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testLogin() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/login")!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testLoginWithRedirect() {
    let request = router.request(
      for: .login(redirect: url(to: .episode(.right(42)))),
      base: URL(string: "http://localhost:8080")!
      )!
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
  }

  func testLogout() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/logout")!)
      |> \.allHTTPHeaderFields .~ [
        "Cookie": "github_session=deadbeef; HttpOnly; Secure",
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testSecretHome_LoggedOut() {
    let request = URLRequest(url: URL(string: "http://localhost:8080/home")!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }

  func testSecretHome_LoggedIn() {
    let sessionCookie = """
    e78e522838eb96eb96253b60dca1f4afc46adfc6f2e8f6700f03b2b7df656c6d\
    bacd144a80672f96a0a077faf1b63f0de0ba20e2c6bfaaa321853ab5bfb20e8d\
    e3212f5827ef1f51d4542ee4e6920dbcc991459f02f1bdb778782d4a88a7abce
    """

    let request = URLRequest(url: URL(string: "http://localhost:8080/home")!)
      |> \.allHTTPHeaderFields .~ [
        "Cookie": "pf_session=\(sessionCookie)",
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]

    let conn = connection(from: request)
    let result = conn |> siteMiddleware 

    assertSnapshot(matching: result.perform())
  }

  func testRegistrationEmail() {
    let emailNodes = registrationEmailView.view(.mock)

    assertSnapshot(matching: prettyPrint(nodes: emailNodes), pathExtension: "html")

    #if !os(Linux)
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        webView.loadHTMLString(render(emailNodes), baseURL: nil)

        assertSnapshot(matching: webView)
      }
    #endif
  }
}
