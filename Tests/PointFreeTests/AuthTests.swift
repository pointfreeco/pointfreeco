import Dependencies
import Either
import HttpPipeline
import InlineSnapshotTesting
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
      $0.gitHub.fetchAuthToken = { _ in gitHubUserEnvelope.accessToken }
    } operation: {
      let result = await siteMiddleware(
        connection(
          from: request(
            to: .auth(.gitHubCallback(code: "deabeef", redirect: "/")), session: .loggedOut)
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
      $0.gitHub.fetchAuthToken = { _ in gitHubUserEnvelope.accessToken }
    } operation: {
      let result = await siteMiddleware(
        connection(
          from: request(
            to: .auth(.gitHubCallback(code: "deabeef", redirect: "/")), session: .loggedOut)
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
    let auth = request(to: .auth(.gitHubCallback(code: "deadbeef", redirect: nil)))
    let conn = connection(from: auth)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testLoginWithRedirect() async throws {
    @Dependency(\.siteRouter) var siteRouter

    let login = request(
      to: .auth(
        .gitHubAuth(
          redirect: siteRouter.url(for: .episodes(.episode(param: .right(42), .show())))
        )
      ),
      session: .loggedIn
    )
    let conn = connection(from: login)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testRegisterWithDuplicateEmail() async throws {
    _ = try await database.registerUser(
      withGitHubEnvelope: GitHubUserEnvelope(
        accessToken: AccessToken(accessToken: "gh-deadbeef"),
        gitHubUser: GitHubUser(
          createdAt: Date(),
          login: "blob",
          id: 999,
          name: "Blob"
        )
      ),
      email: "blob@pointfree.co",
      now: Date.init
    )

    let gitHubUserEnvelope = GitHubUserEnvelope.mock
    await withDependencies {
      $0.gitHub.fetchUser = { _ in gitHubUserEnvelope.gitHubUser }
      $0.gitHub.fetchAuthToken = { _ in gitHubUserEnvelope.accessToken }
      $0.gitHub.fetchEmails = { _ in [GitHubUser.Email(email: "blob@pointfree.co", primary: true)] }
    } operation: {
      let auth = request(to: .auth(.gitHubCallback(code: "deadbeef", redirect: nil)))
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
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
      let auth = request(to: .auth(.gitHubCallback(code: "deadbeef", redirect: nil)))
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testAuth_WithFetchAuthTokenBadVerificationCode() async throws {
    await withDependencies {
      $0.gitHub.fetchAuthToken = { _ in
        throw OAuthError(description: "", error: .badVerificationCode, errorUri: "")
      }
    } operation: {
      let auth = request(to: .auth(.gitHubCallback(code: "deadbeef", redirect: nil)))
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testAuth_WithFetchAuthTokenBadVerificationCodeRedirect() async throws {
    await withDependencies {
      $0.gitHub.fetchAuthToken = { _ in
        throw OAuthError(description: "", error: .badVerificationCode, errorUri: "")
      }
    } operation: {
      @Dependency(\.siteRouter) var siteRouter

      let auth = request(
        to: .auth(
          .gitHubCallback(
            code: "deadbeef",
            redirect: siteRouter.url(for: .episodes(.episode(param: .right(42), .show())))
          )
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
      let auth = request(to: .auth(.gitHubCallback(code: "deadbeef", redirect: nil)))
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
      let auth = request(to: .auth(.gitHubCallback(code: "deadbeef", redirect: nil)))
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testAuth_GitHubFailureLanding() async throws {
    await withDependencies {
      $0.gitHub.fetchUser = { accessToken in
        if accessToken.accessToken == "deadbeef-new" {
          return GitHubUser(createdAt: Date(), login: "blob-new", id: 42, name: "Blob New")
        } else {
          XCTFail("Unrecognized access token.")
          return .mock
        }
      }
      _ = $0
    } operation: {
      let auth = request(
        to: .auth(
          .failureLanding(
            accessToken: AccessToken(accessToken: "deadbeef-new"),
            redirect: nil
          )
        )
      )
      let conn = connection(from: auth)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(conn),
            as: [
              "desktop": .connWebView(size: .init(width: 1100, height: 2000)),
              "mobile": .connWebView(size: .init(width: 500, height: 2000)),
            ]
          )
        }
      #endif
    }
  }

  @MainActor
  func testAuth_UpdateGitHubAccount() async throws {
    let didUpdateUser = self.expectation(description: "didUpdateUser")
    await withDependencies {
      $0.gitHub.fetchUser = { accessToken in
        if accessToken.accessToken == "deadbeef-new" {
          return GitHubUser(createdAt: Date(), login: "blob-new", id: 42, name: "Blob New")
        } else {
          XCTFail("Unrecognized access token.")
          return .mock
        }
      }
      $0.database.updateUser = { _, _, _, _, gitHubUserID, gitHubAccessToken, _ in
        XCTAssertEqual(gitHubUserID, 42)
        XCTAssertEqual(gitHubAccessToken, AccessToken(accessToken: "deadbeef-new"))
        didUpdateUser.fulfill()
      }
    } operation: {
      let auth = request(
        to: .auth(
          .updateGitHub(
            accessToken: AccessToken(accessToken: "deadbeef-new"),
            redirect: nil
          )
        )
      )
      let conn = connection(from: auth)
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        POST http://localhost:8080/update-github?acccess_token=deadbeef-new
        Cookie: pf_session={}

        302 Found
        Location: /
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Your GitHub account has been updated to @blob-new.","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
      await fulfillment(of: [didUpdateUser], timeout: 1)
    }
  }

  @MainActor
  func testLogin() async throws {
    let login = request(to: .auth(.gitHubAuth(redirect: nil)))
    let conn = connection(from: login)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testLogin_AlreadyLoggedIn() async throws {
    let login = request(to: .auth(.gitHubAuth(redirect: nil)), session: .loggedIn)
    let conn = connection(from: login)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testLogout() async throws {
    let conn = connection(from: request(to: .auth(.logout)))

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
