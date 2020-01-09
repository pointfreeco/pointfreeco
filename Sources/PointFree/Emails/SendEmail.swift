import ApplicativeRouter
import Either
import Html
import HtmlPlainTextPrint
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide

public let supportEmail: EmailAddress = "Point-Free <support@pointfree.co>"
public let mgDomain = "mg.pointfree.co"

let expressUnsubscribeIso: PartialIso<String, (User.Id, EmailSetting.Newsletter)>
  = payload(.tagged(.uuid), .rawRepresentable)

public func prepareEmail(
  from: EmailAddress = supportEmail,
  to: [EmailAddress],
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
          let unsubUrl = expressUnsubscribeIso
            .unapply((userId, newsletter))
            .flatMap({ Encrypted($0, with: Current.envVars.appSecret) })
            .map({ url(to: .expressUnsubscribe(payload: $0)) })
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
      cc: nil,
      bcc: nil,
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
  return Current.mailgun.sendEmail(email)
}

public func sendEmail(
  from: EmailAddress = supportEmail,
  to: [EmailAddress],
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
