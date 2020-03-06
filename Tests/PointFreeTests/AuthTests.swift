import Either
@testable import GitHub
import HttpPipeline
@testable import PointFree
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

class AuthIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testRegister() {
    var gitHubUserEnvelope = GitHubUserEnvelope.mock
    gitHubUserEnvelope.accessToken = .init(accessToken: "1234-deadbeef")
    gitHubUserEnvelope.gitHubUser.id = 1234567890
    gitHubUserEnvelope.gitHubUser.name = "Blobby McBlob"

    Current.gitHub.fetchUser = const(pure(gitHubUserEnvelope.gitHubUser))
    Current.gitHub.fetchAuthToken = const(pure(pure(gitHubUserEnvelope.accessToken)))

    let result = connection(
      from: request(to: .gitHubCallback(code: "deabeef", redirect: "/"), session: .loggedOut)
      )
      |> siteMiddleware
      |> Prelude.perform
    assertSnapshot(matching: result, as: .conn)

    let registeredUser = Current.database
      .fetchUserByGitHub(gitHubUserEnvelope.gitHubUser.id)
      .run
      .perform()
      .right!!

    XCTAssertEqual(gitHubUserEnvelope.accessToken.accessToken, registeredUser.gitHubAccessToken)
    XCTAssertEqual(gitHubUserEnvelope.gitHubUser.id, registeredUser.gitHubUserId)
    XCTAssertEqual(gitHubUserEnvelope.gitHubUser.name, registeredUser.name)
    XCTAssertEqual(1, registeredUser.episodeCreditCount)
  }

  func testAuth() {
    let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
    let conn = connection(from: auth)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
  func testLoginWithRedirect() {

    let login = request(to: .login(redirect: url(to: .account(.index))), session: .loggedIn)
    let conn = connection(from: login)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}

class AuthTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testAuth_WithFetchAuthTokenFailure() {
    Current.gitHub.fetchAuthToken = unit |> throwE >>> const

    let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
    let conn = connection(from: auth)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAuth_WithFetchAuthTokenBadVerificationCode() {
    Current.gitHub.fetchAuthToken
      = const(pure(.left(.init(description: "", error: .badVerificationCode, errorUri: ""))))

    let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
    let conn = connection(from: auth)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAuth_WithFetchAuthTokenBadVerificationCodeRedirect() {
    Current.gitHub.fetchAuthToken
      = const(pure(.left(.init(description: "", error: .badVerificationCode, errorUri: ""))))

    let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: url(to: .account(.index))))
    let conn = connection(from: auth)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testAuth_WithFetchUserFailure() {
    Current.gitHub.fetchUser = unit |> throwE >>> const

    let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
    let conn = connection(from: auth)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLogin() {
    let login = request(to: .login(redirect: nil))
    let conn = connection(from: login)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLogin_AlreadyLoggedIn() {
    let login = request(to: .login(redirect: nil), session: .loggedIn)
    let conn = connection(from: login)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLogout() {
    let conn = connection(from: request(to: .logout))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testHome_LoggedOut() {
    let conn = connection(from: request(to: .home, session: .loggedOut))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testHome_LoggedIn() {
    let conn = connection(from: request(to: .home, session: .loggedIn))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
