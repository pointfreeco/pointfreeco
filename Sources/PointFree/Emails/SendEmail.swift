import Dependencies
import Either
import EmailAddress
import Foundation
import Html
import HtmlPlainTextPrint
import Mailgun
import Models
import Parsing
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide

public let supportEmail: EmailAddress = "Point-Free <support@pointfree.co>"
public let mgDomain = "mg.pointfree.co"

let expressUnsubscribe = ParsePrint {
  UUID.parser().map(.representing(User.ID.self))
  "--POINT-FREE-BOUNDARY--"
  Rest().map(.string.representing(EmailSetting.Newsletter.self))
}

public func prepareEmail(
  from: EmailAddress = supportEmail,
  to: [EmailAddress],
  cc: [EmailAddress]? = nil,
  bcc: [EmailAddress]? = nil,
  subject: String,
  unsubscribeData: (User.ID, EmailSetting.Newsletter)? = nil,
  content: Either3<String, Node, (String, Node)>,
  domain: String = mgDomain
)
  -> Email
{
  @Dependency(\.envVars) var envVars
  @Dependency(\.logger) var logger
  @Dependency(\.mailgun) var mailgun
  @Dependency(\.siteRouter) var siteRouter

  let (plain, html): (String, String?) =
    either3(
      content,
      { plain in (plain, nil) },
      { node in (plainText(for: node), render(node)) },
      second { render($0) }
    )

  let headers: [(String, String)] =
    unsubscribeData
    .map { userId, newsletter in
      guard
        let unsubEmail = mailgun.unsubscribeEmail(
          fromUserId: userId, andNewsletter: newsletter),
        let unsubUrl = (try? expressUnsubscribe.print((userId, newsletter)))
          .flatMap({ Encrypted(String($0), with: envVars.appSecret) })
          .map({ siteRouter.url(for: .expressUnsubscribe(payload: $0)) })
      else {
        logger.log(.error, "Failed to generate unsubscribe link for user \(userId)")
        return []
      }

      return [
        (
          "List-Unsubscribe",
          "<mailto:\(unsubEmail)>, <\(unsubUrl)>"
        )
      ]
    }
    ?? []

  return Email(
    from: from,
    to: to,
    cc: cc,
    bcc: bcc,
    subject: envVars.appEnv == .production
      ? subject
      : "[\(envVars.appEnv)] " + subject,
    text: plain,
    html: html,
    testMode: nil,
    tracking: nil,
    trackingClicks: nil,
    trackingOpens: nil,
    domain: domain,
    headers: headers
  )
}

public func send(email: Email) async throws -> SendEmailResponse {
  @Dependency(\.mailgun) var mailgun

  return try await mailgun.sendEmail(email)
}

public func sendEmail(
  from: EmailAddress = supportEmail,
  to: [EmailAddress],
  cc: [EmailAddress]? = nil,
  bcc: [EmailAddress]? = nil,
  subject: String,
  unsubscribeData: (User.ID, EmailSetting.Newsletter)? = nil,
  content: Either3<String, Node, (String, Node)>,
  domain: String = mgDomain
) async throws -> SendEmailResponse {
  @Dependency(\.mailgun) var mailgun

  return try await mailgun.sendEmail(
    prepareEmail(
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      subject: subject,
      unsubscribeData: unsubscribeData,
      content: content,
      domain: domain
    )
  )
}

func notifyError(subject: String) -> (Error) -> Prelude.Unit {
  return { error in
    Task {
      var errorDump = ""
      dump(error, to: &errorDump)
      _ = try await sendEmail(
        to: adminEmails,
        subject: "[PointFree Error] \(subject)",
        content: inj1(errorDump)
      )
    }
    return unit
  }
}

func notifyError<R>(subject: String, operation: () async throws -> R) async -> R? {
  do {
    return try await operation()
  } catch {
    Task {
      var errorDump = ""
      dump(error, to: &errorDump)
      _ = try await sendEmail(
        to: adminEmails,
        subject: "[PointFree Error] \(subject)",
        content: inj1(errorDump)
      )
    }
    return nil
  }
}
