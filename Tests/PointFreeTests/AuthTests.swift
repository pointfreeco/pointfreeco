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

class AuthIntegrationTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  @MainActor
  func testRegister() async throws {
    let now = Date.mock

    var gitHubUserEnvelope = GitHubUserEnvelope.mock
    gitHubUserEnvelope.accessToken = .init(accessToken: "1234-deadbeef")
    gitHubUserEnvelope.gitHubUser.createdAt = now - 60 * 60 * 24 * 365
    gitHubUserEnvelope.gitHubUser.id = 1_234_567_890
    gitHubUserEnvelope.gitHubUser.name = "Blobby McBlob"

    try await withDependencies {
      $0.date.now = now
      $0.gitHub.fetchUser = { _ in gitHubUserEnvelope.gitHubUser }
      $0.gitHub.fetchAuthToken = { _ in .right(gitHubUserEnvelope.accessToken) }
    } operation: {
      let result = await siteMiddleware(
        connection(
          from: request(to: .gitHubCallback(code: "deabeef", redirect: "/"), session: .loggedOut)
        )
      )
      await assertSnapshot(matching: result, as: .conn)

      let registeredUser = try await self.database
        .fetchUserByGitHub(gitHubUserEnvelope.gitHubUser.id)

      XCTAssertEqual(gitHubUserEnvelope.accessToken.accessToken, registeredUser.gitHubAccessToken)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.id, registeredUser.gitHubUserId)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.name, registeredUser.name)
      XCTAssertEqual(1, registeredUser.episodeCreditCount)
    }
  }

  @MainActor
  func testRegisterRecentAccount() async throws {
    let now = Date.mock

    var gitHubUserEnvelope = GitHubUserEnvelope.mock
    gitHubUserEnvelope.accessToken = .init(accessToken: "1234-deadbeef")
    gitHubUserEnvelope.gitHubUser.createdAt = now - 5 * 60
    gitHubUserEnvelope.gitHubUser.id = 1_234_567_890
    gitHubUserEnvelope.gitHubUser.name = "Blobby McBlob"

    try await withDependencies {
      $0.date.now = now
      $0.gitHub.fetchUser = { _ in gitHubUserEnvelope.gitHubUser }
      $0.gitHub.fetchAuthToken = { _ in .right(gitHubUserEnvelope.accessToken) }
    } operation: {
      let result = await siteMiddleware(
        connection(
          from: request(to: .gitHubCallback(code: "deabeef", redirect: "/"), session: .loggedOut)
        )
      )
      await assertSnapshot(matching: result, as: .conn)

      let registeredUser = try await self.database
        .fetchUserByGitHub(gitHubUserEnvelope.gitHubUser.id)

      XCTAssertEqual(gitHubUserEnvelope.accessToken.accessToken, registeredUser.gitHubAccessToken)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.id, registeredUser.gitHubUserId)
      XCTAssertEqual(gitHubUserEnvelope.gitHubUser.name, registeredUser.name)
      XCTAssertEqual(0, registeredUser.episodeCreditCount)
    }
  }

  @MainActor
  func testAuth() async throws {
    let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
    let conn = connection(from: auth)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testLoginWithRedirect() async throws {
    @Dependency(\.siteRouter) var siteRouter

    let login = request(
      to: .gitHubAuth(
        redirect: siteRouter.url(for: .episodes(.episode(param: .right(42), .show())))
      ),
      session: .loggedIn
    )
    let conn = connection(from: login)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }
}

class AuthTests: TestCase {

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  @MainActor
  func testAuth_WithFetchAuthTokenFailure() async throws {
    await withDependencies {
      $0.gitHub.fetchAuthToken = { _ in throw unit }
    } operation: {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testAuth_WithFetchAuthTokenBadVerificationCode() async throws {
    await withDependencies {
      $0.gitHub.fetchAuthToken = { _ in
        .left(.init(description: "", error: .badVerificationCode, errorUri: ""))
      }
    } operation: {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testAuth_WithFetchAuthTokenBadVerificationCodeRedirect() async throws {
    await withDependencies {
      $0.gitHub.fetchAuthToken = { _ in
        .left(.init(description: "", error: .badVerificationCode, errorUri: ""))
      }
    } operation: {
      @Dependency(\.siteRouter) var siteRouter

      let auth = request(
        to: .gitHubCallback(
          code: "deadbeef",
          redirect: siteRouter.url(for: .episodes(.episode(param: .right(42), .show())))
        )
      )
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testAuth_WithFetchUserFailure() async throws {
    await withDependencies {
      $0.gitHub.fetchUser = { _ in throw unit }
    } operation: {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testAuth_WithRegisterUserFailure() async throws {
    await withDependencies {
      $0.database.fetchUserByGitHub = { _ in throw unit }
      $0.database.upsertUser = { _, _, _ in
        throw GitHubUser.AlreadyRegistered(email: "blob@example.org")
      }
    } operation: {
      let auth = request(to: .gitHubCallback(code: "deadbeef", redirect: nil))
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testLogin() async throws {
    let login = request(to: .gitHubAuth(redirect: nil))
    let conn = connection(from: login)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testLogin_AlreadyLoggedIn() async throws {
    let login = request(to: .gitHubAuth(redirect: nil), session: .loggedIn)
    let conn = connection(from: login)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testLogout() async throws {
    let conn = connection(from: request(to: .logout))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testHome_LoggedOut() async throws {
    let conn = connection(from: request(to: .home, session: .loggedOut))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testHome_LoggedIn() async throws {
    let conn = connection(from: request(to: .home, session: .loggedIn))

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }
}
