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

extension Conn where Step == StatusLineOpen, A == Void {
  func ghostIndex() -> Conn<ResponseEnded, Data> {
    self.writeStatus(.ok).respond { indexView() }
  }

  func ghostStart(adminUser: User, userID: User.ID?) async -> Conn<ResponseEnded, Data> {
    @Dependency(\.database) var database

    do {
      let ghostee = try await database.fetchUserById(userID.unwrap())
      return self.redirect(to: .home) {
        $0.writeSessionCookie {
          $0.user = .ghosting(ghosteeId: ghostee.id, ghosterId: adminUser.id)
        }
      }
    } catch {
      return self.redirect(to: .home) { $0.flash(.error, "Couldn't find user with that id" ) }
    }
  }

  func endGhosting() -> Conn<ResponseEnded, Data> {
    self.redirect(to: .home) {
      $0.writeSessionCookie { $0.user = self.request.session.ghosterId.map(Session.User.standard) }
    }
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
