import Database
import DatabaseTestSupport
import Dependencies
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

class InviteIntegrationTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  @MainActor
  func testSendInvite_HappyPath() async throws {
    let inviterUser = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )

    _ = try await self.database.createSubscription(.teamYearly, inviterUser.id, true, nil)

    await withDependencies {
      $0.stripe.fetchSubscription = { _ in .teamYearly }
    } operation: {
      let sendInvite = request(
        to: .invite(.send("blobber@pointfree.co")),
        session: .init(flash: nil, userId: inviterUser.id)
      )
      let conn = connection(from: sendInvite)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testSendInvite_UnhappyPath_NoSeats() async throws {
    let inviterUser = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )

    let sub = update(Stripe.Subscription.teamYearly) { $0.quantity = 2 }
    _ = try await self.database.createSubscription(sub, inviterUser.id, true, nil)

    try await withDependencies {
      $0.stripe.fetchSubscription = { _ in sub }
    } operation: {
      _ = try await self.database.insertTeamInvite("blobber@pointfree.co", inviterUser.id)

      let sendInvite = request(
        to: .invite(.send("blobber2@pointfree.co")),
        session: .init(flash: nil, userId: inviterUser.id))
      let conn = connection(from: sendInvite)

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  @MainActor
  func testResendInvite_HappyPath() async throws {
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )

    let teamInvite = try await self.database
      .insertTeamInvite("blobber@pointfree.co", currentUser.id)

    let resendInvite = request(
      to: .invite(.invitation(teamInvite.id, .resend)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: resendInvite)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }

  @MainActor
  func testRevokeInvite_HappyPath() async throws {
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )

    let teamInvite = try await self.database
      .insertTeamInvite("blobber@pointfree.co", currentUser.id)

    let revokeInvite = request(
      to: .invite(.invitation(teamInvite.id, .revoke)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: revokeInvite)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    let invite = try? await self.database.fetchTeamInvite(teamInvite.id)
    XCTAssertNil(invite)
  }

  @MainActor
  func testRevokeInvite_CurrentUserIsNotInviter() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )

    env.gitHubUser.id = 2
    let inviterUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )

    let teamInvite = try await self.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)

    let revokeInvite = request(
      to: .invite(.invitation(teamInvite.id, .revoke)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: revokeInvite)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    let invite = try? await self.database.fetchTeamInvite(teamInvite.id)
    XCTAssertNotNil(invite)
  }

  @MainActor
  func testAcceptInvitation_HappyPath() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )

    env.gitHubUser.id = 2
    let inviterUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )

    _ = try await self.database
      .createSubscription(Stripe.Subscription.mock, inviterUser.id, true, nil)

    let teamInvite = try await self.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)

    let acceptInvite = request(
      to: .invite(.invitation(teamInvite.id, .accept)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: acceptInvite)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    // TODO: need `Parallel` to run on main queue during tests, otherwise we can make this assertion.
    // let invite = try? await self.database.fetchTeamInvite(teamInvite.id)
    // XCTAssertNil(invite)

    let subscriptionId = try await self.database.fetchUserById(currentUser.id).subscriptionId
    XCTAssertNotNil(subscriptionId, "Current user now has a subscription")
  }

  @MainActor
  func testAcceptInvitation_InviterIsNotSubscriber() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )

    env.gitHubUser.id = 2
    let inviterUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )

    let teamInvite = try await self.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)

    let acceptInvite = request(
      to: .invite(.invitation(teamInvite.id, .accept)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: acceptInvite)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    let subscriptionId = try await self.database.fetchUserById(currentUser.id).subscriptionId
    XCTAssertNil(subscriptionId, "Current user does not have a subscription")
  }

  @MainActor
  func testAcceptInvitation_InviterHasInactiveStripeSubscription() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )

    env.gitHubUser.id = 2
    let inviterUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )

    _ = try await self.database
      .createSubscription(Stripe.Subscription.mock, inviterUser.id, true, nil)

    let teamInvite = try await self.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)

    try await withDependencies {
      $0.stripe.fetchSubscription = { _ in .canceled }
    } operation: {
      let acceptInvite = request(
        to: .invite(.invitation(teamInvite.id, .accept)),
        session: .init(flash: nil, userId: currentUser.id)
      )
      let conn = connection(from: acceptInvite)

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

      let subscriptionId = try await self.database.fetchUserById(currentUser.id).subscriptionId
      XCTAssertNil(subscriptionId, "Current user now has a subscription")
    }
  }

  @MainActor
  func testAcceptInvitation_InviterHasCancelingStripeSubscription() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )

    env.gitHubUser.id = 2
    let inviterUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )

    _ = try await self.database.createSubscription(
      Stripe.Subscription.canceling, inviterUser.id, true, nil
    )

    let teamInvite = try await self.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)

    try await withDependencies {
      $0.stripe.fetchSubscription = { _ in .canceled }
    } operation: {
      let acceptInvite = request(
        to: .invite(.invitation(teamInvite.id, .accept)),
        session: .init(flash: nil, userId: currentUser.id)
      )
      let conn = connection(from: acceptInvite)

      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

      let subscriptionId = try await self.database.fetchUserById(currentUser.id).subscriptionId
      XCTAssertNil(subscriptionId, "Current user now has a subscription")
    }
  }

  @MainActor
  func testAddTeammate() async throws {
    try await withDependencies {
      $0.database.fetchSubscriptionTeammatesByOwnerId = { _ in [.mock, .mock] }
    } operation: {
      let currentUser = try await self.database.upsertUser(
        .mock, "hello@pointfree.co", { .mock })

      var stripeSubscription = Stripe.Subscription.teamYearly
      stripeSubscription.quantity = 2
      let teammateEmailAddress: EmailAddress = "blob.jr@pointfree.co"

      _ = try await self.database.createSubscription(
        stripeSubscription, currentUser.id, true, nil)

      var session = Session.loggedIn
      session.user = .standard(currentUser.id)

      stripeSubscription.quantity += 3
      try await withDependencies {
        $0.stripe.fetchSubscription = { _ in stripeSubscription }
      } operation: {
        let conn = connection(
          from: request(
            to: .invite(.addTeammate(teammateEmailAddress)),
            session: session
          )
        )

        await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

        let teamInvites = try await self.database.fetchTeamInvites(currentUser.id)
        XCTAssertEqual(
          [teammateEmailAddress],
          teamInvites.map(\.email)
        )
        XCTAssertEqual(
          [currentUser.id],
          teamInvites.map(\.inviterUserId)
        )
      }
    }
  }

  @MainActor
  func testResendInvite_CurrentUserIsNotInviter() async throws {
    var env = GitHubUserEnvelope.mock
    env.gitHubUser.id = 1
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "hello@pointfree.co", now: { .mock }
    )

    env.gitHubUser.id = 2
    let inviterUser = try await self.database.registerUser(
      withGitHubEnvelope: env, email: "inviter@pointfree.co", now: { .mock }
    )

    let teamInvite = try await self.database
      .insertTeamInvite("blobber@pointfree.co", inviterUser.id)

    let resendInvite = request(
      to: .invite(.invitation(teamInvite.id, .resend)),
      session: .init(flash: nil, userId: currentUser.id)
    )
    let conn = connection(from: resendInvite)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
  }
}

class InviteTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  @MainActor
  func testShowInvite_LoggedOut() async throws {
    let showInvite = request(to: .invite(.invitation(Models.TeamInvite.mock.id)))
    let conn = connection(from: showInvite)

    await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: await siteMiddleware(conn),
          as: [
            "desktop": .connWebView(size: .init(width: 1080, height: 800)),
            "mobile": .connWebView(size: .init(width: 400, height: 800)),
          ]
        )
      }
    #endif
  }

  @MainActor
  func testShowInvite_LoggedIn_NonSubscriber() async throws {
    var currentUser = Models.User.mock
    currentUser.id = .init(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!

    var invite = Models.TeamInvite.mock
    invite.inviterUserId = .init(
      UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!)

    await withDependencies {
      $0 = .test
      $0.database.fetchEpisodeProgresses = { _ in [] }
      $0.database.fetchLivestreams = { [] }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.database.fetchUserById = { _ in currentUser }
      $0.database.fetchTeamInvite = { _ in invite }
      $0.database.fetchSubscriptionById = { _ in throw unit }
      $0.database.sawUser = { _ in }
      $0.date.now = .mock
      $0.uuid = .incrementing
    } operation: {
      let showInvite = request(to: .invite(.invitation(invite.id)), session: .loggedIn)
      let conn = connection(from: showInvite)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: await siteMiddleware(conn),
            as: [
              "desktop": .connWebView(size: .init(width: 1080, height: 800)),
              "mobile": .connWebView(size: .init(width: 400, height: 800)),
            ]
          )
        }
      #endif
    }
  }

  @MainActor
  func testShowInvite_LoggedIn_Subscriber() async throws {
    var currentUser = User.mock
    currentUser.id = .init(uuidString: "deadbeef-dead-beef-dead-beefdead0002")!

    var invite = TeamInvite.mock
    invite.inviterUserId = .init(
      UUID(uuidString: "deadbeef-dead-beef-dead-beefdead0001")!)

    await withDependencies {
      $0.database.fetchLivestreams = { [] }
      $0.database.fetchUserById = { _ in currentUser }
      $0.database.fetchTeamInvite = { _ in invite }
      $0.database.fetchSubscriptionById = { _ in .mock }
      $0.stripe.fetchSubscription = { _ in .mock }
    } operation: {
      let showInvite = request(to: .invite(.invitation(invite.id)), session: .loggedIn)
      let conn = connection(from: showInvite)
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }
}
