import Css
import Dependencies
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide

func showNewBlogPostEmailMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  conn.writeStatus(.ok)
    .respond(showNewBlogPostView)
}

private func showNewBlogPostView() -> Node {
  @Dependency(\.blogPosts) var blogPosts

  return .ul(
    .fragment(
      blogPosts()
        .sorted(by: their(\.id, >))
        .prefix(upTo: 3)
        .map { .li(newBlogPostEmailRowView(post: $0)) }
    )
  )
}

private func newBlogPostEmailRowView(post: BlogPost) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .p(
    .text("Blog Post: \(post.title)"),
    .form(
      attributes: [
        .action(siteRouter.path(for: .admin(.newBlogPostEmail(.send(post.id))))),
        .method(.post),
      ],
      .input(
        attributes: [
          .checked(true),
          .name(NewBlogPostFormData.CodingKeys.subscriberDeliver.rawValue),
          .type(.checkbox),
          .value("true"),
        ]
      ),
      .textarea(
        attributes: [
          .name(NewBlogPostFormData.CodingKeys.subscriberAnnouncement.rawValue),
          .placeholder("Subscriber announcement"),
        ]
      ),
      .input(
        attributes: [
          .checked(true),
          .name(NewBlogPostFormData.CodingKeys.nonsubscriberDeliver.rawValue),
          .type(.checkbox),
          .value("true"),
        ]
      ),
      .textarea(
        attributes: [
          .name(NewBlogPostFormData.CodingKeys.nonsubscriberAnnouncement.rawValue),
          .placeholder("Non-subscriber announcement"),
        ]
      ),
      .input(attributes: [.type(.submit), .name("test"), .value("Test email!")]),
      .input(attributes: [.type(.submit), .name("live"), .value("Send email!")])
    )
  )
}

func sendNewBlogPostEmailMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  blogPostID: BlogPost.ID,
  formData: NewBlogPostFormData?,
  isTest: Bool
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.blogPosts) var blogPosts
  guard let post = blogPosts().first(where: { blogPostID == $0.id })
  else { return conn.redirect(to: .admin(.newBlogPostEmail(.index))) }

  Task {
    try? await sendNewBlogPostEmails(post: post, formData: formData, isTest: isTest)
  }
  return conn.redirect(to: .admin())
}

private func sendNewBlogPostEmails(
  post: BlogPost,
  formData: NewBlogPostFormData?,
  isTest: Bool
) async throws {
  @Dependency(\.database) var database

  guard let formData else { return }

  let nonsubscriberOrSubscribersOnly: Models.User.SubscriberState?
  switch (formData.nonsubscriberDeliver, formData.subscriberDeliver) {
  case (true, true):
    nonsubscriberOrSubscribersOnly = nil
  case (true, _):
    nonsubscriberOrSubscribersOnly = .nonSubscriber
  case (_, true):
    nonsubscriberOrSubscribersOnly = .subscriber
  case (_, _):
    return
  }

  let users = try await isTest
    ? database.fetchAdmins()
    : database.fetchUsersSubscribedToNewsletter(.newBlogPost, nonsubscriberOrSubscribersOnly)

  let subjectPrefix = isTest ? "[TEST] " : ""
  var failedUsers: [User] = []

  for user in users {
    do {
      let nodes = newBlogPostEmail(
        (post, formData.subscriberAnnouncement, formData.nonsubscriberAnnouncement, user)
      )
      try await retry(maxRetries: 3, backoff: { .seconds(10 * $0) }) {
        _ = try await sendEmail(
          to: [user.email],
          subject: "\(subjectPrefix)\(post.title)",
          unsubscribeData: (user.id, .newBlogPost),
          content: inj2(nodes)
        )
      }
    } catch {
      failedUsers.append(user)
    }
  }

  _ = try? await sendEmail(
    to: adminEmails,
    subject: "New blog post email finished sending!",
    content: inj2(
      newBlogPostEmailAdminReportEmail(
        (
          failedUsers,
          users.count
        )
      )
    )
  )
}
