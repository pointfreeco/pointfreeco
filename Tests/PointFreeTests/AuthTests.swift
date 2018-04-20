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

class AuthTests: TestCase {

  func testRegister() {
    let gitHubUserEnvelope = GitHub.UserEnvelope.mock
      |> set(^\.accessToken, .init(accessToken: "1234-deadbeef"))
      <> set(^\.gitHubUser.id, 1234567890)
      <> set(^\.gitHubUser.name, "Blobby McBlob")

    let env: (Environment) -> Environment =
      set(^\.database, .live)
        <> set(^\.gitHub.fetchUser, const(pure(gitHubUserEnvelope.gitHubUser)))
        <> set(^\.gitHub.fetchAuthToken, const(pure(pure(gitHubUserEnvelope.accessToken))))

    AppEnvironment.with(env) {
      let result = connection(
        from: request(to: .gitHubCallback(code: "deabeef", redirect: "/"), session: .loggedOut)
        )
        |> siteMiddleware
        |> Prelude.perform
      assertSnapshot(matching: result)

      let registeredUser = AppEnvironment.current.database
        .fetchUserByGitHub(gitHubUserEnvelope.gitHubUser.id)
        .run
        .perform()
        .right!!

      XCTAssertEqual(gitHubUserEnvelope.accessToken.accessToken, registeredUser.gitHubAccessToken)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.id, registeredUser.gitHubUserId)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.name, registeredUser.name)
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
    AppEnvironment.with(set(^\.gitHub.fetchAuthToken, unit |> throwE >>> const)) {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))

      let conn = connection(from: auth)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testAuth_WithFetchAuthTokenBadVerificationCode() {
    AppEnvironment.with(
      set(
        ^\.gitHub.fetchAuthToken,
        const(pure(.left(.init(description: "", error: .badVerificationCode, errorUri: ""))))
      )
    ) {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))

      let conn = connection(from: auth)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testAuth_WithFetchAuthTokenBadVerificationCodeRedirect() {
    AppEnvironment.with(
      set(
        ^\.gitHub.fetchAuthToken,
        const(pure(.left(.init(description: "", error: .badVerificationCode, errorUri: ""))))
      )
    ) {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: url(to: .episode(.right(42)))))

      let conn = connection(from: auth)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testAuth_WithFetchUserFailure() {
    AppEnvironment.with(set(^\.gitHub.fetchUser, unit |> throwE >>> const)) {
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
    AppEnvironment.with(set(^\.database, .mock)) {
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
    AppEnvironment.with(set(^\.database, .mock)) {
      let conn = connection(from: request(to: .home, session: .loggedOut))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }

  func testHome_LoggedIn() {
    AppEnvironment.with(set(^\.database, .mock)) {
      let conn = connection(from: request(to: .home, session: .loggedIn))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())
    }
  }
}
