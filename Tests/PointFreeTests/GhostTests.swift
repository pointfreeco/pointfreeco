import Either
import HttpPipeline
import Models
@testable import PointFree
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

final class GhostTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testStartGhosting_HappyPath() {
    let adminUser = User.admin
    var adminSession = Session.loggedIn
    adminSession.user = .standard(adminUser.id)
    
    var ghostee = User.mock
    ghostee.id = User.Id(rawValue: UUID(uuidString: "10101010-dead-beef-dead-beefdeadbeef")!)
    
    Current.database.fetchUserById = { userId -> EitherIO<Error, User?> in
      pure(
        userId == adminUser.id ? adminUser
          : userId == ghostee.id ? ghostee
          : nil
      )
    }

    let conn = connection(
      from: request(to: .admin(.ghost(.start(ghostee.id))), session: adminSession)
      )
      |> siteMiddleware
      |> Prelude.perform

    _assertInlineSnapshot(matching: conn, as: .conn, with: """
POST http://localhost:8080/admin/ghost/start
Cookie: pf_session={"userId":"12121212-1212-1212-1212-121212121212"}

user_id=10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF

302 Found
Location: /
Referrer-Policy: strict-origin-when-cross-origin
Set-Cookie: pf_session={"user":{"ghosteeId":"10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF","ghosterId":"12121212-1212-1212-1212-121212121212"}}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-XSS-Protection: 1; mode=block
""")
  }

  func testStartGhosting_InvalidGhostee() {
    let adminUser = User.admin
    var adminSession = Session.loggedIn
    adminSession.user = .standard(adminUser.id)

    var ghostee = User.mock
    ghostee.id = User.Id(rawValue: UUID(uuidString: "10101010-dead-beef-dead-beefdeadbeef")!)

    Current.database.fetchUserById = { userId -> EitherIO<Error, User?> in
      pure(
        userId == adminUser.id ? adminUser
          : nil
      )
    }

    let conn = connection(
      from: request(to: .admin(.ghost(.start(ghostee.id))), session: adminSession)
      )
      |> siteMiddleware
      |> Prelude.perform

    _assertInlineSnapshot(matching: conn, as: .conn, with: """
POST http://localhost:8080/admin/ghost/start
Cookie: pf_session={"userId":"12121212-1212-1212-1212-121212121212"}

user_id=10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF

302 Found
Location: /admin/ghost
Referrer-Policy: strict-origin-when-cross-origin
Set-Cookie: pf_session={"flash":{"message":"Couldn't find user with that id","priority":"error"},"userId":"12121212-1212-1212-1212-121212121212"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-XSS-Protection: 1; mode=block
""")
  }

  func testStartGhosting_NonAdmin() {
    let user = User.mock
    var session = Session.loggedIn
    session.user = .standard(user.id)

    var ghostee = User.mock
    ghostee.id = User.Id(rawValue: UUID(uuidString: "10101010-dead-beef-dead-beefdeadbeef")!)

    Current.database.fetchUserById = { userId -> EitherIO<Error, User?> in
      pure(
        userId == user.id ? user
          : userId == ghostee.id ? ghostee
          : nil
      )
    }

    let conn = connection(
      from: request(to: .admin(.ghost(.start(ghostee.id))), session: session)
      )
      |> siteMiddleware
      |> Prelude.perform

    _assertInlineSnapshot(matching: conn, as: .conn, with: """
POST http://localhost:8080/admin/ghost/start
Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}

user_id=10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF

302 Found
Location: /
Referrer-Policy: strict-origin-when-cross-origin
Set-Cookie: pf_session={"flash":{"message":"You don't have access to that.","priority":"error"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-XSS-Protection: 1; mode=block
""")
  }

  func testEndGhosting_HappyPath() {
    var ghostee = User.mock
    ghostee.id = User.Id(rawValue: UUID(uuidString: "10101010-dead-beef-dead-beefdeadbeef")!)

    let adminUser = User.admin
    var adminSession = Session.loggedIn
    adminSession.user = .ghosting(ghosteeId: ghostee.id, ghosterId: adminUser.id)

    Current.database.fetchUserById = { userId -> EitherIO<Error, User?> in
      pure(
        userId == adminUser.id ? adminUser
          : userId == ghostee.id ? ghostee
          : nil
      )
    }

    let conn = connection(
      from: request(to: .endGhosting, session: adminSession)
      )
      |> siteMiddleware
      |> Prelude.perform

    _assertInlineSnapshot(matching: conn, as: .conn, with: """
POST http://localhost:8080/ghosting/end
Cookie: pf_session={"user":{"ghosteeId":"10101010-DEAD-BEEF-DEAD-BEEFDEADBEEF","ghosterId":"12121212-1212-1212-1212-121212121212"}}

302 Found
Location: /
Referrer-Policy: strict-origin-when-cross-origin
Set-Cookie: pf_session={"userId":"12121212-1212-1212-1212-121212121212"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-XSS-Protection: 1; mode=block
""")
  }
}
