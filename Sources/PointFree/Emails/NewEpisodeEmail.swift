import CssReset
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide

let newEpisodeEmail = simpleEmailLayout(newEpisodeEmailContent)
  .contramap { ep, isSubscriber in
    SimpleEmailLayoutData(
      title: "New Point-Free Episode: \(ep.title)",
      preheader: ep.blurb,
      data: (ep, isSubscriber)
    )
}

let newEpisodeEmailContent = View<(Episode, isSubscriber: Bool)> { ep, isSubscriber in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], [.text(encode("Episode #\(ep.sequence)"))]),
          p([.text(encode(ep.blurb))]),
          h4([`class`([Class.pf.type.title4])], ["[Insert image still here...]"])
          ]
          <> nonSubscriberCtaView.view(isSubscriber)
          <> subscriberCtaView.view((ep, isSubscriber))
          <> hostSignOffView.view(unit))
        ])
      ])
    ])
}

private let nonSubscriberCtaView = View<Bool> { isSubscriber -> [Node] in
  guard !isSubscriber else { return [] }

  return [
    p([
      """
      This episode is for subscribers only. To access to it, and all past and future episodes, become a
      subscriber today!
      """
      ]),
    p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
      a([href(url(to: .pricing(nil, nil))), `class`([Class.pf.components.button(color: .purple)])],
        ["Subscribe to Point-Free!"])
      ])
  ]
}

private let subscriberCtaView = View<(Episode, isSubscriber: Bool)> { (ep, isSubscriber) -> [Node] in
  guard isSubscriber else { return [] }

  return [
    p([.text(encode("This episode is 23 minutes long."))]),
    p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
      a([href(url(to: .episode(.left(ep.slug)))), `class`([Class.pf.components.button(color: .purple)])],
        ["Watch now!"])
      ])
  ]
}

let newEpisodeEmailAdminReportEmail = simpleEmailLayout(newEpisodeEmailAdminReportEmailContent)
  .contramap { erroredUsers, totalAttempted in
    SimpleEmailLayoutData(
      title: "New episode email finished sending!",
      preheader: "\(totalAttempted) attempted emails, \(erroredUsers.count) errors",
      data: (erroredUsers, totalAttempted)
    )
}

let newEpisodeEmailAdminReportEmailContent = View<([Database.User], Int)> { erroredUsers, totalAttempted in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], ["New episode email report"]),
          p([
            "A total of ",
            strong([.text(encode("\(totalAttempted)"))]),
            " emails were attempted to be sent, and of those, ",
            strong([.text(encode("\(erroredUsers.count)"))]),
            " emails failed to send. Here is the list of users that we ",
            "had trouble sending to their emails:"
            ]),

          ul(
            erroredUsers.map { user in
              li([
                .text(encode("\(user.name) (\(user.email.unwrap))"))
                ])
            }
          )
          ])
        ])
      ])
    ])
}
