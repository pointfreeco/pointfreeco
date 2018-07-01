import Either
import Html
import Prelude

public func sendEmail(
  from: EmailAddress = "Point-Free <support@pointfree.co>",
  to: [EmailAddress],
  subject: String,
  unsubscribeData: (Database.User.Id, Database.EmailSetting.Newsletter)? = nil,
  content: Either3<String, [Node], (String, [Node])>,
  domain: String = "mg.pointfree.co"
  )
  -> EitherIO<Error, Mailgun.SendEmailResponse> {

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

    return Current.mailgun.sendEmail(
      Email(
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
