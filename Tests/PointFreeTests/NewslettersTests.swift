import EmailAddress
import Html
import HtmlSnapshotTesting
import HttpPipelineTestSupport
import Models
import ModelsTestSupport
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import GitHub
@testable import HttpPipeline
@testable import PointFree

@MainActor
class NewslettersIntegrationTests: LiveDatabaseTestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.isRecording = true
  }

  func testExpressUnsubscribe() async throws {
    let user = try await Current.database.registerUser(
      withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
    )
    .performAsync()!

    let payload = try XCTUnwrap(
      Encrypted(
        String(expressUnsubscribe.print((user.id, .announcements))), with: Current.envVars.appSecret
      )
    )

    let unsubscribe = request(
      to: .expressUnsubscribe(payload: payload),
      session: .loggedIn
    )

    var settings = try await Current.database.fetchEmailSettingsForUserId(user.id).performAsync()
    assertSnapshot(
      matching: settings,
      as: .customDump,
      named: "email_settings_before_unsubscribe"
    )

    let output = await siteMiddleware(connection(from: unsubscribe)).performAsync()
    assertSnapshot(matching: output, as: .conn)

    settings = try await Current.database.fetchEmailSettingsForUserId(user.id).performAsync()
    assertSnapshot(
      matching: settings,
      as: .customDump,
      named: "email_settings_after_unsubscribe"
    )
  }

  func testExpressUnsubscribeReply() async throws {
    #if !os(Linux)
      let user = try await Current.database.registerUser(
        withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
      )
      .performAsync()!

      let unsubEmail = Current.mailgun.unsubscribeEmail(
        fromUserId: user.id, andNewsletter: .announcements)!

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

      var settings = try await Current.database.fetchEmailSettingsForUserId(user.id).performAsync()
      assertSnapshot(
        matching: settings,
        as: .customDump,
        named: "email_settings_before_unsubscribe"
      )

      let output = await siteMiddleware(connection(from: unsubscribe)).performAsync()
      assertSnapshot(matching: output, as: .conn)

      settings = try await Current.database.fetchEmailSettingsForUserId(user.id).performAsync()
      assertSnapshot(
        matching: settings,
        as: .customDump,
        named: "email_settings_after_unsubscribe"
      )
    #endif
  }

  func testExpressUnsubscribeReply_IncorrectSignature() async throws {
    #if !os(Linux)
      let user = try await Current.database.registerUser(
        withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
      )
      .performAsync()!

      let unsubEmail = Current.mailgun.unsubscribeEmail(
        fromUserId: user.id, andNewsletter: .announcements)!

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

      var settings = try await Current.database.fetchEmailSettingsForUserId(user.id).performAsync()
      assertSnapshot(
        matching: settings,
        as: .customDump,
        named: "email_settings_before_unsubscribe"
      )

      let output = await siteMiddleware(connection(from: unsubscribe)).performAsync()
      assertSnapshot(matching: output, as: .conn)

      settings = try await Current.database.fetchEmailSettingsForUserId(user.id).performAsync()
      assertSnapshot(
        matching: settings,
        as: .customDump,
        named: "email_settings_after_unsubscribe"
      )
    #endif
  }

  func testExpressUnsubscribeReply_UnknownNewsletter() async throws {
    #if !os(Linux)
      let user = try await Current.database.registerUser(
        withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock }
      )
      .performAsync()!

      let payload = encrypted(
        text: "\(user.id.rawValue.uuidString)--unknown",
        secret: Current.envVars.appSecret.rawValue,
        nonce: [0x30, 0x9D, 0xF8, 0xA2, 0x72, 0xA7, 0x4D, 0x37, 0xB9, 0x02, 0xDF, 0x4F]
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

      var settings = try await Current.database.fetchEmailSettingsForUserId(user.id).performAsync()
      assertSnapshot(
        matching: settings,
        as: .customDump,
        named: "email_settings_before_unsubscribe"
      )

      let output = await siteMiddleware(connection(from: unsubscribe)).performAsync()
      assertSnapshot(matching: output, as: .conn)

      settings = try await Current.database.fetchEmailSettingsForUserId(user.id).performAsync()
      assertSnapshot(
        matching: settings,
        as: .customDump,
        named: "email_settings_after_unsubscribe"
      )
    #endif
  }
}
