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
    let user = AppEnvironment.current.database.registerUser(.mock, "hello@pointfree.co")
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
    #if !os(Linux)
      let user = AppEnvironment.current.database.registerUser(.mock, "hello@pointfree.co")
        .run
        .perform()
        .right!!

      let unsubEmail = unsubscribeEmail(fromUserId: user.id, andNewsletter: .announcements)!

      let unsubscribe = request(
        to: .expressUnsubscribeReply(
          .init(
            recipient: unsubEmail,
            timestamp: Int(AppEnvironment.current.date().timeIntervalSince1970),
            token: "deadbeef",
            sender: user.email,
            signature: "ab77648a3a922e2aab8b0e309e898a6606d071438b6f2490d381c6ca4aa6d8c9"
          )
        ),
        session: .loggedOut
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
    #endif
  }

  func testExpressUnsubscribeReply_IncorrectSignature() {
    #if !os(Linux)
      let user = AppEnvironment.current.database.registerUser(.mock, "hello@pointfree.co")
        .run
        .perform()
        .right!!

      let unsubEmail = unsubscribeEmail(fromUserId: user.id, andNewsletter: .announcements)!

      let unsubscribe = request(
        to: .expressUnsubscribeReply(
          .init(
            recipient: unsubEmail,
            timestamp: Int(AppEnvironment.current.date().timeIntervalSince1970),
            token: "deadbeef",
            sender: user.email,
            signature: "this is an invalid signature"
          )
        ),
        session: .loggedOut
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
    #endif
  }

  func testExpressUnsubscribeReply_UnknownNewsletter() {
    #if !os(Linux)
      let user = AppEnvironment.current.database.registerUser(.mock, "hello@pointfree.co")
        .run
        .perform()
        .right!!

      let payload = encrypted(
        text: "\(user.id.unwrap.uuidString)--unknown",
        secret: AppEnvironment.current.envVars.appSecret
        )!
      let unsubEmail = EmailAddress(unwrap: "unsub-\(payload)@pointfree.co")

      let unsubscribe = request(
        to: .expressUnsubscribeReply(
          .init(
            recipient: unsubEmail,
            timestamp: Int(AppEnvironment.current.date().timeIntervalSince1970),
            token: "deadbeef",
            sender: user.email,
            signature: "ab77648a3a922e2aab8b0e309e898a6606d071438b6f2490d381c6ca4aa6d8c9"
          )
        ),
        session: .loggedOut
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
    #endif
  }
}
