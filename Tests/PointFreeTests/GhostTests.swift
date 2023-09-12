import Dependencies
import Either
import HttpPipeline
import InlineSnapshotTesting
import Models
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import XCTest

@testable import PointFree

@MainActor
final class GhostTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testStartGhosting_HappyPath() async throws {
    let adminUser = User.admin
    var adminSession = Session.loggedIn
    adminSession.user = .standard(adminUser.id)

    var ghostee = User.mock
    ghostee.id = User.ID(uuidString: "10101010-dead-beef-dead-beefdeadbeef")!

    await withDependencies {
      $0.database.fetchUserById = { userId in
        if userId == adminUser.id {
          return adminUser
        } else if userId == ghostee.id {
          return ghostee
        } else {
          throw unit
        }
      }
    } operation: {
      await assertRequest(
        connection(from: request(to: .admin(.ghost(.start(ghostee.id))), session: adminSession))
      ) {
        """
        POST http://localhost:8080/admin/ghost/start
        Cookie: pf_session={"userId":"12121212-1212-1212-1212-121212121212"}

        user_id=10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF
        """
      } response: {
        """
        302 Found
        Location: /
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"user":{"ghosteeId":"10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF","ghosterId":"12121212-1212-1212-1212-121212121212"}}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  func testStartGhosting_InvalidGhostee() async throws {
    let adminUser = User.admin
    var adminSession = Session.loggedIn
    adminSession.user = .standard(adminUser.id)

    var ghostee = User.mock
    ghostee.id = User.ID(uuidString: "10101010-dead-beef-dead-beefdeadbeef")!

    await withDependencies {
      $0.database.fetchUserById = { userId in
        if userId == adminUser.id {
          return adminUser
        } else {
          throw unit
        }
      }
    } operation: {
      await assertRequest(
        connection(from: request(to: .admin(.ghost(.start(ghostee.id))), session: adminSession))
      ) {
        """
        POST http://localhost:8080/admin/ghost/start
        Cookie: pf_session={"userId":"12121212-1212-1212-1212-121212121212"}

        user_id=10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF
        """
      } response: {
        """
        302 Found
        Location: /admin/ghost
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Couldn't find user with that id","priority":"error"},"userId":"12121212-1212-1212-1212-121212121212"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  func testStartGhosting_NonAdmin() async throws {
    let user = User.mock
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var ghostee = User.mock
    ghostee.id = User.ID(uuidString: "10101010-dead-beef-dead-beefdeadbeef")!

    await withDependencies {
      $0.database.fetchUserById = { userId in
        if userId == user.id {
          return user
        } else if userId == ghostee.id {
          return ghostee
        } else {
          throw unit
        }
      }
    } operation: {
      await assertRequest(
        connection(from: request(to: .admin(.ghost(.start(ghostee.id))), session: session))
      ) {
        """
        POST http://localhost:8080/admin/ghost/start
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}

        user_id=10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF
        """
      } response: {
        """
        302 Found
        Location: /
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"You don't have access to that.","priority":"error"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  func testEndGhosting_HappyPath() async throws {
    var ghostee = User.mock
    ghostee.id = User.ID(uuidString: "10101010-dead-beef-dead-beefdeadbeef")!

    let adminUser = User.admin
    var adminSession = Session.loggedIn
    adminSession.user = .ghosting(ghosteeId: ghostee.id, ghosterId: adminUser.id)

    await withDependencies {
      $0.database.fetchUserById = { userId in
        if userId == adminUser.id {
          return adminUser
        } else if userId == ghostee.id {
          return ghostee
        } else {
          throw unit
        }
      }
    } operation: {
      await assertRequest(
        connection(from: request(to: .endGhosting, session: adminSession))
      ) {
        """
        POST http://localhost:8080/ghosting/end
        Cookie: pf_session={"user":{"ghosteeId":"10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF","ghosterId":"12121212-1212-1212-1212-121212121212"}}
        """
      } response: {
        """
        302 Found
        Location: /
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"userId":"12121212-1212-1212-1212-121212121212"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }
}
