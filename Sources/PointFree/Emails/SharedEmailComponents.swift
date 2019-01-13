import Html
import HtmlCssSupport
import Foundation
import Styleguide
import Prelude
import View

let hostSignOffView = View<Prelude.Unit> { _ in
  [
    p([`class`([Class.padding([.mobile: [.top: 2]])])], [
      "Your hosts,"
      ]),
    p([
      a([href(twitterUrl(to: .mbrandonw))], [.raw("Brandon&nbsp;Williams")]),
      " & ",
      a([href(twitterUrl(to: .stephencelis))], [.raw("Stephen&nbsp;Celis")]),
      ])
  ]
}

let emailFooterView = View<(Database.User?, Database.EmailSetting.Newsletter?)> { user, newsletter in
  emailTable([`class`([Class.pf.colors.bg.gray900]), style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          p([`class`([Class.pf.type.body.small])], [
            "Contact us via email at ",
            a([mailto("support@pointfree.co")], ["support@pointfree.co"]),
            ", or on Twitter ",
            a([href(twitterUrl(to: .pointfreeco))], ["@pointfreeco"]),
            "."
            ]),

          p([`class`([Class.pf.type.body.small])], [
            "Our postal address: 139 Skillman #5C, Brooklyn, NY 11211"
            ]),

          ] + unsubscribeView.view((user, newsletter)))
        ])
      ])
    ])
}

private let unsubscribeView = View<(Database.User?, Database.EmailSetting.Newsletter?)> { user, newsletter -> [Node] in
  guard let user = user, let newsletter = newsletter else { return [] }

  return [
    p([`class`([Class.pf.type.body.small])], [
      .text(subscribedReason(newsletter: newsletter)),
      " If you no longer wish to receive emails like this, you can unsubscribe ",
      a([href(url(to: .expressUnsubscribe(userId: user.id, newsletter: newsletter)))], ["here"]),
      "."
      ])
  ]
}

private func subscribedReason(newsletter: Database.EmailSetting.Newsletter) -> String {
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
public func emailTable(_ attribs: [Attribute<Html.Tag.Table>], _ content: [ChildOf<Html.Tag.Table>]) -> Node {
  return table([border(0), cellpadding(0), cellspacing(0)] + attribs, content)
}
