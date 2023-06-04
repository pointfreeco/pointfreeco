import Dependencies
import EmailAddress
import Mailgun
import Models
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
    //isRecording = true
  }

  override func invokeTest() {
    self.mockBaseDependencies = false
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
      let conn = connection(from: request(to: .join(.landing(code: "deadbeef"))))
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          GET http://localhost:8080/join/deadbeef
          Cookie: pf_session={}

          200 OK
          Content-Length: 174
          Content-Type: text/html; charset=utf-8
          Referrer-Policy: strict-origin-when-cross-origin
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block

          Do you want to join Blob's subscription?

          <form action="/join/deadbeef" method="post">

            <input type="hidden" name="code" value="deadbeef">
            <input type="submit">
          </form>
          """)
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
      let conn = connection(from: request(to: .join(.landing(code: "pointfree.co"))))
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
      let conn = connection(from: request(to: .join(.landing(code: "deadbeef"))))
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
          """)
    }
  }

  func testJoin_LoggedOut() async throws {
    let user = User.mock
    try await withDependencies {
      $0.database.fetchLivestreams = { [] }
      $0.date = .constant(.mock)
      $0.uuid = .incrementing
    } operation: {
      let secret = try JoinSecretConversion().unapply(
        ("deadbeef", user.id, Int(Date.mock.timeIntervalSince1970))
      )
      let conn = connection(from: request(to: .join(.confirm(code: "deadbeef", secret: secret))))
      await _assertInlineSnapshot(
        matching: await siteMiddleware(conn), as: .conn,
        with: """
          GET http://localhost:8080/join/deadbeef/confirm/309df8a272a74d37b902df4f8e7eacc25b064c5c66954cff243a12787dcd45e2b416a8e524eafdcb08a1b82c003867d90807255e3048d8431db6df5aee13a14bfe6b08719418957c9f259750c2758aa3d47fedc6da90f7
          Cookie: pf_session={}

          302 Found
          Location: /login?redirect=http://localhost:8080/join/deadbeef/confirm/309df8a272a74d37b902df4f8e7eacc25b064c5c66954cff243a12787dcd45e2b416a8e524eafdcb08a1b82c003867d90807255e3048d8431db6df5aee13a14bfe6b08719418957c9f259750c2758aa3d47fedc6da90f7
          Referrer-Policy: strict-origin-when-cross-origin
          X-Content-Type-Options: nosniff
          X-Download-Options: noopen
          X-Frame-Options: SAMEORIGIN
          X-Permitted-Cross-Domain-Policies: none
          X-XSS-Protection: 1; mode=block
          """)
    }
  }
}

