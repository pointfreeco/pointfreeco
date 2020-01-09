import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import Optics
import PointFreeRouter
import PointFreePrelude
import Prelude
import Styleguide
import Tuple

let showNewBlogPostEmailMiddleware: AppMiddleware<Prelude.Unit> =
  writeStatus(.ok)
    >=> respond({ _ in showNewBlogPostView })

private let showNewBlogPostView = Node.ul(
  .fragment(
    Current.blogPosts()
      .sorted(by: their(^\.id, >))
      .prefix(upTo: 3)
      .map { .li(newBlogPostEmailRowView(post: $0)) }
  )
)

private func newBlogPostEmailRowView(post: BlogPost) -> Node {
  return .p(
    .text("Blog Post: \(post.title)"),
    .form(
      attributes: [
        .action(path(to: .admin(.newBlogPostEmail(.send(post.id, formData: nil, isTest: nil))))),
        .method(.post)
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
          .placeholder("Subscriber announcement")
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
          .placeholder("Non-subscriber announcement")
        ]
      ),
      .input(attributes: [.type(.submit), .name("test"), .value("Test email!")]),
      .input(attributes: [.type(.submit), .name("live"), .value("Send email!")])
    )
  )
}

let sendNewBlogPostEmailMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple4<User, BlogPost.Id, NewBlogPostFormData?, Bool?>, Data
  > =
  filterMap(
      over2(fetchBlogPost(forId:) >>> pure) >>> sequence2 >>> map(require2),
      or: redirect(to: .admin(.newBlogPostEmail(.index)))
    )
    <<< filterMap(
      require4 >>> pure,
      or: redirect(to: .admin(.newBlogPostEmail(.index)))
    )
    <| sendNewBlogPostEmails
    >=> redirect(to: .admin(.index))

func fetchBlogPost(forId id: BlogPost.Id) -> BlogPost? {
  return Current.blogPosts()
    .first(where: { id == $0.id })
}

private func sendNewBlogPostEmails<I>(
  _ conn: Conn<I, Tuple4<User, BlogPost, NewBlogPostFormData?, Bool>>
  ) -> IO<Conn<I, Prelude.Unit>> {

  let (_, post, optionalFormData, isTest) = lower(conn.data)

  guard let formData = optionalFormData else {
    return pure(conn.map(const(unit)))
  }

  let nonsubscriberOrSubscribersOnly: Either<Prelude.Unit, Prelude.Unit>?
  switch (formData.nonsubscriberDeliver, formData.subscriberDeliver) {
  case (.some(true), .some(true)):
    nonsubscriberOrSubscribersOnly = nil
  case (.some(true), _):
    nonsubscriberOrSubscribersOnly = .left(unit)
  case (_, .some(true)):
    nonsubscriberOrSubscribersOnly = .right(unit)
  case (_, _):
    return pure(conn.map(const(unit)))
  }

  let users = isTest
    ? Current.database.fetchAdmins()
    : Current.database.fetchUsersSubscribedToNewsletter(.newBlogPost, nonsubscriberOrSubscribersOnly)

  return users
    .mapExcept(bimap(const(unit), id))
    .flatMap { users in
      sendEmail(
        forNewBlogPost: post,
        toUsers: users,
        subscriberAnnouncement: formData.subscriberAnnouncement,
        subscriberDeliver: formData.subscriberDeliver,
        nonsubscriberAnnouncement: formData.nonsubscriberAnnouncement,
        nonsubscriberDeliver: formData.nonsubscriberDeliver,
        isTest: isTest
      )
    }
    .run
    .map { _ in conn.map(const(unit)) }
}

private func sendEmail(
  forNewBlogPost post: BlogPost,
  toUsers users: [User],
  subscriberAnnouncement: String,
  subscriberDeliver: Bool?,
  nonsubscriberAnnouncement: String,
  nonsubscriberDeliver: Bool?,
  isTest: Bool
  ) -> EitherIO<Prelude.Unit, Prelude.Unit> {

  let subjectPrefix = isTest ? "[TEST] " : ""

  // A personalized email to send to each user.
  let newBlogPostEmails = users.map { user in
    lift(IO { newBlogPostEmail((post, subscriberAnnouncement, nonsubscriberAnnouncement, user)) })
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
          newBlogPostEmailAdminReportEmail(
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
