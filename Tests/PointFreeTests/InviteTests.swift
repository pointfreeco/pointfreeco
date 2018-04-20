import Either
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
import HttpPipeline
import Optics

class InviteTests: TestCase {
  func testShowInvite_LoggedOut() {
    AppEnvironment.with(set(^\.database, .mock)) {
      let showInvite = request(to: .invite(.show(Database.TeamInvite.mock.id)))
      let conn = connection(from: showInvite)
      let result = siteMiddleware(conn)

      assertSnapshot(matching: result.perform())
    }
  }

  func testShowInvite_LoggedIn_NonSubscriber() {
    let currentUser = Database.User.mock
      |> set(^\.id, .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!))

    let invite = Database.TeamInvite.mock
      |> set(^\.inviterUserId, .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!))

    let db = Database.mock
      |> set(^\.fetchUserById, const(pure(.some(currentUser))))
      <> set(^\.fetchTeamInvite, const(pure(.some(invite))))
      <> set(^\.fetchSubscriptionById, const(pure(nil)))

    AppEnvironment.with(set(^\.database, db)) {
      let showInvite = request(to: .invite(.show(invite.id)), session: .loggedIn)
      let conn = connection(from: showInvite)
      let result = siteMiddleware(conn)

      assertSnapshot(matching: result.perform())
    }
  }

  func testShowInvite_LoggedIn_Subscriber() {
    let currentUser = Database.User.mock
      |> set(^\.id, .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!))

    let invite = Database.TeamInvite.mock
      |> set(^\.inviterUserId, .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!))

    let db = Database.mock
      |> set(^\.fetchUserById, const(pure(.some(currentUser))))
      <> set(^\.fetchTeamInvite, const(pure(.some(invite))))
      <> set(^\.fetchSubscriptionById, const(pure(.mock)))

    let stripe = Stripe.mock
      |> set(^\.fetchSubscription, const(pure(.mock |> set(^\.status, .active))))

    AppEnvironment.with(set(^\.database, db) <> set(^\.stripe, stripe)) {
      let showInvite = request(to: .invite(.show(invite.id)), session: .loggedIn)
      let conn = connection(from: showInvite)
      let result = siteMiddleware(conn)

      assertSnapshot(matching: result.perform())
    }
  }

  func testResendInvite_HappyPath() {
    let currentUser = AppEnvironment.current.database.registerUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite("blobber@pointfree.co", currentUser.id)
      .run
      .perform()
      .right!

    let resendInvite = request(to: .invite(.resend(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: resendInvite))

    assertSnapshot(matching: result.perform())
  }

  func testResendInvite_CurrentUserIsNotInviter() {
    let currentUser = AppEnvironment.current.database.registerUser(
      .mock |> set(^\.gitHubUser.id, 1),
      "hello@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock |> set(^\.gitHubUser.id, 2),
      "inviter@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    let resendInvite = request(to: .invite(.resend(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let result = siteMiddleware(connection(from: resendInvite))

    assertSnapshot(matching: result.perform())
  }

  func testRevokeInvite_HappyPath() {
    let currentUser = AppEnvironment.current.database.registerUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite("blobber@pointfree.co", currentUser.id)
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
      .mock |> set(^\.gitHubUser.id, 1),
      "hello@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock |> set(^\.gitHubUser.id, 2),
      "inviter@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
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
      .mock |> set(^\.gitHubUser.id, 1),
      "hello@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock |> set(^\.gitHubUser.id, 2),
      "inviter@pointfree.co"
      )
      .run
      .perform()
      .right!!

    _ = AppEnvironment.current.database.createSubscription(Stripe.Subscription.mock, inviterUser.id)
      .run
      .perform()

    let teamInvite = AppEnvironment.current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
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
      .mock |> set(^\.gitHubUser.id, 1),
      "hello@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock |> set(^\.gitHubUser.id, 2),
      "inviter@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let teamInvite = AppEnvironment.current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
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
      .mock |> set(^\.gitHubUser.id, 1),
      "hello@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock |> set(^\.gitHubUser.id, 2),
      "inviter@pointfree.co"
      )
      .run
      .perform()
      .right!!

    _ = AppEnvironment.current.database.createSubscription(Stripe.Subscription.mock, inviterUser.id)
      .run
      .perform()

    let teamInvite = AppEnvironment.current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    let stripe = Stripe.mock
      |> set(^\.fetchSubscription, const(pure(.mock |> set(^\.status, .canceled))))

    AppEnvironment.with(set(^\.stripe, stripe)) {
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

  func testAcceptInvitation_InviterHasCancelingStripeSubscription() {
    let currentUser = AppEnvironment.current.database.registerUser(
      .mock |> set(^\.gitHubUser.id, 1),
      "hello@pointfree.co"
      )
      .run
      .perform()
      .right!!

    let inviterUser = AppEnvironment.current.database.registerUser(
      .mock |> set(^\.gitHubUser.id, 2),
      "inviter@pointfree.co"
      )
      .run
      .perform()
      .right!!

    _ = AppEnvironment.current.database.createSubscription(Stripe.Subscription.canceling, inviterUser.id)
      .run
      .perform()

    let teamInvite = AppEnvironment.current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    let stripe = Stripe.mock
      |> set(^\.fetchSubscription, const(pure(.mock |> set(^\.status, .canceled))))

    AppEnvironment.with(set(^\.stripe, stripe)) {
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
}
