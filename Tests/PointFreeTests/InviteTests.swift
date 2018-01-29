import Either
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
import Optics
#if !os(Linux)
  import WebKit
#endif

class InviteTests: TestCase {
  func testShowInvite_LoggedOut() {
    AppEnvironment.with(\.database .~ .mock) {
      let showInvite = request(to: .invite(.show(Database.TeamInvite.mock.id)))
      let conn = connection(from: showInvite)
      let result = siteMiddleware(conn)

      assertSnapshot(matching: result.perform())
    }
  }

  func testShowInvite_LoggedIn_NonSubscriber() {
    let currentUser = Database.User.mock
      |> \.id .~ .init(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!)

    let invite = Database.TeamInvite.mock
      |> \.inviterUserId .~ .init(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!)

    let db = Database.mock
      |> \.fetchUserById .~ const(pure(.some(currentUser)))
      |> \.fetchTeamInvite .~ const(pure(.some(invite)))
      |> \.fetchSubscriptionById .~ const(pure(nil))

    AppEnvironment.with(\.database .~ db) {
      let showInvite = request(to: .invite(.show(invite.id)), session: .loggedIn)
      let conn = connection(from: showInvite)
      let result = siteMiddleware(conn)

      assertSnapshot(matching: result.perform())
    }
  }

  func testShowInvite_LoggedIn_Subscriber() {
    let currentUser = Database.User.mock
      |> \.id .~ .init(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!)

    let invite = Database.TeamInvite.mock
      |> \.inviterUserId .~ .init(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!)

    let db = Database.mock
      |> \.fetchUserById .~ const(pure(.some(currentUser)))
      |> \.fetchTeamInvite .~ const(pure(.some(invite)))
      |> \.fetchSubscriptionById .~ const(pure(.mock))

    let stripe = Stripe.mock
      |> \.fetchSubscription .~ const(pure(.mock |> \.status .~ .active))

    AppEnvironment.with((\.database .~ db) <> (\.stripe .~ stripe)) {
      let showInvite = request(to: .invite(.show(invite.id)), session: .loggedIn)
      let conn = connection(from: showInvite)
      let result = siteMiddleware(conn)

      assertSnapshot(matching: result.perform())
    }
  }

  func testResendInvite_HappyPath() {
    let currentUser = AppEnvironment.current.database.registerUser(.mock, EmailAddress(unwrap: "hello@pointfree.co"))
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobber@pointfree.co"), currentUser.id)
      .run
      .perform()
      .right!

    let resendInvite = request(to: .invite(.resend(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: resendInvite))

    assertSnapshot(matching: result.perform())
  }

  func testResendInvite_CurrentUserIsNotInviter() {
    let currentUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 1),

      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 2),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobber@pointfree.co"), inviterUser.id)
      .run
      .perform()
      .right!

    let resendInvite = request(to: .invite(.resend(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: resendInvite))

    assertSnapshot(matching: result.perform())
  }

  func testRevokeInvite_HappyPath() {
    let currentUser = AppEnvironment.current.database.registerUser(.mock, EmailAddress(unwrap: "hello@pointfree.co"))
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobber@pointfree.co"), currentUser.id)
      .run
      .perform()
      .right!

    let revokeInvite = request(to: .invite(.revoke(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: revokeInvite))

    assertSnapshot(matching: result.perform())

    XCTAssertNil(
      AppEnvironment.current.database.fetchTeamInvite(teamInvite.id)
        .run
        .perform()
        .right!
    )
  }

  func testRevokeInvite_CurrentUserIsNotInviter() {
    let currentUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 1),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 2),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobber@pointfree.co"), inviterUser.id)
      .run
      .perform()
      .right!

    let revokeInvite = request(to: .invite(.revoke(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: revokeInvite))

    assertSnapshot(matching: result.perform())

    XCTAssertNotNil(
      AppEnvironment.current.database.fetchTeamInvite(teamInvite.id)
        .run
        .perform()
        .right!
    )
  }

  func testAcceptInvitation_HappyPath() {
    let currentUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 1),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 2),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    _ = AppEnvironment.current.database.createSubscription(Stripe.Subscription.mock, inviterUser.id)
      .run
      .perform()

    let teamInvite = AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobber@pointfree.co"), inviterUser.id)
      .run
      .perform()
      .right!

    let acceptInvite = request(to: .invite(.accept(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: acceptInvite))

    assertSnapshot(matching: result.perform())

    // TODO: need `Parallel` to run on main queue during tests, otherwise we can make this assertion.
//    XCTAssertNil(
//      AppEnvironment.current.database.fetchTeamInvite(teamInvite.id)
//        .run
//        .perform()
//        .right!
//    )

    XCTAssertNotNil(
      AppEnvironment.current.database.fetchUserById(currentUser.id)
        .run
        .perform()
        .right!!.subscriptionId,
      "Current user now has a subscription"
    )
  }

  func testAcceptInvitation_InviterIsNotSubscriber() {
    let currentUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 1),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 2),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobber@pointfree.co"), inviterUser.id)
      .run
      .perform()
      .right!

    let acceptInvite = request(to: .invite(.accept(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: acceptInvite))

    assertSnapshot(matching: result.perform())

    XCTAssertNil(
      AppEnvironment.current.database.fetchUserById(currentUser.id)
        .run
        .perform()
        .right!!.subscriptionId,
      "Current user does not have a subscription"
    )
  }

  func testAcceptInvitation_InviterHasInactiveStripeSubscription() {
    let currentUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 1),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock
        |> \.gitHubUser.id .~ .init(unwrap: 2),
      EmailAddress(unwrap: "hello@pointfree.co")
      )
      .run
      .perform()
      .right!!

    _ = AppEnvironment.current.database.createSubscription(Stripe.Subscription.mock, inviterUser.id)
      .run
      .perform()

    let teamInvite = AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobber@pointfree.co"), inviterUser.id)
      .run
      .perform()
      .right!

    let stripe = Stripe.mock
      |> (\Stripe.fetchSubscription) .~ const(pure(.mock |> \.status .~ .canceled))

    AppEnvironment.with(\.stripe .~ stripe) {
      let acceptInvite = request(to: .invite(.accept(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
      let result = siteMiddleware(connection(from: acceptInvite))
      
      assertSnapshot(matching: result.perform())

      XCTAssertNil(
        AppEnvironment.current.database.fetchUserById(currentUser.id)
          .run
          .perform()
          .right!!.subscriptionId,
        "Current user now has a subscription"
      )
    }
  }

  func testAcceptInvitation_CurrentUserIsInviter() {
    let currentUser = AppEnvironment.current.database.registerUser(.mock, EmailAddress(unwrap: "hello@pointfree.co"))
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobber@pointfree.co"), currentUser.id)
      .run
      .perform()
      .right!

    let acceptInvite = request(to: .invite(.accept(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: acceptInvite))

    assertSnapshot(matching: result.perform())

    XCTAssertNotNil(
      AppEnvironment.current.database.fetchTeamInvite(teamInvite.id)
        .run
        .perform()
        .right!
    )
  }
}
