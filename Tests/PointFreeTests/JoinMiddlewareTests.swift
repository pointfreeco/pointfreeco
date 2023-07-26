import CustomDump
import Dependencies
import EmailAddress
import Mailgun
import Models
import Overture
import PointFreeTestSupport
import SnapshotTesting
import Stripe
import XCTest

@testable import HttpPipeline
@testable import PointFree

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@MainActor
class JoinMiddlewareTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    // isRecording = true
  }

  override func invokeTest() {
    self.useMockBaseDependencies = false
    super.invokeTest()
  }

  func testLanding() async throws {
    await withDependencies {
      $0.database.fetchLivestreams = { [] }
      $0.database.fetchSubscriptionByTeamInviteCode = { _ in .mock }
      $0.database.fetchUserById = { _ in .mock }
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(from: request(to: .teamInviteCode(.landing(code: "deadbeef"))))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  func testLanding_Domain() async throws {
    await withDependencies {
      $0.database.fetchLivestreams = { [] }
      $0.database.fetchSubscriptionByTeamInviteCode = { _ in .mock }
      $0.database.fetchUserById = { _ in .mock }
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(from: request(to: .teamInviteCode(.landing(code: "pointfree.co"))))
      await assertSnapshot(matching: await siteMiddleware(conn), as: .conn)
    }
  }

  func testLanding_InvalidTeamCode() async throws {
    await withDependencies {
      $0.database.fetchLivestreams = { [] }
      $0.database.fetchSubscriptionByTeamInviteCode = { _ in
        struct SomeError: Error {}
        throw SomeError()
      }
      $0.database.fetchUserById = { _ in .mock }
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(from: request(to: .teamInviteCode(.landing(code: "deadbeef"))))
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          GET http://localhost:8080/join/deadbeef
          Cookie: pf_session={}

          302 Found
          Location: /
          Referrer-Policy: strict-origin-when-cross-origin
          Set-Cookie: pf_session={"flash":{"message":"Cannot join team as it is inactive. Contact the subscription owner to re-activate.","priority":"error"}}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )
    }
  }

  func testLanding_InactiveSubscription() async throws {
    await withDependencies {
      $0.database.fetchLivestreams = { [] }
      $0.database.fetchSubscriptionByTeamInviteCode = { _ in .canceled }
      $0.database.fetchUserById = { _ in .mock }
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(from: request(to: .teamInviteCode(.landing(code: "deadbeef"))))
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          GET http://localhost:8080/join/deadbeef
          Cookie: pf_session={}

          302 Found
          Location: /
          Referrer-Policy: strict-origin-when-cross-origin
          Set-Cookie: pf_session={"flash":{"message":"Cannot join team as it is inactive. Contact the subscription owner to re-activate.","priority":"error"}}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )
    }
  }

  func testConfirm_LoggedOut() async throws {
    let user = User.mock
    try await withDependencies {
      $0.database.fetchLivestreams = { [] }
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let secret = try JoinSecretConversion().unapply(
        ("deadbeef", user.id, Int(Date.mock.timeIntervalSince1970))
      )
      let conn = connection(
        from: request(to: .teamInviteCode(.confirm(code: "deadbeef", secret: secret))))
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          GET http://localhost:8080/join/deadbeef/confirm/309df8a272a74d37b902df4f8e7eacc25b064c5c66954cff243a12787dcd45e2b416a8e524eafdcb08a1b82c003867d90807255e3048d8431db6df5aee13a14bfe6b08719418954ebfe54214c9cc3c405a142a74553308da3280ab2cacf8d95e40c913dabe85f929b6238f0b6f27ad41
          Cookie: pf_session={}

          302 Found
          Location: /login?redirect=http://localhost:8080/join/deadbeef/confirm/309df8a272a74d37b902df4f8e7eacc25b064c5c66954cff243a12787dcd45e2b416a8e524eafdcb08a1b82c003867d90807255e3048d8431db6df5aee13a14bfe6b08719418954ebfe54214c9cc3c405a142a74553308da3280ab2cacf8d95e40c913dabe85f929b6238f0b6f27ad41
          Referrer-Policy: strict-origin-when-cross-origin
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )
    }
  }

  func testConfirm_InvalidCode() async throws {
    let user = User.nonSubscriber
    await withDependencies {
      $0.database.fetchEpisodeProgresses = { _ in [] }
      $0.database.fetchLivestreams = { [] }
      $0.database.fetchSubscriptionByOwnerId = { _ in
        struct SomeError: Error {}
        throw SomeError()
      }
      $0.database.fetchUserById = { _ in user }
      $0.database.sawUser = { _ in }
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.confirm(code: "deadbeef", secret: "deadbeef")),
          session: .loggedIn(as: user)
        )
      )
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          GET http://localhost:8080/join/deadbeef/confirm/deadbeef
          Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}

          302 Found
          Location: /
          Referrer-Policy: strict-origin-when-cross-origin
          Set-Cookie: pf_session={"flash":{"message":"This invite link is no longer valid","priority":"error"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )
    }
  }
}

