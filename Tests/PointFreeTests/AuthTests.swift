import Either
import HttpPipeline
import Optics
@testable import PointFree
import Prelude
import SnapshotTesting
import XCTest

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
}
