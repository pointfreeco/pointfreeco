import CustomDump
import Dependencies
import EmailAddress
import InlineSnapshotTesting
import Mailgun
import Models
import Overture
import PointFreeTestSupport
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }
    }
  }

  func testJoin_InvalidEmail() async throws {
    await withDependencies {
      struct SomeError: Error {}
      $0.database.fetchEpisodeProgresses = { _ in [] }
      $0.database.fetchLivestreams = { [] }
      $0.database.fetchSubscriptionById = { _ in throw SomeError() }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw SomeError() }
      $0.database.fetchSubscriptionByTeamInviteCode = { _ in .mock }
      $0.database.fetchUserById = { _ in .mock }
      $0.database.sawUser = { _ in }
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.join(code: "pointfree.co", email: "admin@blob.biz")),
          session: .loggedIn(as: .nonSubscriber)))
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        POST http://localhost:8080/join/pointfree.co
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}

        email=admin%40blob.biz

        302 Found
        Location: /join/pointfree.co
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Your email address must be from the @pointfree.co domain.","priority":"error"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }
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

  #if !os(Linux)
    override func invokeTest() {
      self.useMockBaseDependencies = false
      super.invokeTest()
    }
  #endif

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
      $0.stripe.fetchSubscription = { _ in
        var stripeSubscription = Stripe.Subscription.mock
        stripeSubscription.quantity = 1
        return stripeSubscription
      }
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }

      XCTAssertNoDifference(
        Set(sentEmails.value.flatMap(\.to)),
        [
          "blob@pointfree.co",
          "blob.sr@pointfree.co",
          "brandon@pointfree.co",
          "stephen@pointfree.co",
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }

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

  func testJoin_LoggedIn_Domain_StripeFetchError() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "pointfree.co")

    await withDependencies {
      $0.date = .constant(.mock)
      $0.stripe.fetchSubscription = { _ in
        struct SomeError: Error {}
        throw SomeError()
      }
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.join(code: subscription.teamInviteCode, email: nil)),
          session: .loggedIn(as: currentUser)
        )
      )
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        POST http://localhost:8080/join/pointfree.co
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

        302 Found
        Location: /join/pointfree.co
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Could not find subscription. Try again or contact support@pointfree.co.","priority":"error"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  func testJoin_LoggedIn_InactiveSubscription() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(
      owner: owner, code: "pointfree.co", status: .canceled
    )

    await withDependencies {
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.join(code: subscription.teamInviteCode, email: nil)),
          session: .loggedIn(as: currentUser)
        )
      )
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        POST http://localhost:8080/join/pointfree.co
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

        302 Found
        Location: /join/pointfree.co
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Cannot join team as it is inactive. Contact the subscription owner to re-activate.","priority":"error"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  func testJoin_LoggedIn_InvalidDomain() async throws {
    let currentUser = try await self.registerBlob()

    await withDependencies {
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .teamInviteCode(.join(code: "pointfree.co", email: nil)),
          session: .loggedIn(as: currentUser)
        )
      )
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        POST http://localhost:8080/join/pointfree.co
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

        302 Found
        Location: /
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Could not find that team.","priority":"error"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }
    }
  }

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
      $0.stripe.fetchSubscription = { _ in
        var stripeSubscription = Stripe.Subscription.mock
        stripeSubscription.quantity = 1
        return stripeSubscription
      }
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }

      XCTAssertNoDifference(
        Set(sentEmails.value.flatMap(\.to)),
        [
          "blob.sr@pointfree.co",
          "blob@pointfree.co",
          "brandon@pointfree.co",
          "stephen@pointfree.co",
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

  func testConfirm_LoggedIn_Domain_OpenSeats_OwnerNonSubscriber() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(
      owner: owner,
      isOwnerTakingSeat: false,
      code: "pointfree.co"
    )

    let sentEmails = LockIsolated<[Email]>([])

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.mailgun.sendEmail = { email in
        sentEmails.withValue { $0.append(email) }
        return SendEmailResponse(id: "", message: "")
      }
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.stripe.updateSubscription = { _, _, _ in
        struct SomeError: Error {}
        throw SomeError()
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }

      XCTAssertNoDifference(
        Set(sentEmails.value.flatMap(\.to)),
        [
          "blob.sr@pointfree.co",
          "blob@pointfree.co",
          "brandon@pointfree.co",
          "stephen@pointfree.co",
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
    }
  }

  func testConfirm_LoggedIn_Domain_OpenSeats() async throws {
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
      $0.stripe.fetchSubscription = { _ in
        var stripeSubscription = Stripe.Subscription.mock
        stripeSubscription.quantity = 10
        return stripeSubscription
      }
      $0.stripe.updateSubscription = { _, _, _ in
        struct SomeError: Error {}
        throw SomeError()
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
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
      }

      XCTAssertNoDifference(
        Set(sentEmails.value.flatMap(\.to)),
        [
          "blob.sr@pointfree.co",
          "blob@pointfree.co",
          "brandon@pointfree.co",
          "stephen@pointfree.co",
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
    }
  }

  func testConfirm_LoggedIn_Domain_StripeFailure() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "pointfree.co")

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.stripe.fetchSubscription = { _ in
        var stripeSubscription = Stripe.Subscription.mock
        stripeSubscription.quantity = 1
        return stripeSubscription
      }
      $0.stripe.updateSubscription = { _, _, _ in
        struct SomeError: Error {}
        throw SomeError()
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
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        GET http://localhost:8080/join/pointfree.co/confirm/309df8a272a74d37b902df4f9a74a4c84d055b5f2e9654c34c47287979c94be2886fca8769f7e0cb08a1b831003867c41507255e2d55d8431dabc25aee13bc4bfe6b087194189553a2ae207cb4f63d445e1a2a482c516b922e9aa92cabf7da5b9abcddac5efd9c919037cfd12b0931c289eb6a98
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

        302 Found
        Location: /join/pointfree.co
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"Could not add you to the team. Try again or contact support@pointfree.co.","priority":"error"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  func testConfirm_LoggedIn_ExpiredCode() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "pointfree.co")

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.uuid = .incrementing
    } operation: {
      let secret = try JoinSecretConversion().unapply(
        (
          subscription.teamInviteCode,
          currentUser.id,
          Int(Date.mock.addingTimeInterval(-700_000).timeIntervalSince1970)
        )
      )
      let conn = connection(
        from: request(
          to: .teamInviteCode(.confirm(code: subscription.teamInviteCode, secret: secret)),
          session: .loggedIn(as: currentUser)
        )
      )
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        GET http://localhost:8080/join/pointfree.co/confirm/309df8a272a74d37b902df4f9a74a4c84d055b5f2e9654c34c47287979c94be2886fca8769f7e0cb08a1b831003867c41507255e2d55d8431dabc25aee13bc4bfe6b087194189553a2ae207cb4f63d445e1a2a482c516b922e9aa92cabf6df5b9abcddaca84acabd9594437b4126b2df20a5593c
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

        302 Found
        Location: /
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"This invite link is no longer valid","priority":"error"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  func testConfirm_LoggedIn_UserIDMismatch() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "pointfree.co")

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.uuid = .incrementing
    } operation: {
      let secret = try JoinSecretConversion().unapply(
        (
          subscription.teamInviteCode,
          User.ID(UUID(uuidString: "99999999-9999-9999-9999-999999999999")!),
          Int(Date.mock.timeIntervalSince1970)
        )
      )
      let conn = connection(
        from: request(
          to: .teamInviteCode(.confirm(code: subscription.teamInviteCode, secret: secret)),
          session: .loggedIn(as: currentUser)
        )
      )
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        GET http://localhost:8080/join/pointfree.co/confirm/309df8a272a74d37b902df4f9a74a4c84d055b5f2e9654c34c47287979c94be2886fca8769f7e0c201a8b13809316ec41c0e2c572d5cd14a14abcb53e71abc42f76201789d119c5aaba7287cb4f63d445e1a2a482c516b922e9aa92cabf7da5b9abcddacc773d82cfa5af5d389a5eb7528190134
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

        302 Found
        Location: /
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"This invite link is no longer valid","priority":"error"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

  func testConfirm_LoggedIn_CodeMismatch() async throws {
    let currentUser = try await self.registerBlob()
    let owner = try await self.registerBlobSr()
    let subscription = try await self.createSubscription(owner: owner, code: "pointfree.co")

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.uuid = .incrementing
    } operation: {
      let secret = try JoinSecretConversion().unapply(
        ("deadbeef", currentUser.id, Int(Date.mock.timeIntervalSince1970))
      )
      let conn = connection(
        from: request(
          to: .teamInviteCode(.confirm(code: subscription.teamInviteCode, secret: secret)),
          session: .loggedIn(as: currentUser)
        )
      )
      await assertInlineSnapshot(of: await siteMiddleware(conn), as: .conn) {
        """
        GET http://localhost:8080/join/pointfree.co/confirm/309df8a272a74d37b902df4f8e7eacc25b064c5c66954cff243a12787dcd45e2b416a8e524eafdcb08a1b82c003867d90807255e3048d8431db6df5aee13a14bfe6b08719418944ebfe54214c9cc3c405a142a74553308da3280ab2cacf8d95e98c815747a45ce3cfba86d353c333009
        Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000001"}

        302 Found
        Location: /
        Referrer-Policy: strict-origin-when-cross-origin
        Set-Cookie: pf_session={"flash":{"message":"This invite link is no longer valid","priority":"error"},"userId":"00000000-0000-0000-0000-000000000001"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
        X-Content-Type-Options: nosniff
        X-Download-Options: noopen
        X-Frame-Options: SAMEORIGIN
        X-Permitted-Cross-Domain-Policies: none
        X-XSS-Protection: 1; mode=block
        """
      }
    }
  }

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
    isOwnerTakingSeat: Bool = true,
    code: Models.Subscription.TeamInviteCode? = nil,
    status: Stripe.Subscription.Status? = nil
  ) async throws -> Models.Subscription {
    var subscription = try await self.database.createSubscription(
      update(.teamYearly) {
        $0.id = .init(UUID().uuidString)
      },
      owner.id,
      isOwnerTakingSeat,
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
    if let status = status {
      subscription.stripeSubscriptionStatus = status
      _ = try await self.database.execute(
        """
        UPDATE "subscriptions"
        SET "stripe_subscription_status" = \(bind: status)
        WHERE "id" = \(bind: subscription.id)
        """
      )
    }
    return subscription
  }
}
