import EmailAddress
import Foundation
import Html
import HttpPipeline
import Models
import PointFreeRouter
import PointFreePrelude
import Prelude
import Tuple
import Views

public let adminEmails: [EmailAddress] = [
  "brandon@pointfree.co",
  "stephen@pointfree.co"
]

func requireAdmin<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<User?, A>, Data> {

    return filterMap(require1 >>> pure, or: loginAndRedirect)
      <<< filter(
        get1 >>> ^\.isAdmin,
        or: redirect(
          to: .home,
          headersMiddleware: flash(.error, "You don't have access to that.")
          )
      )
      <| middleware
}

let adminIndex
  = writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: adminIndexView(currentUser:),
      layoutData: { currentUser in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: currentUser,
          title: "Admin"
        )
    }
)

private func adminIndexView(currentUser: User) -> Node {
  return .ul(
    .li(.a(attributes: [.href(path(to: .admin(.newEpisodeEmail(.show))))], "Send new episode email")),
    .li(.a(attributes: [.href(path(to: .admin(.episodeCredits(.show))))], "Send episode credits")),
    .li(.a(attributes: [.href(path(to: .admin(.freeEpisodeEmail(.index))))], "Send free episode email")),
    .li(.a(attributes: [.href(path(to: .admin(.newBlogPostEmail(.index))))], "Send new blog post email")),
    .li(.a(attributes: [.href(path(to: .admin(.ghost(.index))))], "Ghost a user"))
  )
}
