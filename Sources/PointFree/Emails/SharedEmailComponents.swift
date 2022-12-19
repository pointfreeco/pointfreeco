import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

let hostSignOffView: Node = [
  .p(
    attributes: [.class([Class.padding([.mobile: [.top: 2]])])],
    "Your hosts,"
  ),
  .p(
    .a(
      attributes: [.href(twitterRouter.url(for: .mbrandonw).absoluteString)],
      .raw("Brandon&nbsp;Williams")),
    " & ",
    .a(
      attributes: [.href(twitterRouter.url(for: .stephencelis).absoluteString)],
      .raw("Stephen&nbsp;Celis"))
  ),
]

func emailFooterView(user: User?, newsletter: EmailSetting.Newsletter?) -> Node {
  return .emailTable(
    attributes: [.class([Class.pf.colors.bg.gray900]), .style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 2]])])],
          .p(
            attributes: [.class([Class.pf.type.body.small])],
            "Contact us via email at ",
            .a(attributes: [.mailto("support@pointfree.co")], "support@pointfree.co"),
            ", on Mastodon ",
            .a(
              attributes: [.href("http://hachyderm.io/@pointfreeco")],
              "@pointfreeco"),
            ", or on Twitter ",
            .a(
              attributes: [.href(twitterRouter.url(for: .pointfreeco).absoluteString)],
              "@pointfreeco"),
            "."
          ),
          .p(
            attributes: [.class([Class.pf.type.body.small])],
            "Our postal address: 139 Skillman #5C, Brooklyn, NY 11211"
          ),
          unsubscribeView(user: user, newsletter: newsletter)
        )
      )
    )
  )
}

private func unsubscribeView(user: User?, newsletter: EmailSetting.Newsletter?) -> Node {
  guard
    let user = user,
    let newsletter = newsletter
  else { return [] }

  guard
    let unsubUrl = (try? expressUnsubscribe.print((user.id, newsletter)))
      .flatMap({ Encrypted(String($0), with: Current.envVars.appSecret) })
      .map({ siteRouter.url(for: .expressUnsubscribe(payload: $0)) })
  else {
    Current.logger.log(.error, "Failed to generate unsubscribe link for user \(user.id)")
    return []
  }

  return .p(
    attributes: [.class([Class.pf.type.body.small])],
    .text(subscribedReason(newsletter: newsletter)),
    " If you no longer wish to receive emails like this, you can unsubscribe ",
    .a(attributes: [.href(unsubUrl)], "here"),
    "."
  )
}

private func subscribedReason(newsletter: EmailSetting.Newsletter) -> String {
  switch newsletter {
  case .announcements:
    return """
      You are receiving this email because you expressed interest in hearing about new announcements,
      such as new features and new projects of ours.
      """
  case .newBlogPost:
    return """
      You are receiving this email because you expressed interest in being notified about new posts on our
      blog, Point-Free Pointers.
      """
  case .newEpisode:
    return """
      You are receiving this email because you wanted to be notified whenever a new episode is available.
      """
  case .welcomeEmails:
    return """
      You are receiving this email because you recently signed up for Point-Free.
      """
  }
}

// TODO: move into a package for html email helpers.
extension Node {
  public static func emailTable(
    attributes: [Attribute<Tag.Table>],
    _ content: ChildOf<Tag.Table>...
  ) -> Node {
    return .table(
      attributes: [.border(0), .cellpadding(0), .cellspacing(0)] + attributes, .fragment(content))
  }
}
