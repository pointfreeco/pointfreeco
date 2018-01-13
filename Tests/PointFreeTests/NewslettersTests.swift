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

  func testExpressUnsubscribeReply() {
    record = true

    let user = AppEnvironment.current.database.registerUser(.mock)
      .run
      .perform()
      .right!!

    let unsubscribe = request(
      to: .expressUnsubscribeReply(
        .init(
          recipient: user.email.unwrap,
          timestamp: Int(AppEnvironment.current.date().timeIntervalSince1970),
          token: "deadbeef",
          sender: "express-unsubscribe-announcements@pointfree.co",
          signature: "94df20262fa6ac5a6611a6b48490784a38876ffc2767c47e4e2bdb2b0ca649e6"
        )
      ),
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
