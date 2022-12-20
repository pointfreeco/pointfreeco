import Database
import DatabaseTestSupport
import Either
import EmailAddress
import GitHub
import HttpPipeline
import Models
import ModelsTestSupport
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import Stripe
import StripeTestSupport
import XCTest

@testable import PointFree

@MainActor
class InviteIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  func testSendInvite_HappyPath() async throws {
    let inviterUser = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    _ = try await Current.database.createSubscription(.teamYearly, inviterUser.id, true, nil)

    Current.stripe.fetchSubscription = const(pure(.teamYearly))

    let sendInvite = request(
      to: .invite(.send("blobber@pointfree.co")), session: .init(flash: nil, userId: inviterUser.id)
    )
    let conn = connection(from: sendInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testSendInvite_UnhappyPath_NoSeats() async throws {
    let inviterUser = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let sub = update(Stripe.Subscription.teamYearly) { $0.quantity = 2 }
    _ = try await Current.database.createSubscription(sub, inviterUser.id, true, nil)

    Current.stripe.fetchSubscription = const(pure(sub))

    _ = try await Current.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .performAsync()

    let sendInvite = request(
      to: .invite(.send("blobber2@pointfree.co")),
      session: .init(flash: nil, userId: inviterUser.id))
    let conn = connection(from: sendInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testResendInvite_HappyPath() async throws {
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let teamInvite = try await Current.database
      .insertTeamInvite("blobber@pointfree.co", currentUser.id)
      .performAsync()

    let resendInvite = request(
      to: .invite(.invitation(teamInvite.id, .resend)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: resendInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testRevokeInvite_HappyPath() async throws {
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let teamInvite = try await Current.database
      .insertTeamInvite("blobber@pointfree.co", currentUser.id)
      .performAsync()

    let revokeInvite = request(
      to: .invite(.invitation(teamInvite.id, .revoke)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: revokeInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    let invite = try await Current.database.fetchTeamInvite(teamInvite.id).performAsync()
    XCTAssertNil(invite)
  }

  func testRevokeInvite_CurrentUserIsNotInviter() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    env.gitHubUser.id = 2
    let inviterUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let teamInvite = try await Current.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .performAsync()

    let revokeInvite = request(
      to: .invite(.invitation(teamInvite.id, .revoke)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: revokeInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    let invite = try await Current.database.fetchTeamInvite(teamInvite.id).performAsync()
    XCTAssertNotNil(invite)
  }

  func testAcceptInvitation_HappyPath() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    env.gitHubUser.id = 2
    let inviterUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )
    .performAsync()!

    _ = try await Current.database
      .createSubscription(Stripe.Subscription.mock, inviterUser.id, true, nil)

    let teamInvite = try await Current.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .performAsync()

    let acceptInvite = request(
      to: .invite(.invitation(teamInvite.id, .accept)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: acceptInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    // TODO: need `Parallel` to run on main queue during tests, otherwise we can make this assertion.
    // let invite = try await Current.database.fetchTeamInvite(teamInvite.id).performAsync()
    // XCTAssertNil(invite)

    let subscriptionId = try await Current.database.fetchUserById(currentUser.id).performAsync()!
      .subscriptionId
    XCTAssertNotNil(subscriptionId, "Current user now has a subscription")
  }

  func testAcceptInvitation_InviterIsNotSubscriber() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    env.gitHubUser.id = 2
    let inviterUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let teamInvite = try await Current.database.insertTeamInvite(
      "blobber@pointfree.co", inviterUser.id
    )
    .performAsync()

    let acceptInvite = request(
      to: .invite(.invitation(teamInvite.id, .accept)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: acceptInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    let subscriptionId = try await Current.database.fetchUserById(currentUser.id).performAsync()!
      .subscriptionId
    XCTAssertNil(subscriptionId, "Current user does not have a subscription")
  }

  func testAcceptInvitation_InviterHasInactiveStripeSubscription() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    env.gitHubUser.id = 2
    let inviterUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )
    .performAsync()!

    _ = try await Current.database
      .createSubscription(Stripe.Subscription.mock, inviterUser.id, true, nil)

    let teamInvite = try await Current.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .performAsync()

    Current.stripe.fetchSubscription = const(pure(.canceled))

    let acceptInvite = request(
      to: .invite(.invitation(teamInvite.id, .accept)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: acceptInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    let subscriptionId = try await Current.database.fetchUserById(currentUser.id).performAsync()!
      .subscriptionId
    XCTAssertNil(subscriptionId, "Current user now has a subscription")
  }

  func testAcceptInvitation_InviterHasCancelingStripeSubscription() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    env.gitHubUser.id = 2
    let inviterUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )
    .performAsync()!

    _ = try await Current.database.createSubscription(
      Stripe.Subscription.canceling, inviterUser.id, true, nil
    )

    let teamInvite = try await Current.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .performAsync()

    Current.stripe.fetchSubscription = const(pure(.canceled))

    let acceptInvite = request(
      to: .invite(.invitation(teamInvite.id, .accept)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: acceptInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    let subscriptionId = try await Current.database.fetchUserById(currentUser.id).performAsync()!
      .subscriptionId
    XCTAssertNil(subscriptionId, "Current user now has a subscription")
  }

  func testAddTeammate() async throws {
    Current.database.fetchSubscriptionTeammatesByOwnerId = const(pure([.mock, .mock]))

    let currentUser = try await Current.database.upsertUser(.mock, "hello@pointfree.co", { .mock })
      .performAsync()!

    var stripeSubscription = Stripe.Subscription.teamYearly
    stripeSubscription.quantity = 2
    let teammateEmailAddress: EmailAddress = "blob.jr@pointfree.co"

    _ = try await Current.database.createSubscription(stripeSubscription, currentUser.id, true, nil)

    var session = Session.loggedIn
    session.user = .standard(currentUser.id)

    stripeSubscription.quantity += 3
    Current.stripe.fetchSubscription = const(pure(stripeSubscription))

    let conn = connection(
      from: request(
        to: .invite(.addTeammate(teammateEmailAddress)),
        session: session
      )
    )

    assertSnapshot(matching: siteMiddleware(conn), as: .ioConn)

    let teamInvites = try await Current.database.fetchTeamInvites(currentUser.id)
      .performAsync()
    XCTAssertEqual(
      [teammateEmailAddress],
      teamInvites.map(\.email)
    )
    XCTAssertEqual(
      [currentUser.id],
      teamInvites.map(\.inviterUserId)
    )
  }

  func testResendInvite_CurrentUserIsNotInviter() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    env.gitHubUser.id = 2
    let inviterUser = try await Current.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let teamInvite = try await Current.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)
      .performAsync()

    let resendInvite = request(
      to: .invite(.invitation(teamInvite.id, .resend)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: resendInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}

class InviteTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  func testShowInvite_LoggedOut() {
    let showInvite = request(to: .invite(.invitation(Models.TeamInvite.mock.id)))
    let conn = connection(from: showInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 800)),
          ]
        )
      }
    #endif
  }

  func testShowInvite_LoggedIn_NonSubscriber() {
    var currentUser = Models.User.mock
    currentUser.id = .init(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!

    var invite = Models.TeamInvite.mock
    invite.inviterUserId = .init(
      UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!)

    Current.database.fetchUserById = const(pure(.some(currentUser)))
    Current.database.fetchTeamInvite = const(pure(.some(invite)))
    Current.database.fetchSubscriptionById = const(pure(nil))

    let showInvite = request(to: .invite(.invitation(invite.id)), session: .loggedIn)
    let conn = connection(from: showInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1080, height: 800)),
            "mobile": .ioConnWebView(size: .init(width: 400, height: 800)),
          ]
        )
      }
    #endif
  }

  func testShowInvite_LoggedIn_Subscriber() {
    var currentUser = User.mock
    currentUser.id = .init(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!

    var invite = TeamInvite.mock
    invite.inviterUserId = .init(
      UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!)

    Current.database.fetchUserById = const(pure(.some(currentUser)))
    Current.database.fetchTeamInvite = const(pure(.some(invite)))
    Current.database.fetchSubscriptionById = const(pure(.mock))

    Current.stripe.fetchSubscription = const(pure(.mock))

    let showInvite = request(to: .invite(.invitation(invite.id)), session: .loggedIn)
    let conn = connection(from: showInvite)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
