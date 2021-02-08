import Database
import DatabaseTestSupport
import EmailAddress
import GitHub
import Either
import HttpPipeline
import Models
import ModelsTestSupport
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import StripeTestSupport
import XCTest

class InviteIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record = true
  }

  func testResendInvite_HappyPath() {
    let currentUser = Current.database.registerUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    let teamInvite = Current.database.insertTeamInvite("blobber@pointfree.co", currentUser.id)
      .run
      .perform()
      .right!

    let resendInvite = request(to: .invite(.resend(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let conn = connection(from: resendInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testRevokeInvite_HappyPath() {
    let currentUser = Current.database.registerUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    let teamInvite = Current.database.insertTeamInvite("blobber@pointfree.co", currentUser.id)
      .run
      .perform()
      .right!

    let revokeInvite = request(to: .invite(.revoke(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let conn = connection(from: revokeInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertNil(
      Current.database.fetchTeamInvite(teamInvite.id)
        .run
        .perform()
        .right!
    )
  }

  func testRevokeInvite_CurrentUserIsNotInviter() {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = Current.database.registerUser(env, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    env.gitHubUser.id = 2
    let inviterUser = Current.database.registerUser(env, "inviter@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    let teamInvite = Current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    let revokeInvite = request(to: .invite(.revoke(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let conn = connection(from: revokeInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertNotNil(
      Current.database.fetchTeamInvite(teamInvite.id)
        .run
        .perform()
        .right!
    )
  }

  func testAcceptInvitation_HappyPath() {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = Current.database.registerUser(env, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    env.gitHubUser.id = 2
    let inviterUser = Current.database.registerUser(env, "inviter@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    _ = Current.database.createSubscription(Stripe.Subscription.mock, inviterUser.id, true, nil)
      .run
      .perform()

    let teamInvite = Current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    let acceptInvite = request(to: .invite(.accept(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let conn = connection(from: acceptInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    // TODO: need `Parallel` to run on main queue during tests, otherwise we can make this assertion.
    //    XCTAssertNil(
    //      Current.database.fetchTeamInvite(teamInvite.id)
    //        .run
    //        .perform()
    //        .right!
    //    )

    XCTAssertNotNil(
      Current.database.fetchUserById(currentUser.id)
        .run
        .perform()
        .right!!.subscriptionId,
      "Current user now has a subscription"
    )
  }

  func testAcceptInvitation_InviterIsNotSubscriber() {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = Current.database.registerUser(env, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    env.gitHubUser.id = 2
    let inviterUser = Current.database.registerUser(env, "inviter@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    let teamInvite = Current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    let acceptInvite = request(to: .invite(.accept(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let conn = connection(from: acceptInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertNil(
      Current.database.fetchUserById(currentUser.id)
        .run
        .perform()
        .right!!.subscriptionId,
      "Current user does not have a subscription"
    )
  }

  func testAcceptInvitation_InviterHasInactiveStripeSubscription() {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = Current.database.registerUser(env, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    env.gitHubUser.id = 2
    let inviterUser = Current.database.registerUser(env, "inviter@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    _ = Current.database.createSubscription(Stripe.Subscription.mock, inviterUser.id, true, nil)
      .run
      .perform()

    let teamInvite = Current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    Current.stripe.fetchSubscription = const(pure(.canceled))

    let acceptInvite = request(to: .invite(.accept(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let conn = connection(from: acceptInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertNil(
      Current.database.fetchUserById(currentUser.id)
        .run
        .perform()
        .right!!.subscriptionId,
      "Current user now has a subscription"
    )
  }

  func testAcceptInvitation_InviterHasCancelingStripeSubscription() {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = Current.database.registerUser(env, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    env.gitHubUser.id = 2
    let inviterUser = Current.database.registerUser(env, "inviter@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    _ = Current.database.createSubscription(Stripe.Subscription.canceling, inviterUser.id, true, nil)
      .run
      .perform()

    let teamInvite = Current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    Current.stripe.fetchSubscription = const(pure(.canceled))

    let acceptInvite = request(to: .invite(.accept(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let conn = connection(from: acceptInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertNil(
      Current.database.fetchUserById(currentUser.id)
        .run
        .perform()
        .right!!.subscriptionId,
      "Current user now has a subscription"
    )
  }

  func testAddTeammate() {
    Current.database.fetchSubscriptionTeammatesByOwnerId = const(pure([.mock, .mock]))

    let currentUser = Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    var stripeSubscription = Stripe.Subscription.teamYearly
    stripeSubscription.quantity = 2
    let teammateEmailAddress: EmailAddress = "blob.jr@pointfree.co"

    _ = Current.database.createSubscription(stripeSubscription, currentUser.id, true, nil)
      .run
      .perform()
      .right!!

    var session = Session.loggedIn
    session.user = .standard(currentUser.id)
    let conn = connection(
      from: request(
        to: .invite(.addTeammate(teammateEmailAddress)),
        session: session
      )
    )

    assertSnapshot(matching: siteMiddleware(conn), as: .ioConn)

    let teamInvites = Current.database.fetchTeamInvites(currentUser.id)
      .run
      .perform()
      .right!
    XCTAssertEqual(
      [teammateEmailAddress],
      teamInvites.map(\.email)
    )
    XCTAssertEqual(
      [currentUser.id],
      teamInvites.map(\.inviterUserId)
    )
  }

  func testResendInvite_CurrentUserIsNotInviter() {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = Current.database.registerUser(env, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    env.gitHubUser.id = 2
    let inviterUser = Current.database.registerUser(env, "inviter@pointfree.co", { .mock })
      .run
      .perform()
      .right!!

    let teamInvite = Current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .run
      .perform()
      .right!

    let resendInvite = request(to: .invite(.resend(teamInvite.id)), session: .init(flash: nil, userId: currentUser.id))
    let conn = connection(from: resendInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}

class InviteTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record = true
  }

  func testShowInvite_LoggedOut() {
    let showInvite = request(to: .invite(.show(Models.TeamInvite.mock.id)))
    let conn = connection(from: showInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ]
      )
    }
    #endif
  }

  func testShowInvite_LoggedIn_NonSubscriber() {
    var currentUser = Models.User.mock
    currentUser.id = .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!)

    var invite = Models.TeamInvite.mock
    invite.inviterUserId = .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!)

    Current.database.fetchUserById = const(pure(.some(currentUser)))
    Current.database.fetchTeamInvite = const(pure(.some(invite)))
    Current.database.fetchSubscriptionById = const(pure(nil))

    let showInvite = request(to: .invite(.show(invite.id)), session: .loggedIn)
    let conn = connection(from: showInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
          "mobile": .ioConnWebView(size: .init(width: 400, height: 800))
        ]
      )
    }
    #endif
  }

  func testShowInvite_LoggedIn_Subscriber() {
    var currentUser = User.mock
    currentUser.id = .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!)

    var invite = TeamInvite.mock
    invite.inviterUserId = .init(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!)

    Current.database.fetchUserById = const(pure(.some(currentUser)))
    Current.database.fetchTeamInvite = const(pure(.some(invite)))
    Current.database.fetchSubscriptionById = const(pure(.mock))

    Current.stripe.fetchSubscription = const(pure(.mock))

    let showInvite = request(to: .invite(.show(invite.id)), session: .loggedIn)
    let conn = connection(from: showInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
