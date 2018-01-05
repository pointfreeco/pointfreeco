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
    let request = URLRequest(url: URL(string: "http://localhost:8080/github-auth?code=deadbeef")!)
      |> \.allHTTPHeaderFields .~ [
        "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
    ]
    
    let conn = connection(from: request)
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
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
      |> \.httpMethod .~ "GET"
    
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
    let conn = connection(from: request(to: .secretHome, session: .loggedIn))
    let result = conn |> siteMiddleware 
    
    assertSnapshot(matching: result.perform())
  }
}
