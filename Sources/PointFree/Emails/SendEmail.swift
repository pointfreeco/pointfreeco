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
  UUID.parser().map(.representing(User.Id.self))
  "--POINT-FREE-BOUNDARY--"
  Rest().map(.string.representing(EmailSetting.Newsletter.self))
}

public func prepareEmail(
  from: EmailAddress = supportEmail,
  to: [EmailAddress],
  cc: [EmailAddress]? = nil,
  bcc: [EmailAddress]? = nil,
  subject: String,
  unsubscribeData: (User.Id, EmailSetting.Newsletter)? = nil,
  content: Either3<String, Node, (String, Node)>,
  domain: String = mgDomain
  )
  -> Email {

    let (plain, html): (String, String?) =
      either3(
        content,
        { plain in (plain, nil) },
        { node in (plainText(for: node), render(node)) },
        second { render($0) }
    )

    let headers: [(String, String)] = unsubscribeData
      .map { userId, newsletter in
        guard
          let unsubEmail = Current.mailgun.unsubscribeEmail(fromUserId: userId, andNewsletter: newsletter),
          let unsubUrl = (try? expressUnsubscribe.print((userId, newsletter)))
            .flatMap({ Encrypted(String($0), with: Current.envVars.appSecret) })
            .map({ siteRouter.url(for: .expressUnsubscribe(payload: $0)) })
          else {
            Current.logger.log(.error, "Failed to generate unsubscribe link for user \(userId)")
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
      subject: Current.envVars.appEnv == .production
        ? subject
        : "[\(Current.envVars.appEnv)] " + subject,
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

public func send(email: Email) -> EitherIO<Error, SendEmailResponse> {
  Current.mailgun.sendEmail(email)
}

public func sendEmail(
  from: EmailAddress = supportEmail,
  to: [EmailAddress],
  cc: [EmailAddress]? = nil,
  bcc: [EmailAddress]? = nil,
  subject: String,
  unsubscribeData: (User.Id, EmailSetting.Newsletter)? = nil,
  content: Either3<String, Node, (String, Node)>,
  domain: String = mgDomain
  )
  -> EitherIO<Error, SendEmailResponse> {

    return Current.mailgun.sendEmail(
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
    var errorDump = ""
    dump(error, to: &errorDump)

    parallel(
      sendEmail(
        to: adminEmails,
        subject: "[PointFree Error] \(subject)",
        content: inj1(errorDump)
        ).run
      ).run { _ in }

    return unit
  }
}
