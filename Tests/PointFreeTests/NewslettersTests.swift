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

class NewslettersTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testExpressUnsubscribe() {
    let user = Current.database.registerUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!

    let unsubscribe = request(
      to: .expressUnsubscribe(userId: user.id, newsletter: .announcements),
      session: .loggedIn
    )

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_before_unsubscribe"
    )

    let output = connection(from: unsubscribe)
      |> siteMiddleware
      |> Prelude.perform
    assertSnapshot(matching: output, as: .conn)

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_after_unsubscribe"
    )
  }

  func testExpressUnsubscribeReply() {
    #if !os(Linux)
    let user = Current.database.registerUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!

    let unsubEmail = unsubscribeEmail(fromUserId: user.id, andNewsletter: .announcements)!

    let unsubscribe = request(
      to: .expressUnsubscribeReply(
        .init(
          recipient: unsubEmail,
          timestamp: Int(Current.date().timeIntervalSince1970),
          token: "deadbeef",
          sender: user.email,
          signature: "ab77648a3a922e2aab8b0e309e898a6606d071438b6f2490d381c6ca4aa6d8c9"
        )
      ),
      session: .loggedOut
    )

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_before_unsubscribe"
    )

    let output = connection(from: unsubscribe)
      |> siteMiddleware
      |> Prelude.perform
    assertSnapshot(matching: output, as: .conn)

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_after_unsubscribe"
    )
    #endif
  }

  func testExpressUnsubscribeReply_IncorrectSignature() {
    #if !os(Linux)
    update(&Current, \.renderHtml .~ { debugRender($0) })

    let user = Current.database.registerUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!

    let unsubEmail = unsubscribeEmail(fromUserId: user.id, andNewsletter: .announcements)!

    let unsubscribe = request(
      to: .expressUnsubscribeReply(
        .init(
          recipient: unsubEmail,
          timestamp: Int(Current.date().timeIntervalSince1970),
          token: "deadbeef",
          sender: user.email,
          signature: "this is an invalid signature"
        )
      ),
      session: .loggedOut
    )

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_before_unsubscribe"
    )

    let output = connection(from: unsubscribe)
      |> siteMiddleware
      |> Prelude.perform
    assertSnapshot(matching: output, as: .conn)

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_after_unsubscribe"
    )
    #endif
  }

  func testExpressUnsubscribeReply_UnknownNewsletter() {
    #if !os(Linux)
    let user = Current.database.registerUser(.mock, "hello@pointfree.co")
      .run
      .perform()
      .right!!

    let payload = encrypted(
      text: "\(user.id.rawValue.uuidString)--unknown",
      secret: Current.envVars.appSecret
      )!
    let unsubEmail = EmailAddress(rawValue: "unsub-\(payload)@pointfree.co")

    let unsubscribe = request(
      to: .expressUnsubscribeReply(
        .init(
          recipient: unsubEmail,
          timestamp: Int(Current.date().timeIntervalSince1970),
          token: "deadbeef",
          sender: user.email,
          signature: "ab77648a3a922e2aab8b0e309e898a6606d071438b6f2490d381c6ca4aa6d8c9"
        )
      ),
      session: .loggedOut
    )

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_before_unsubscribe"
    )

    let output = connection(from: unsubscribe)
      |> siteMiddleware
      |> Prelude.perform
    assertSnapshot(matching: output, as: .conn)

    assertSnapshot(
      matching: Current.database.fetchEmailSettingsForUserId(user.id)
        .run
        .perform()
        .right!,
      as: .dump,
      named: "email_settings_after_unsubscribe"
    )
    #endif
  }
}
