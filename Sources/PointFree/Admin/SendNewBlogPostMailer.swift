import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import StyleguideV2
import Views

func showNewBlogPostEmailMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) -> Conn<ResponseEnded, Data> {
  @Dependency(\.blogPosts) var blogPosts
  let posts = blogPosts()
    .sorted { $0.id > $1.id }
    .prefix(upTo: 3)
  return conn.writeStatus(.ok)
    .respondV2(layoutData: SimplePageLayoutData(title: "New blog post email")) {
      AdminNewBlogPostEmailView(posts: Array(posts))
    }
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
