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

  func testRegister() {
    AppEnvironment.with(\.database .~ .live) {
      let result = connection(
        from: request(to: .gitHubCallback(code: "deabeef", redirect: "/"), session: .loggedOut)
        )
        |> siteMiddleware
        |> Prelude.perform
      assertSnapshot(matching: result)

      let registeredUser = AppEnvironment.current.database
        .fetchUserByGitHub(GitHub.UserEnvelope.mock.gitHubUser.id)
        .run
        .perform()
        .right!!

      XCTAssertEqual(1, registeredUser.episodeCreditCount)
    }
  }

  func testAuth() {
    let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))

    let conn = connection(from: auth)
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
  }
  
  func testAuth_WithFetchAuthTokenFailure() {
    AppEnvironment.with(\.gitHub.fetchAuthToken .~ (unit |> throwE >>> const)) {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))

      let conn = connection(from: auth)
      let result = conn |> siteMiddleware
      
      assertSnapshot(matching: result.perform())
    }
  }
  
  func testAuth_WithFetchUserFailure() {
    AppEnvironment.with(\.gitHub.fetchUser .~ (unit |> throwE >>> const)) {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))

      let conn = connection(from: auth)
      let result = conn |> siteMiddleware
      
      assertSnapshot(matching: result.perform())
    }
  }

  func testLogin() {
    let login = request(to: .login(redirect: nil))

    let conn = connection(from: login)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())
  }
  
  func testLogin_AlreadyLoggedIn() {
    AppEnvironment.with(\.database .~ .mock) {
      let login = request(to: .login(redirect: nil), session: .loggedIn)
      
      let conn = connection(from: login)
      let result = conn |> siteMiddleware
      
      assertSnapshot(matching: result.perform())
    }
  }

  func testLoginWithRedirect() {
    let login = request(to: .login(redirect: url(to: .episode(.right(42)))), session: .loggedIn)

    let conn = connection(from: login)
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
  }
  
  func testLogout() {
    let conn = connection(from: request(to: .logout))
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
  }
  
  func testHome_LoggedOut() {
    let conn = connection(from: request(to: .home, session: .loggedOut))
    let result = conn |> siteMiddleware
    
    assertSnapshot(matching: result.perform())
  }
  
  func testHome_LoggedIn() {
    let conn = connection(from: request(to: .home, session: .loggedIn))
    let result = conn |> siteMiddleware 
    
    assertSnapshot(matching: result.perform())
  }
}
