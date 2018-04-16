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

let newBlogPostEmail = simpleEmailLayout(newBlogPostEmailContent)
  .contramap { post, subscriberAnnouncement, nonSubscriberAnnouncement, user in
    SimpleEmailLayoutData(
      user: user,
      newsletter: .newBlogPost,
      title: "New Point-Free Pointer: \(post.title)",
      preheader: post.blurb,
      data: (
        post,
        user.subscriptionId != nil
          ? subscriberAnnouncement
          : nonSubscriberAnnouncement,
        user.subscriptionId != nil
      )
    )
}

let newBlogPostEmailContent = View<(BlogPost, String?, isSubscriber: Bool)> { post, announcement, isSubscriber in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],

            announcementView.view(announcement) <> [

              a([href(url(to: .blog(.show(.right(post.id.unwrap)))))], [
                h3([`class`([Class.pf.type.responsiveTitle3])], [text(post.title)]),
                ]),
              p([.text(encode(post.blurb))]),
              p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
                a([href(url(to: .blog(.show((.right(post.id.unwrap))))))], [
                  img(src: post.coverImage, alt: "", [style(maxWidth(.pct(100)))])
                  ])
                ])
              ]
              <> nonSubscriberCtaView.view((post, isSubscriber))
              <> subscriberCtaView.view((post, isSubscriber))
              <> hostSignOffView.view(unit))
        ])
      ])
    ])
}

private let announcementView = View<String?> { announcement -> [Node] in
  guard let announcement = announcement, !announcement.isEmpty else { return [] }

  return [
    blockquote(
      [
        `class`(
          [
            Class.padding([.mobile: [.all: 2]]),
            Class.margin([.mobile: [.leftRight: 0, .topBottom: 3]]),
            Class.pf.colors.bg.blue900,
            Class.type.italic
          ]
        )
      ],
      [
        h5([`class`([Class.pf.type.title5])], ["Announcements"]),
        markdownBlock(announcement)
      ]
    )
  ]
}

private let nonSubscriberCtaView = View<(BlogPost, isSubscriber: Bool)> { post, isSubscriber -> [Node] in
  guard !isSubscriber else { return [] }

  let blurb = true // ep.subscriberOnly
    ? "This episode is for subscribers only. To access it, and all past and future episodes, become a subscriber today!"
    : "This episode is free for everyone, made possible by our subscribers. Consider becoming a subscriber today!"

  let watchText = true // ep.subscriberOnly
    ? "Watch preview"
    : "Watch"

  return [
    p([text(blurb)]),
    p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
      a([href(url(to: .pricing(nil, expand: nil))), `class`([Class.pf.components.button(color: .purple)])],
        ["Subscribe to Point-Free!"]
      ),
      a(
        [
          href(url(to: .blog(.show(.right(post.id.unwrap))))),
          `class`([Class.pf.components.button(color: .black, style: .underline), Class.display.inlineBlock])
        ],
        [text(watchText)]
      )
      ])
  ]
}

private let subscriberCtaView = View<(BlogPost, isSubscriber: Bool)> { (post, isSubscriber) -> [Node] in
  guard isSubscriber else { return [] }

  return [
//    p([.text(encode("This episode is \(ep.length / 60) minutes long."))]),
//    p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
//      a([href(url(to: .episode(.left(ep.slug)))), `class`([Class.pf.components.button(color: .purple)])],
//        ["Watch now!"])
//      ])
  ]
}

let newBlogPostEmailAdminReportEmail = simpleEmailLayout(newBlogPostEmailAdminReportEmailContent)
  .contramap { erroredUsers, totalAttempted in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "New blog post email finished sending!",
      preheader: "\(totalAttempted) attempted emails, \(erroredUsers.count) errors",
      data: (erroredUsers, totalAttempted)
    )
}

let newBlogPostEmailAdminReportEmailContent = View<([Database.User], Int)> { erroredUsers, totalAttempted in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div([`class`([Class.padding([.mobile: [.all: 1], .desktop: [.all: 2]])])], [
          h3([`class`([Class.pf.type.title3])], ["New blog post email report"]),
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
