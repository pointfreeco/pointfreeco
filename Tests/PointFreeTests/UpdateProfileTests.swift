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
    #if !os(Linux)
    let user = AppEnvironment.current.database.registerUser(.mock)
      .run
      .perform()
      .right!!

    assertSnapshot(
      matching: user,
      named: "user_before_update"
    )

    let request = authedRequest(
      to: .account(.update(.init(email: .init(unwrap: "blobby@blob.co"), name: "Blobby McBlob", emailSettings: [:]))),
      session: .init(flash: nil, userId: user.id)
      )
      // NB: We are explicitly setting the body here even though the request already has it's body set from
      //     the route printer in order to fix its order.
      |> \.httpBody .~ Data("name=Blobby%20McBlob&&email=blobby@blob.co".utf8)

    let output = connection(from: request)
      |> siteMiddleware
      |> Prelude.perform
    assertSnapshot(matching: output)

    assertSnapshot(
      matching: AppEnvironment.current.database.fetchUserById(user.id)
        .run
        .perform()
        .right!!,
      named: "user_after_update"
    )
    #endif
  }

  func testUpdateEmailSettings() {
    #if !os(Linux)
    let user = AppEnvironment.current.database.registerUser(.mock)
      .run
      .perform()
      .right!!
    let emailSettings = AppEnvironment.current.database.fetchEmailSettingsForUserId(user.id)
      .run
      .perform()
      .right!

    assertSnapshot(
      matching: emailSettings,
      named: "email_settings_before_update"
    )

    let request = authedRequest(
      to: .account(.update(.init(email: .init(unwrap: ""), name: "", emailSettings: ["newEpisode": "on"]))),
      session: .init(flash: nil, userId: user.id)
      )
      // NB: We are explicitly setting the body here even though the request already has it's body set from
      //     the route printer in order to fix its order.
      |> \.httpBody .~ Data("name=&emailSettings[newEpisode]=on&email=".utf8)

    let output = connection(from: request)
      |> siteMiddleware
      |> Prelude.perform
    assertSnapshot(matching: output)

    assertSnapshot(
      matching: AppEnvironment.current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      named: "email_settings_after_update"
    )
    #endif
  }
}
