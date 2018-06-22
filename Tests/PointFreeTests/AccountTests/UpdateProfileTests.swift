import Html
import HtmlTestSupport
import HtmlPrettyPrint
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
      named: "user_after_update"
    )

    #if !os(Linux)
      assertSnapshot(matching: output)
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
      named: "email_settings_after_update"
    )

    #if !os(Linux)
      assertSnapshot(matching: output)
    #endif
  }
}
