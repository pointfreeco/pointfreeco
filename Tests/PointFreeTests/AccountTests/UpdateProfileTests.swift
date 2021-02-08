import Either
@testable import GitHub
import HtmlSnapshotTesting
@testable import HttpPipeline
import HttpPipelineTestSupport
import Models
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
@testable import Stripe
import XCTest

class UpdateProfileIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record=true
  }

  func testUpdateNameAndEmail() {
    var user = Current.database.registerUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    user.referralCode = "deadbeef"

    assertSnapshot(
      matching: user,
      as: .dump,
      named: "user_before_update"
    )

    let update = request(
      to: .account(
        .update(ProfileData(email: "blobby@blob.co", extraInvoiceInfo: nil, emailSettings: [:], name: "Blobby McBlob"))
      ),
      session: .init(flash: nil, userId: user.id)
    )

    let output = connection(from: update)
      |> siteMiddleware
      |> Prelude.perform

    user = Current.database.fetchUserById(user.id)
      .run
      .perform()
      .right!!
    user.referralCode = "deadbeef"

    assertSnapshot(
      matching: user,
      as: .dump,
      named: "user_after_update"
    )

    #if !os(Linux)
    assertSnapshot(matching: output, as: .conn)
    #endif
  }

  func testUpdateEmailSettings() {
    let user = Current.database.registerUser(.mock, "hello@pointfree.co", { .mock })
      .run
      .perform()
      .right!!
    let emailSettings = Current.database.fetchEmailSettingsForUserId(user.id)
      .run
      .perform()
      .right!

    assertSnapshot(
      matching: emailSettings,
      as: .dump,
      named: "email_settings_before_update"
    )

    let update = request(
      to: .account(
        .update(.init(email: user.email, extraInvoiceInfo: nil, emailSettings: ["newEpisode": "on"], name: user.name))
      ),
      session: .init(flash: nil, userId: user.id)
    )

    let output = connection(from: update)
      |> siteMiddleware
      |> Prelude.perform

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_after_update"
    )

    #if !os(Linux)
    assertSnapshot(matching: output, as: .conn)
    #endif
  }
}

class UpdateProfileTests: TestCase {
  override func setUp() {
    super.setUp()
//    SnapshotTesting.record=true
  }

  func testUpdateExtraInvoiceInfo() {
    var updatedCustomerWithExtraInvoiceInfo: String!

    var stripeSubscription = Stripe.Subscription.mock
    var stripeCustomer = Stripe.Customer.mock
    stripeCustomer.metadata = ["extraInvoiceInfo": "VAT: 1234567890"]
    stripeSubscription.customer = .right(stripeCustomer)

    Current = .teamYearly
    Current.stripe.fetchSubscription = const(pure(stripeSubscription))
    Current.stripe.updateCustomerExtraInvoiceInfo = { _, info -> EitherIO<Error, Stripe.Customer> in
      updatedCustomerWithExtraInvoiceInfo = info
      return pure(.mock)
    }

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
      session: .init(flash: nil, userId: .init(rawValue: UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!))
    )

    let output = connection(from: update)
      |> siteMiddleware
      |> Prelude.perform

    #if !os(Linux)
    assertSnapshot(matching: output, as: .conn)
    #endif

    XCTAssertEqual("VAT: 123456789", updatedCustomerWithExtraInvoiceInfo)
  }
}
