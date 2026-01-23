import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import StyleguideV2
import Views

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

func ghostIndexMiddleware(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  conn.writeStatus(.ok)
    .respondV2(layoutData: SimplePageLayoutData(title: "Ghost a user")) {
      GhostIndexView()
    }
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

func endGhostingMiddleware(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  conn.redirect(to: .home) {
    $0.writeSessionCookie {
      $0.user = conn.request.session.ghosterId.map(Session.User.standard)
    }
  }
}

private struct GhostIndexView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(title: "Ghost a user", theme: .content) {
      form {
        VStack(alignment: .leading, spacing: 1) {
          input()
            .attribute("name", "user_id")
            .attribute("placeholder", "User ID")
            .attribute("type", "text")
          Button(tag: "input", color: .purple)
            .attribute("type", "submit")
            .attribute("value", "Ghost 👻")
        }
      }
      .attribute("method", "post")
      .attribute("action", siteRouter.path(for: .admin(.ghost(.start(nil)))))
    }
  }
}
