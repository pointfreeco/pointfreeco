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
    let user = AppEnvironment.current.database.registerUser(.mock)
      .run
      .perform()
      .right!!
    
    assertSnapshot(
      matching: user,
      named: "user_before_update"
    )
    
    let update = request(
      to: .account(.update(.init(email: .init(unwrap: "blobby@blob.co"), name: "Blobby McBlob", emailSettings: [:]))),
      session: .init(flash: nil, userId: user.id)
    )
    
    let output = connection(from: update)
      |> siteMiddleware
      |> Prelude.perform
    
    assertSnapshot(
      matching: AppEnvironment.current.database.fetchUserById(user.id)
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
    
    let update = request(
      to: .account(.update(.init(email: user.email, name: user.name, emailSettings: ["newEpisode": "on"]))),
      session: .init(flash: nil, userId: user.id)
    )
    
    let output = connection(from: update)
      |> siteMiddleware
      |> Prelude.perform
    
    assertSnapshot(
      matching: AppEnvironment.current.database.fetchEmailSettingsForUserId(user.id)
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
