import Either
import Html
import Prelude

public let supportEmail: EmailAddress = "Point-Free <support@pointfree.co>"
public let mgDomain = "mg.pointfree.co"

public func prepareEmail(
  from: EmailAddress = supportEmail,
  to: [EmailAddress],
  subject: String,
  unsubscribeData: (Database.User.Id, Database.EmailSetting.Newsletter)? = nil,
  content: Either3<String, [Node], (String, [Node])>,
  domain: String = mgDomain
  )
  -> Email {

    let (plain, html): (String, String?) =
      either3(
        content,
        { plain in (plain, nil) },
        { nodes in (plainText(for: nodes), render(nodes)) },
        second { render($0) }
    )

    let headers: [(String, String)] = unsubscribeData
      .map { userId, newsletter in
        guard let unsubEmail = unsubscribeEmail(fromUserId: userId, andNewsletter: newsletter)
          else { return [] }

        return [
          (
            "List-Unsubscribe",
            """
            <mailto:\(unsubEmail)>, \
            <\(url(to: .expressUnsubscribe(userId: userId, newsletter: newsletter)))>
            """
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

public func send(email: Email) -> EitherIO<Error, Mailgun.SendEmailResponse> {
  return Current.mailgun.sendEmail(email)
}

public func sendEmail(
  from: EmailAddress = supportEmail,
  to: [EmailAddress],
  subject: String,
  unsubscribeData: (Database.User.Id, Database.EmailSetting.Newsletter)? = nil,
  content: Either3<String, [Node], (String, [Node])>,
  domain: String = mgDomain
  )
  -> EitherIO<Error, Mailgun.SendEmailResponse> {

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
