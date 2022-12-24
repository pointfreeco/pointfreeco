import Either
import FunctionalCss
import Html
import Mailgun
import Models
import Prelude

func sendInvalidRssFeedEmail(user: User, userAgent: String) -> EitherIO<Error, SendEmailResponse> {
  EitherIO {
    try await sendEmail(
      to: [user.email],
      bcc: ["support@pointfree.co"],
      subject: "Private RSS Feed",
      content: inj2(invalidRssFeedEmail((user, userAgent)))
    )
  }
}

let invalidRssFeedEmail =
  simpleEmailLayout(invalidRssFeedEmailBody(user:userAgent:)) <<< { user, userAgent in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "Private RSS Feed",
      preheader: "We detected that your private RSS feed URL was shared.",
      template: .default(includeHeaderImage: false),
      data: (user, userAgent)
    )
  }

private func invalidRssFeedEmailBody(user: User, userAgent: String) -> Node {
  .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])], "Private RSS Feed"
          ),
          .markdownBlock(
            """
            Hi there,

            We detected that your private RSS feed URL was shared\(shareQualifier(userAgent: userAgent)). To protect your account, your RSS feed has been deactivated and a new URL has been generated for you, which is available on your [account](https://www.pointfree.co/account) page.

            Please note that the RSS feed URL we provide to you is private to only you and should not be shared externally. If you would like to share Point-Free with friends or colleagues, please consider purchasing a [team](https://www.pointfree.co/pricing) subscription by adding them to your [account](https://www.pointfree.co/account), or send them a [gift subscription](https://www.pointfree.co/gifts).
            """)
        )
      )
    )
  )
}

private func shareQualifier(userAgent: String) -> String {
  if userAgent.contains("slack") {
    return " on Slack"
  } else if userAgent.contains("telegram") {
    return " on Telegram"
  } else if userAgent.contains("whatsapp") {
    return " on WhatsApp"
  } else if userAgent.contains("twitter") || userAgent.contains("facebook") {
    return " on a messaging app (e.g. iMessage, Twitter DM, etc.)"
  }
  return ""
}
