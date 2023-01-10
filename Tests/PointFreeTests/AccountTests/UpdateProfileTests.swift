import Dependencies
import Either
import HtmlSnapshotTesting
import HttpPipelineTestSupport
import Models
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import GitHub
@testable import HttpPipeline
@testable import PointFree
@testable import Stripe

@MainActor
class UpdateProfileIntegrationTests: LiveDatabaseTestCase {
  @Dependency(\.database) var database

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testUpdateNameAndEmail() async throws {
    var user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )
    user.referralCode = "deadbeef"

    await assertSnapshot(
      matching: user,
      as: .customDump,
      named: "user_before_update"
    )

    let update = request(
      to: .account(
        .update(
          ProfileData(
            email: "blobby@blob.co", extraInvoiceInfo: nil, emailSettings: [:],
            name: "Blobby McBlob"))
      ),
      session: .init(flash: nil, userId: user.id)
    )

    let output = await siteMiddleware(connection(from: update))

    user = try await self.database.fetchUserById(user.id)
    user.referralCode = "deadbeef"

    await assertSnapshot(
      matching: user,
      as: .customDump,
      named: "user_after_update"
    )

    #if !os(Linux)
      await assertSnapshot(matching: output, as: .conn)
    #endif
  }

  func testUpdateEmailSettings() async throws {
    let user = try await self.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )
    let emailSettings = try await self.database.fetchEmailSettingsForUserId(user.id)

    await assertSnapshot(
      matching: emailSettings,
      as: .customDump,
      named: "email_settings_before_update"
    )

    let update = request(
      to: .account(
        .update(
          .init(
            email: user.email, extraInvoiceInfo: nil, emailSettings: ["newEpisode": "on"],
            name: user.name))
      ),
      session: .init(flash: nil, userId: user.id)
    )

    let output = await siteMiddleware(connection(from: update))

    let settings = try await self.database.fetchEmailSettingsForUserId(user.id)
    await assertSnapshot(
      matching: settings,
      as: .customDump,
      named: "email_settings_after_update"
    )

    #if !os(Linux)
      await assertSnapshot(matching: output, as: .conn)
    #endif
  }
}

@MainActor
class UpdateProfileTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testUpdateExtraInvoiceInfo() async throws {
    var updatedCustomerWithExtraInvoiceInfo: String!

    var stripeSubscription = Stripe.Subscription.mock
    var stripeCustomer = Stripe.Customer.mock
    stripeCustomer.metadata = ["extraInvoiceInfo": "VAT: 1234567890"]
    stripeSubscription.customer = .right(stripeCustomer)

    await withDependencies {
      $0.teamYearly()
      $0.stripe.fetchSubscription = { _ in stripeSubscription }
      $0.stripe.updateCustomerExtraInvoiceInfo = { _, info in
        updatedCustomerWithExtraInvoiceInfo = info
        return .mock
      }
    } operation: {
      let update = request(
        to: .account(
          .update(
            .init(
              email: "blob@pointfree.co",
              extraInvoiceInfo: "VAT: 123456789",
              emailSettings: ["newEpisode": "on"],
              name: "Blob"
            )
          )
        ),
        session: .init(
          flash: nil,
          userId: .init(rawValue: UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!))
      )

      let output = await siteMiddleware(connection(from: update))

      #if !os(Linux)
        await assertSnapshot(matching: output, as: .conn)
      #endif

      XCTAssertEqual("VAT: 123456789", updatedCustomerWithExtraInvoiceInfo)
    }
  }
}
