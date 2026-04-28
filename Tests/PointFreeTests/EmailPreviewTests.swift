import Dependencies
import HttpPipeline
import Mailgun
import Models
import PointFreeRouter
import PointFreeTestSupport
import XCTest

@testable import PointFree

final class EmailPreviewTests: TestCase {
  @MainActor
  func testSendTestEmail() async throws {
    let adminUser = User.admin

    let sentEmails = LockIsolated<[Email]>([])

    await withDependencies {
      $0.database.fetchUserById = { _ in adminUser }
      $0.mailgun.sendEmail = { email in
        sentEmails.withValue { $0.append(email) }
        return SendEmailResponse(id: "", message: "")
      }
    } operation: {
      let conn = await siteMiddleware(
        connection(
          from: request(
            to: .admin(.emailPreview(.send(template: .proWelcomeEmail, email: "test@example.com"))),
            session: .loggedIn(as: adminUser)
          )
        )
      )

      XCTAssertEqual(sentEmails.value.flatMap(\.to), ["test@example.com"])
      XCTAssertEqual(sentEmails.value.compactMap(\.cc).flatMap { $0 }, [supportEmail])
      XCTAssertEqual(sentEmails.value.map(\.subject), ["[testing] [Preview] Pro Welcome Email"])

      let body = String(decoding: conn.data, as: UTF8.self)
      XCTAssertTrue(body.contains("Sent a test email to test@example.com."))
    }
  }
}
