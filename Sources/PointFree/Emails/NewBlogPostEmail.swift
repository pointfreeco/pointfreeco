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
      title: "Point-Free Pointer: \(post.title)",
      preheader: post.blurb,
      template: .blog,
      data: (
        post,
        user.subscriptionId != nil
          ? subscriberAnnouncement
          : nonSubscriberAnnouncement
      )
    )
}

let newBlogPostEmailContent = View<(BlogPost, String?)> { post, announcement in
  emailTable([style(contentTableStyles)], [
    tr([
      td([valign(.top)], [
        div(
          [`class`([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],
          announcementView.view(announcement)
        ),

        div([`class`([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])], [
          a([href(url(to: .blog(.show(.right(post.id.unwrap)))))], [
            h3([`class`([Class.pf.type.responsiveTitle3])], [text(post.title)]),
            ]),
          p([.text(encode(post.blurb))]),
          p([`class`([Class.padding([.mobile: [.topBottom: 2]])])], [
            a([href(url(to: .blog(.show((.right(post.id.unwrap))))))], [
              img(src: post.coverImage, alt: "", [style(maxWidth(.pct(100)))])
              ])
            ]),

          a(
            [
              href(url(to: .blog(.show(.right(post.id.unwrap))))),
              `class`(
                [
                  Class.pf.colors.link.purple,
                  Class.pf.colors.fg.purple,
                  Class.pf.type.body.leading
                ]
              )
            ],
            ["Read the full post…"]
          )
          ]),

        div(
          [`class`([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],
          hostSignOffView.view(unit)
        )
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

let newBlogPostEmailAdminReportEmail = simpleEmailLayout(newBlogPostEmailAdminReportEmailContent)
  .contramap { erroredUsers, totalAttempted in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "New blog post email finished sending!",
      preheader: "\(totalAttempted) attempted emails, \(erroredUsers.count) errors",
      template: .blog,
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