@MainActor
class JoinMiddlewareIntegrationTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  override func setUp() async throws {
    try await super.setUp()
    //isRecording = true
  }

  override func invokeTest() {
    self.mockBaseDependencies = false
    super.invokeTest()
  }

  func testJoin_LoggedIn_Code() async throws {
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-user"),
        gitHubUser: .init(createdAt: .mock, id: 1, name: "Blob")
      ),
      email: "blob@pointfree.co",
      now: { .mock }
    )
    let owner = try await self.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-owner"),
        gitHubUser: .init(createdAt: .mock, id: 2, name: "Blob Sr")
      ),
      email: "blob.sr@pointfree.co",
      now: { .mock }
    )
    let subscription = try await self.database.createSubscription(.teamYearly, owner.id, true, nil)

    let sentEmails = LockIsolated<[Email]>([])
    let updatedSubscription = LockIsolated<(Stripe.Subscription, Plan.ID, Int)?>(nil)

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.mailgun.sendEmail = { email in
        sentEmails.withValue { $0.append(email) }
        return SendEmailResponse(id: "", message: "")
      }
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.stripe.updateSubscription = { subscription, plan, quantity in
        updatedSubscription.setValue((subscription, plan, quantity))
        var subscription = subscription
        subscription.plan = plan == .monthly ? .individualMonthly : .individualYearly
        subscription.quantity = quantity
        return subscription
      }
      $0.uuid = .incrementing
    } operation: {
      let conn = connection(
        from: request(
          to: .join(.join(code: subscription.teamInviteCode, email: nil)),
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
          """)

      XCTAssertNoDifference(
        Set(sentEmails.value.flatMap(\.to)),
        [EmailAddress("blob@pointfree.co"), EmailAddress("blob.sr@pointfree.co")]
      )
      XCTAssertNoDifference(
        Set(sentEmails.value.map(\.subject)),
        [
          "[testing] Blob has joined your Point-Free subscription",
          "[testing] You have joined Blob Sr's Point-Free subscription"
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
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-user"),
        gitHubUser: .init(createdAt: .mock, id: 1, name: "Blob")
      ),
      email: "blob@pointfree.co",
      now: { .mock }
    )
    let owner = try await self.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-owner"),
        gitHubUser: .init(createdAt: .mock, id: 2, name: "Blob Sr")
      ),
      email: "blob.sr@pointfree.co",
      now: { .mock }
    )
    var subscription = try await self.database.createSubscription(.teamYearly, owner.id, true, nil)
    subscription.teamInviteCode = "pointfree.co"
    _ = try await self.database.execute(
      """
      UPDATE "subscriptions"
      SET "team_invite_code" = \(bind: subscription.teamInviteCode)
      WHERE "id" = \(bind: subscription.id)
      """
    )

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
          to: .join(.join(code: subscription.teamInviteCode, email: currentUser.email)),
          session: .loggedIn(as: currentUser)
        )
      )
      await _assertInlineSnapshot(matching: await siteMiddleware(conn), as: .conn, with: """
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
      """)

      XCTAssertEqual(sentEmails.value.flatMap(\.to), [currentUser.email])
      XCTAssertNoDifference(
        sentEmails.value.map(\.subject),
        ["[testing] Confirm your email to join the Point-Free team subscription."]
      )
      let teammateIDs = try await self.database.fetchSubscriptionTeammatesByOwnerId(owner.id).map(\.id)
      XCTAssertEqual(teammateIDs, [owner.id])
    }
  }

  // TODO: test join: non-active subscription
  // TODO: test join: logged out
  // TODO: test join: invalid team code
  // TODO: test join: unused team seats (with and without owner taking seat)
  // TODO: test join: current user has active subscription
  // TODO: test join: expired link

  func testConfirm_LoggedIn_Domain() async throws {
    let currentUser = try await self.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-user"),
        gitHubUser: .init(createdAt: .mock, id: 1, name: "Blob")
      ),
      email: "blob@pointfree.co",
      now: { .mock }
    )
    let owner = try await self.database.registerUser(
      withGitHubEnvelope: .init(
        accessToken: .init(accessToken: "deadbeef-owner"),
        gitHubUser: .init(createdAt: .mock, id: 2, name: "Blob Sr")
      ),
      email: "blob.sr@pointfree.co",
      now: { .mock }
    )
    var subscription = try await self.database.createSubscription(.teamYearly, owner.id, true, nil)
    subscription.teamInviteCode = "pointfree.co"
    _ = try await self.database.execute(
      """
      UPDATE "subscriptions"
      SET "team_invite_code" = \(bind: subscription.teamInviteCode)
      WHERE "id" = \(bind: subscription.id)
      """
    )

    let sentEmails = LockIsolated<[Email]>([])
    let updatedSubscription = LockIsolated<(Stripe.Subscription, Plan.ID, Int)?>(nil)

    try await withDependencies {
      $0.date = .constant(.mock)
      $0.mailgun.sendEmail = { email in
        sentEmails.withValue { $0.append(email) }
        return SendEmailResponse(id: "", message: "")
      }
      $0.stripe.fetchSubscription = { _ in .mock }
      $0.stripe.updateSubscription = { subscription, plan, quantity in
        updatedSubscription.setValue((subscription, plan, quantity))
        var subscription = subscription
        subscription.plan = plan == .monthly ? .individualMonthly : .individualYearly
        subscription.quantity = quantity
        return subscription
      }
      $0.uuid = .incrementing
    } operation: {
      let secret = try JoinSecretConversion().unapply(
        (subscription.teamInviteCode, currentUser.id, Int(Date.mock.timeIntervalSince1970))
      )
      let conn = connection(
        from: request(
          to: .join(.confirm(code: subscription.teamInviteCode, secret: secret)),
          session: .loggedIn(as: currentUser)
        )
      )
      await _assertInlineSnapshot(matching: await siteMiddleware(conn), as: .conn, with: """
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
      """)

      XCTAssertEqual(
        Set(sentEmails.value.flatMap(\.to)),
        ["blob.sr@pointfree.co", "blob@pointfree.co"]
      )
      XCTAssertEqual(
        Set(sentEmails.value.map(\.subject)),
        [
          "[testing] Blob has joined your Point-Free subscription",
          "[testing] You have joined Blob Sr's Point-Free subscription"
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
}

import CustomDump
