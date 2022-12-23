import Dependencies
import Either
import HttpPipeline
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import GitHub
@testable import PointFree

@MainActor
class AuthIntegrationTests: LiveDatabaseTestCase {
  @Dependency(\.siteRouter) var siteRouter
  
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.record = true
  }

  func testRegister() async throws {
    let now = Date.mock
    var gitHubUserEnvelope = GitHubUserEnvelope.mock
    gitHubUserEnvelope.accessToken = .init(accessToken: "1234-deadbeef")
    gitHubUserEnvelope.gitHubUser.createdAt = now - 60 * 60 * 24 * 365
    gitHubUserEnvelope.gitHubUser.id = 1_234_567_890
    gitHubUserEnvelope.gitHubUser.name = "Blobby McBlob"

    try await DependencyValues.withTestValues {
      $0.date.now = now
      $0.gitHub.fetchUser = const(pure(gitHubUserEnvelope.gitHubUser))
      $0.gitHub.fetchAuthToken = const(pure(pure(gitHubUserEnvelope.accessToken)))
    } operation: {
      let result = await siteMiddleware(
        connection(
          from: request(to: .gitHubCallback(code: "deabeef", redirect: "/"), session: .loggedOut)
        )
      )
        .performAsync()
      assertSnapshot(matching: result, as: .conn)

      let registeredUser = try await Current.database
        .fetchUserByGitHub(gitHubUserEnvelope.gitHubUser.id)
        .performAsync()!

      XCTAssertEqual(gitHubUserEnvelope.accessToken.accessToken, registeredUser.gitHubAccessToken)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.id, registeredUser.gitHubUserId)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.name, registeredUser.name)
      XCTAssertEqual(1, registeredUser.episodeCreditCount)
    }
  }

  func testRegisterRecentAccount() async throws {
    let now = Date.mock
    var gitHubUserEnvelope = GitHubUserEnvelope.mock
    gitHubUserEnvelope.accessToken = .init(accessToken: "1234-deadbeef")
    gitHubUserEnvelope.gitHubUser.createdAt = now - 5 * 60
    gitHubUserEnvelope.gitHubUser.id = 1_234_567_890
    gitHubUserEnvelope.gitHubUser.name = "Blobby McBlob"

    try await DependencyValues.withTestValues {
      $0.date.now = now
      $0.gitHub.fetchUser = const(pure(gitHubUserEnvelope.gitHubUser))
      $0.gitHub.fetchAuthToken = const(pure(pure(gitHubUserEnvelope.accessToken)))
    } operation: {
      let result = await siteMiddleware(
        connection(
          from: request(to: .gitHubCallback(code: "deabeef", redirect: "/"), session: .loggedOut)
        )
      )
        .performAsync()
      assertSnapshot(matching: result, as: .conn)
      
      let registeredUser = try await Current.database
        .fetchUserByGitHub(gitHubUserEnvelope.gitHubUser.id)
        .performAsync()!
      
      XCTAssertEqual(gitHubUserEnvelope.accessToken.accessToken, registeredUser.gitHubAccessToken)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.id, registeredUser.gitHubUserId)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.name, registeredUser.name)
      XCTAssertEqual(0, registeredUser.episodeCreditCount)
    }
  }

  func testAuth() async throws {
    let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
    let conn = connection(from: auth)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testLoginWithRedirect() async throws {

    let login = request(
      to: .login(redirect: siteRouter.url(for: .episode(.show(.right(42))))), session: .loggedIn)
    let conn = connection(from: login)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}

class AuthTests: TestCase {
  @Dependency(\.siteRouter) var siteRouter

  override func setUp() {
    super.setUp()
    //    SnapshotTesting.record = true
  }

  func testAuth_WithFetchAuthTokenFailure() {
    DependencyValues.withTestValues {
      $0.gitHub.fetchAuthToken = unit |> throwE >>> const
      $0.gitHub.fetchAuthToken = unit |> throwE >>> const
    } operation: {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
      let conn = connection(from: auth)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAuth_WithFetchAuthTokenBadVerificationCode() {
    DependencyValues.withTestValues {
      $0.gitHub.fetchAuthToken = const(
        pure(.left(.init(description: "", error: .badVerificationCode, errorUri: ""))))
    } operation: {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
      let conn = connection(from: auth)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAuth_WithFetchAuthTokenBadVerificationCodeRedirect() {
    DependencyValues.withTestValues {
      $0.gitHub.fetchAuthToken = const(
        pure(.left(.init(description: "", error: .badVerificationCode, errorUri: ""))))
    } operation: {
      let auth = request(
        to: .gitHubCallback(
          code: "deadbeef", redirect: siteRouter.url(for: .episode(.show(.right(42))))))
      let conn = connection(from: auth)

      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testAuth_WithFetchUserFailure() {
    DependencyValues.withTestValues {
      $0.gitHub.fetchUser = unit |> throwE >>> const
    } operation: {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
      let conn = connection(from: auth)
      
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
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
