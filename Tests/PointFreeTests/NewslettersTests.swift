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

class NewslettersTests: TestCase {
  func testExpressUnsubscribe() {
    let user = AppEnvironment.current.database.registerUser(.mock)
      .run
      .perform()
      .right!!

    let unsubscribe = request(
      to: .expressUnsubscribe(userId: user.id, newsletter: .announcements),
      session: .loggedIn
    )

    assertSnapshot(
      matching: AppEnvironment.current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      named: "email_settings_before_unsubscribe"
    )

    let output = connection(from: unsubscribe)
      |> siteMiddleware
      |> Prelude.perform
    assertSnapshot(matching: output)

    assertSnapshot(
      matching: AppEnvironment.current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      named: "email_settings_after_unsubscribe"
    )
  }
}
