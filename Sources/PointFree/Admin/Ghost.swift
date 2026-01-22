import Dependencies
import Foundation
import Html
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

func ghostIndexMiddleware(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  conn.writeStatus(.ok).respond(indexView)
}

func ghostStartMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  ghoster: User,
  ghosteeID: User.ID?
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  guard
    let ghosteeID,
    let ghostee = try? await database.fetchUser(id: ghosteeID)
  else {
    return conn.redirect(to: .admin(.ghost(.index))) {
      $0.flash(.error, "Couldn't find user")
    }
  }
  return conn.redirect(to: .home) {
    $0.writeSessionCookie {
      $0.user = .ghosting(ghosteeId: ghostee.id, ghosterId: ghoster.id)
    }
  }
}

let endGhostingMiddleware: M<Prelude.Unit> = redirect(to: .home, headersMiddleware: endGhosting)

private func endGhosting<A>(
  conn: Conn<HeadersOpen, A>
) -> IO<Conn<HeadersOpen, A>> {

  return conn
    |> writeSessionCookieMiddleware {
      $0.user = conn.request.session.ghosterId.map(Session.User.standard)
    }
}

private func indexView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .h3("Ghost a user"),
    .form(
      attributes: [.method(.post), .action(siteRouter.path(for: .admin(.ghost(.start(nil)))))],
      .label("User id:"),
      .input(attributes: [.type(.text), .name("user_id")]),
      .input(attributes: [.type(.submit), .value("Ghost 👻")])
    ),
  ]
}
