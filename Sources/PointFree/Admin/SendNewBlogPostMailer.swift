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
import Tuple

let showNewBlogPostEmailMiddleware =
  requireAdmin
    <| writeStatus(.ok)
    >=> respond(showNewBlogPostView.contramap(lower))

private let showNewBlogPostView = View<Database.User> { _ in
  ul(
    Current.blogPosts()
      .sorted(by: their(^\.id, >))
      .prefix(upTo: 1)
      .map(li <<< newBlogPostEmailRowView.view)
  )
}

private let newBlogPostEmailRowView = View<BlogPost> { post in
  p([
    text("Blog Post: \(post.title)"),

    form([action(path(to: .admin(.newBlogPostEmail(.send(post, subscriberAnnouncement: nil, nonSubscriberAnnouncement: nil, isTest: nil))))), method(.post)], [

      textarea([name("subscriber_announcement"), placeholder("Subscriber announcement")]),
      textarea([name("nonsubscriber_announcement"), placeholder("Non-subscribers announcements")]),

      input([type(.submit), name("test"), value("Test email!")]),
      input([type(.submit), name("live"), value("Send email!")])
      ])
    ])
}

let sendNewBlogPostEmailMiddleware:
  Middleware<StatusLineOpen, ResponseEnded, Tuple5<Database.User?, BlogPost, String?, String?, Bool?>, Data> =
  requireAdmin
    <<< filterMap(
      require5 >>> pure,
      or: redirect(to: .admin(.newBlogPostEmail(.index)))
    )
    <| sendNewBlogPostEmails
    >=> redirect(to: .admin(.index))

func fetchBlogPost(forId id: BlogPost.Id) -> BlogPost? {
  return Current.blogPosts()
    .first(where: { id == $0.id })
}

private func sendNewBlogPostEmails<I>(
  _ conn: Conn<I, Tuple5<Database.User, BlogPost, String?, String? , Bool>>
  ) -> IO<Conn<I, Prelude.Unit>> {

  let (_, post, subscriberAnnouncement, nonSubscriberAnnouncement, isTest) = lower(conn.data)

  let users = isTest
    ? Current.database.fetchAdmins()
    : Current.database.fetchUsersSubscribedToNewsletter(.newBlogPost)

  return users
    .mapExcept(bimap(const(unit), id))
    .flatMap { users in
      sendEmail(
        forNewBlogPost: post,
        toUsers: users,
        subscriberAnnouncement: subscriberAnnouncement,
        nonSubscriberAnnouncement: nonSubscriberAnnouncement,
        isTest: isTest
      )
    }
    .run
    .map { _ in conn.map(const(unit)) }
}

private func sendEmail(
  forNewBlogPost post: BlogPost,
  toUsers users: [Database.User],
  subscriberAnnouncement: String?,
  nonSubscriberAnnouncement: String?,
  isTest: Bool
  ) -> EitherIO<Prelude.Unit, Prelude.Unit> {

  let subjectPrefix = isTest ? "[TEST] " : ""

  // A personalized email to send to each user.
  let newBlogPostEmails = users.map { user in
    lift(IO { newBlogPostEmail.view((post, subscriberAnnouncement, nonSubscriberAnnouncement, user)) })
      .flatMap { nodes in
        sendEmail(
          to: [user.email],
          subject: "\(subjectPrefix)Point-Free Pointer: \(post.title)",
          unsubscribeData: (user.id, .newBlogPost),
          content: inj2(nodes)
          )
          .delay(.milliseconds(200))
          .retry(maxRetries: 3, backoff: { .seconds(10 * $0) })
    }
  }

  // An email to send to admins once all user emails are sent
  let newBlogPostEmailReport = sequence(newBlogPostEmails.map(^\.run))
    .flatMap { results in
      sendEmail(
        to: adminEmails,
        subject: "New blog post email finished sending!",
        content: inj2(
          newBlogPostEmailAdminReportEmail.view(
            (
              zip(users, results)
                .filter(second >>> ^\.isLeft)
                .map(first),

              results.count
            )
          )
        )
        )
        .run
  }

  let fireAndForget = IO { () -> Prelude.Unit in
    newBlogPostEmailReport
      .map(const(unit))
      .parallel
      .run({ _ in })
    return unit
  }

  return lift(fireAndForget)
}
