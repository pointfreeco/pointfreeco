import Dependencies
import Either
import EmailAddress
import FunctionalCss
import Html
import HtmlCssSupport
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Views

func sendGiftEmail(for gift: Gift) -> EitherIO<Error, SendEmailResponse> {
  sendEmail(
    to: ["\(gift.toName) <\(gift.toEmail)>"],
    subject: "\(gift.fromName) sent you \(gift.monthsFree) months of Point-Free!",
    content: inj2(giftEmail(gift))
  )
  .catch(notifyAdmins(subject: "Gift delivery failed"))
}

private let giftEmail =
  simpleEmailLayout(giftEmailBody(gift:)) <<< { gift in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "\(gift.fromName) sent you \(gift.monthsFree) months of Point-Free!",
      preheader: "\(gift.fromName) sent you \(gift.monthsFree) months of Point-Free!",
      template: .default(),
      data: gift
    )
  }

private func giftEmailBody(gift: Gift) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  let quotedMessage = gift.message
    .split(separator: "\n", omittingEmptySubsequences: false)
    .map { "> \($0)" }
    .joined(separator: "\n")
  return [
    .markdownBlock(
      """
      \(gift.fromName) sent you \(gift.monthsFree) months of Point-Free!

      \(quotedMessage)

      [Redeem Your Gift](\(siteRouter.url(for: .gifts(.redeem(gift.id)))))
      """
    )
  ]
}
