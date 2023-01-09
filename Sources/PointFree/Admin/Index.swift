import Dependencies
import EmailAddress
import Foundation
import Html
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

public let adminEmails: [EmailAddress] = [
  "brandon@pointfree.co",
  "stephen@pointfree.co",
]

func requireAdmin<A>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, T2<User, A>, Data>
)
  -> Middleware<StatusLineOpen, ResponseEnded, A, Data>
{
  return { conn in
    @Dependency(\.currentUser) var currentUser

    guard let currentUser = currentUser
    else { return loginAndRedirect(conn) }

    guard currentUser.isAdmin
    else {
      return conn
        |> redirect(
          to: .home,
          headersMiddleware: flash(.error, "You don't have access to that.")
        )
    }

    return middleware(conn.map(const(currentUser .*. conn.data)))
  }
}

let adminIndex =
  writeStatus(.ok)
  >=> respond(
    view: adminIndexView,
    layoutData: {
      SimplePageLayoutData(
        data: (),
        title: "Admin"
      )
    }
  )

private func adminIndexView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .ul(
    .li(
      .a(
        attributes: [.href(siteRouter.path(for: .admin(.newEpisodeEmail())))],
        "Send new episode email")),
    .li(
      .a(
        attributes: [.href(siteRouter.path(for: .admin(.episodeCredits())))], "Send episode credits"
      )),
    .li(
      .a(
        attributes: [.href(siteRouter.path(for: .admin(.freeEpisodeEmail())))],
        "Send free episode email")),
    .li(
      .a(
        attributes: [.href(siteRouter.path(for: .admin(.newBlogPostEmail())))],
        "Send new blog post email")),
    .li(.a(attributes: [.href(siteRouter.path(for: .admin(.ghost())))], "Ghost a user"))
  )
}
