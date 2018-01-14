import Either
import Html
import Prelude

func sendEmail(
  from: EmailAddress = .init(unwrap: "Point-Free <support@pointfree.co>"),
  to: [EmailAddress],
  subject: String,
  content: Either3<String, [Node], (String, [Node])>,
  domain: String = "mg.pointfree.co"
  )
  -> EitherIO<Unit, SendEmailResponse> {

    let (plain, html): (String, String?) =
      destructure(
        content,
        { plain in (plain, nil) },
        { nodes in (plainText(for: nodes), render(nodes)) },
        second(render)
    )

    return AppEnvironment.current.sendEmail(
      Email(
        from: from,
        to: to,
        cc: nil,
        bcc: nil,
        subject: AppEnvironment.current.envVars.appEnv == .production
          ? subject
          : "[\(AppEnvironment.current.envVars.appEnv)] " + subject,
        text: plain,
        html: html,
        testMode: nil,
        tracking: nil,
        trackingClicks: nil,
        trackingOpens: nil,
        domain: domain,
        headers: []
      )
    )
}

// TODO: move to swift-prelude
private func destructure<A, B, C, D>(
  _ either: Either3<A, B, C>,
  _ a2d: (A) -> D,
  _ b2d: (B) -> D,
  _ c2d: (C) -> D
  )
  -> D {
    switch either {
    case let .left(a):
      return a2d(a)
    case let .right(.left(b)):
      return b2d(b)
    case let .right(.right(.left(c))):
      return c2d(c)
    }
}
