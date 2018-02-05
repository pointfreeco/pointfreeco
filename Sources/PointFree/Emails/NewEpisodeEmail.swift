import Css
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
  .contramap { ep, user, isSubscriber, extraBlurb in
    SimpleEmailLayoutData(
      user: user,
      newsletter: .newEpisode,
      title: "New Point-Free Episode: \(ep.title)",
      preheader: ep.blurb,
      data: (ep, isSubscriber, extraBlurb)
    )
}

private let extraBlurbView = View<String?> { extraBlurb -> [Node] in
  guard let extraBlurb = extraBlurb else { return [] }

  return [
    div(
      [
        `class`(
          [
            Class.padding([.mobile: [.all: 2]]),
            Class.pf.colors.bg.gray900,
            Class.type.italic,
            Class.margin([.mobile: [.bottom: 2]])
          ]
        ),
        style(margin(leftRight: .rem(-1)))
      ],
      [markdownBlock(extraBlurb)]
    )
  ]
}

let newEpisodeEmailContent = View<(Episode, isSubscriber: Bool, extraBlurb: String?)> { ep, isSubscriber, extraBlurb in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 2]])])],

            extraBlurbView.view(extraBlurb)
              <> [

                a([href(url(to: .episode(.left(ep.slug))))], [
                  h3([`class`([Class.pf.type.responsiveTitle4])], [text("#\(ep.sequence): \(ep.title)")]),
                  ]),

                p([.text(encode(ep.blurb))]),
                p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
                  a([href(url(to: .episode(.left(ep.slug))))], [
                    img(src: ep.image, alt: "", [style(maxWidth(.pct(100)))])
                    ])
                  ])
              ]
              <> nonSubscriberCtaView.view((ep, isSubscriber))
              <> subscriberCtaView.view((ep, isSubscriber))
              <> hostSignOffView.view(unit))
        ])
      ])
    ])
}

private let nonSubscriberCtaView = View<(Episode, isSubscriber: Bool)> { (ep, isSubscriber) -> [Node] in
  guard !isSubscriber else { return [] }

  return [
    p([
      """
      This episode is for subscribers only. To access it, and all past and future episodes, become a
      subscriber today!
      """
      ]),
    p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
      a([href(url(to: .pricing(nil))), `class`([Class.pf.components.button(color: .purple)])],
        ["Subscribe to Point-Free!"]
      ),
      a(
        [
          href(url(to: .episode(.left(ep.slug)))),
          `class`([Class.pf.components.button(color: .black, style: .underline), Class.display.inlineBlock])
        ],
        ["Watch preview"]
      )
      ])
  ]
}

private let subscriberCtaView = View<(Episode, isSubscriber: Bool)> { (ep, isSubscriber) -> [Node] in
  guard isSubscriber else { return [] }

  return [
    p([.text(encode("This episode is \(ep.length / 60) minutes long."))]),
    p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
      a([href(url(to: .episode(.left(ep.slug)))), `class`([Class.pf.components.button(color: .purple)])],
        ["Watch now!"])
      ])
  ]
}

let newEpisodeEmailAdminReportEmail = simpleEmailLayout(newEpisodeEmailAdminReportEmailContent)
  .contramap { erroredUsers, totalAttempted in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
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

          ul(erroredUsers.map { user in
            li([.text(encode(user.name.map { "\($0) (\(user.email.unwrap)" } ?? user.email.unwrap))])
          })
          ])
        ])
      ])
    ])
}
