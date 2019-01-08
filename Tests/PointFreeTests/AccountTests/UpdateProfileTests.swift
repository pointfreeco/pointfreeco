import Either
import Html
import HtmlSnapshotTesting
import SnapshotTesting
import Prelude
import XCTest
@testable import PointFree
import PointFreeTestSupport
@testable import HttpPipeline
import HttpPipelineTestSupport
import Optics

class UpdateProfileTests: TestCase {
  func testUpdateNameAndEmail() {
    let user = Current.database.registerUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!

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

    assertSnapshot(
      matching: Current.database.fetchUserById(user.id)
        .run
        .perform()
        .right!!,
      as: .dump,
      named: "user_after_update"
    )

    #if !os(Linux)
    assertSnapshot(matching: output, as: .conn)
    #endif
  }

  func testUpdateEmailSettings() {
    let user = Current.database.registerUser(.mock, "hello@pointfree.co")
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

  func testUpdateExtraInvoiceInfo() {
    var updatedCustomerWithExtraInvoiceInfo: String!

    let stripeSubscription = Stripe.Subscription.mock
      |> \.customer .~ .right(
        .mock
          |> \.metadata .~ ["extraInvoiceInfo": "VAT: 1234567890"]
    )

    Current = .teamYearly
      |> \.stripe.fetchSubscription .~ const(pure(stripeSubscription))
      |> \.stripe.updateCustomerExtraInvoiceInfo .~ { _, info -> EitherIO<Error, Stripe.Customer> in
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
      session: .init(flash: nil, userId: Database.User.Id.init(rawValue: UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")!))
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