@MainActor
class JoinMiddlewareIntegrationTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  override func setUp() async throws {
    try await super.setUp()
    // isRecording = true
  }

  override func invokeTest() {
    self.useMockBaseDependencies = false
    super.invokeTest()
  }

  func testJoin_LoggedIn_Code() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner)

    let sentEmails = LockIsolated<[Email]>([])
    let updatedSubscription = LockIsolated<(Stripe.Subscription, Plan.ID, Int)?>(nil)

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.mailgun.sendEmail = { email in
        sentEmails.withValue { $0.append(email) }
        return SendEmailResponse(id: "", message: "")
      }
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.stripe.updateSubscription = { stripeSubscription, plan, quantity in
        var stripeSubscription = stripeSubscription
        stripeSubscription.id = .init(subscription.stripeSubscriptionId.rawValue)
        stripeSubscription.plan = plan == .monthly ? .individualMonthly : .individualYearly
        stripeSubscription.quantity = quantity
        updatedSubscription.withValue { $0 = (stripeSubscription, plan, quantity) }
        return stripeSubscription
      }
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.join(code: subscription.teamInviteCode, email: nil)),
          session: .loggedIn(as: currentUser)
        )
      )
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          POST http://localhost:8080/join/subscriptions-team_invite_code3
          Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

          302 Found
          Location: /account
          Referrer-Policy: strict-origin-when-cross-origin
          Set-Cookie: pf_session={"flash":{"message":"You now have access to Point-Free!","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )

      XCTAssertNoDifference(
        Set(sentEmails.value.flatMap(\.to)),
        [
          "blob@pointfree.co",
          "blob.sr@pointfree.co",
          "support@pointfree.co",
        ]
      )
      XCTAssertNoDifference(
        Set(sentEmails.value.map(\.subject)),
        [
          "[testing] Blob has joined your Point-Free subscription",
          "[testing] You have joined Blob Sr's Point-Free subscription",
          "[testing] Team invite link used",
        ]
      )
      XCTAssertEqual(updatedSubscription.value?.0.id, subscription.stripeSubscriptionId)
      XCTAssertEqual(updatedSubscription.value?.1, .monthly)
      XCTAssertEqual(updatedSubscription.value?.2, 2)
      let teammateIDs = Set(
        try await self.database.fetchSubscriptionTeammatesByOwnerId(owner.id).map(\.id))
      XCTAssertEqual(
        teammateIDs,
        [currentUser.id, owner.id]
      )
    }
  }

  func testJoin_LoggedIn_Domain() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "pointfree.co")

    let sentEmails = LockIsolated<[Email]>([])

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.mailgun.sendEmail = { email in
        sentEmails.withValue { $0.append(email) }
        return SendEmailResponse(id: "", message: "")
      }
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.join(code: subscription.teamInviteCode, email: currentUser.email)),
          session: .loggedIn(as: currentUser)
        )
      )
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          POST http://localhost:8080/join/pointfree.co
          Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

          email=blob%40pointfree.co

          302 Found
          Location: /
          Referrer-Policy: strict-origin-when-cross-origin
          Set-Cookie: pf_session={"flash":{"message":"Confirmation email sent to blob@pointfree.co.","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )

      XCTAssertEqual(sentEmails.value.flatMap(\.to), [currentUser.email])
      XCTAssertNoDifference(
        sentEmails.value.map(\.subject),
        ["[testing] Confirm your email to join the Point-Free team subscription."]
      )
      let teammateIDs = try await self.database.fetchSubscriptionTeammatesByOwnerId(owner.id).map(
        \.id)
      XCTAssertEqual(teammateIDs, [owner.id])
    }
  }

  func testJoin_LoggedOut() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "pointfree.co")

    await withDependencies {
      $0.date = .constant(.mock)
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.join(code: subscription.teamInviteCode, email: currentUser.email))
        )
      )
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          POST http://localhost:8080/join/pointfree.co
          Cookie: pf_session={}

          email=blob%40pointfree.co

          302 Found
          Location: /join/pointfree.co
          Referrer-Policy: strict-origin-when-cross-origin
          Set-Cookie: pf_session={"flash":{"message":"You must be logged in to complete that action.","priority":"notice"}}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )
    }
  }

  func testJoin_LoggedIn_CurrentUserHasActiveSubscription() async throws {
    let currentUser = try await self.registerBlob()
    let _ = try await self.createSubscription(owner: currentUser)
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "xyz")

    await withDependencies {
      $0.date = .constant(.mock)
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.join(code: subscription.teamInviteCode, email: nil)),
          session: .loggedIn(as: currentUser)
        )
      )
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          POST http://localhost:8080/join/xyz
          Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

          302 Found
          Location: /account
          Referrer-Policy: strict-origin-when-cross-origin
          Set-Cookie: pf_session={"flash":{"message":"You cannot join this team as you already have an active subscription.","priority":"warning"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )
    }
  }
  // TODO: test join: inactive subscription
  // TODO: test join: unused team seats (with and without owner taking seat)

  func testConfirm_LoggedIn_Domain() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "pointfree.co")

    let sentEmails = LockIsolated<[Email]>([])
    let updatedSubscription = LockIsolated<(Stripe.Subscription, Plan.ID, Int)?>(nil)

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.mailgun.sendEmail = { email in
        sentEmails.withValue { $0.append(email) }
        return SendEmailResponse(id: "", message: "")
      }
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.stripe.updateSubscription = { stripeSubscription, plan, quantity in
        var stripeSubscription = stripeSubscription
        stripeSubscription.id = .init(subscription.stripeSubscriptionId.rawValue)
        stripeSubscription.plan = plan == .monthly ? .individualMonthly : .individualYearly
        stripeSubscription.quantity = quantity
        updatedSubscription.withValue { $0 = (stripeSubscription, plan, quantity) }
        return stripeSubscription
      }
      $0.uuid = .incrementing
    } operation: {
      let secret = try JoinSecretConversion().unapply(
        (subscription.teamInviteCode, currentUser.id, Int(Date.mock.timeIntervalSince1970))
      )
      let conn = connection(
        from: request(
          to: .teamInviteCode(.confirm(code: subscription.teamInviteCode, secret: secret)),
          session: .loggedIn(as: currentUser)
        )
      )
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          GET http://localhost:8080/join/pointfree.co/confirm/309df8a272a74d37b902df4f9a74a4c84d055b5f2e9654c34c47287979c94be2886fca8769f7e0cb08a1b831003867c41507255e2d55d8431dabc25aee13bc4bfe6b087194189553a2ae207cb4f63d445e1a2a482c516b922e9aa92cabf7da5b9abcddac5efd9c919037cfd12b0931c289eb6a98
          Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

          302 Found
          Location: /account
          Referrer-Policy: strict-origin-when-cross-origin
          Set-Cookie: pf_session={"flash":{"message":"You now have access to Point-Free!","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """
      )

      XCTAssertNoDifference(
        Set(sentEmails.value.flatMap(\.to)),
        [
          "blob.sr@pointfree.co",
          "blob@pointfree.co",
          "support@pointfree.co",
        ]
      )
      XCTAssertNoDifference(
        Set(sentEmails.value.map(\.subject)),
        [
          "[testing] Blob has joined your Point-Free subscription",
          "[testing] You have joined pointfree.co's Point-Free subscription",
          "[testing] Team invite link used",
        ]
      )
      XCTAssertEqual(updatedSubscription.value?.0.id, subscription.stripeSubscriptionId)
      XCTAssertEqual(updatedSubscription.value?.1, .monthly)
      XCTAssertEqual(updatedSubscription.value?.2, 2)
    }
  }

  // TODO: test confirm: logged out
  // TODO: test confirm: invalid secret
  // TODO: test confirm: mismatch code
  // TODO: test confirm: mismatch user id
  // TODO: test confirm: cannot find team
  // TODO: test confirm: non-active team
  // TODO: test confirm: current user has active subscription
  // TODO: test confirm: expired link

  private func registerBlob() async throws -> User {
    try await self.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-blob"),
        gitHubUser: .init(createdAt: .mock, id: 1, name: "Blob")
      ),
      email: "blob@pointfree.co",
      now: { .mock }
    )
  }

  private func registerBlobSr() async throws -> User {
    try await self.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-blob-sr"),
        gitHubUser: .init(createdAt: .mock, id: 2, name: "Blob Sr")
      ),
      email: "blob.sr@pointfree.co",
      now: { .mock }
    )
  }

  private func createSubscription(
    owner: User,
    code: Models.Subscription.TeamInviteCode? = nil
  ) async throws -> Models.Subscription {
    var subscription = try await self.database.createSubscription(
      update(.teamYearly) {
        $0.id = .init(UUID().uuidString)
      },
      owner.id,
      true,
      nil
    )
    if let code = code {
      subscription.teamInviteCode = code
      _ = try await self.database.execute(
        """
        UPDATE "subscriptions"
        SET "team_invite_code" = \(bind: code)
        WHERE "id" = \(bind: subscription.id)
        """
      )
    }
    return subscription
  }
}
