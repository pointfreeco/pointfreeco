import Css
import Either
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Views

let newBlogPostEmail =
  simpleEmailLayout(newBlogPostEmailContent)
  <<< { post, subscriberAnnouncement, nonSubscriberAnnouncement, user in
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

func newBlogPostEmailContent(post: BlogPost, announcement: String?) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],
          announcementView(announcement: announcement)
        ),
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],
          .a(
            attributes: [.href(url(to: .blog(.show(slug: post.slug))))],
            .h3(
              attributes: [.class([Class.pf.type.responsiveTitle3])], .text(post.title))
          ),
          .p(.text(post.blurb)),

          post.coverImage.map {
            .p(
              attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
              .a(
                attributes: [.href(url(to: .blog(.show(slug: post.slug))))],
                .img(attributes: [.src($0), .alt(""), .style(maxWidth(.pct(100)))])
              )
            )
          } ?? [],
          .a(
            attributes: [
              .href(url(to: .blog(.show(slug: post.slug)))),
              .class([
                Class.pf.colors.link.purple,
                Class.pf.colors.fg.purple,
                Class.pf.type.body.leading,
              ]),
            ],
            "Read the full post…"
          )
        ),
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 0], .desktop: [.all: 2]])])],
          hostSignOffView
        )
      )
    )
  )
}

private func announcementView(announcement: String?) -> Node {
  guard let announcement = announcement, !announcement.isEmpty else { return [] }

  return .blockquote(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2]]),
        Class.margin([.mobile: [.leftRight: 0, .topBottom: 3]]),
        Class.pf.colors.bg.blue900,
        Class.type.italic,
      ])
    ],
    .h5(attributes: [.class([Class.pf.type.responsiveTitle5])], ["Announcements"]),
    .markdownBlock(announcement)
  )
}

let newBlogPostEmailAdminReportEmail =
  simpleEmailLayout(newBlogPostEmailAdminReportEmailContent)
  <<< { erroredUsers, totalAttempted in
    SimpleEmailLayoutData(
      user: nil,
      newsletter: nil,
      title: "New blog post email finished sending!",
      preheader: "\(totalAttempted) attempted emails, \(erroredUsers.count) errors",
      template: .blog,
      data: (erroredUsers, totalAttempted)
    )
  }

func newBlogPostEmailAdminReportEmailContent(erroredUsers: [User], totalAttempted: Int) -> Node {
  return .emailTable(
    attributes: [.style(contentTableStyles)],
    .tr(
      .td(
        attributes: [.valign(.top)],
        .div(
          attributes: [.class([Class.padding([.mobile: [.all: 1], .desktop: [.all: 2]])])],
          .h3(
            attributes: [.class([Class.pf.type.responsiveTitle3])], ["New blog post email report"]),
          .p(
            "A total of ",
            .strong(.text("\(totalAttempted)")),
            " emails were attempted to be sent, and of those, ",
            .strong(.text("\(erroredUsers.count)")),
            " emails failed to send. Here is the list of users that we ",
            "had trouble sending to their emails:"
          ),
          .ul(
            .fragment(
              erroredUsers.map { user in
                .li(.text(user.name.map { "\($0) (\(user.email)" } ?? user.email.rawValue))
              }
            )
          )
        )
      )
    )
  )
}
