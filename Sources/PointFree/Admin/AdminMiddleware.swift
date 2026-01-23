import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Tuple

public func adminMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  route: Admin
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  guard let currentUser = currentUser
  else { return conn.loginAndRedirect() }

  guard currentUser.isAdmin
  else {
    return conn.redirect(to: .home) { $0.flash(.error, "You don't have access to that.") }
  }

  switch route {
  case .emailPreview(let template):
    return await emailPreview(conn, template: template)

  case .episodeCredits(.add(let userID, let episodeSequence)):
    return await redeemEpisodeCreditMiddleware(
      conn,
      userID: userID,
      episodeSequence: episodeSequence
    )

  case .episodeCredits(.show):
    return showEpisodeCreditsMiddleware(conn)

  case .index:
    return adminIndex(conn)

  case .freeEpisodeEmail(.index):
    return indexFreeEpisodeEmailMiddleware(conn)

  case .freeEpisodeEmail(.send(let episodeId)):
    return await sendFreeEpisodeEmailMiddleware(conn.map { _ in episodeId })
      .performAsync()

  case .ghost(.index):
    return ghostIndexMiddleware(conn)

  case .ghost(.start(let ghosteeID)):
    return await ghostStartMiddleware(conn, ghoster: currentUser, ghosteeID: ghosteeID)

  case .newBlogPostEmail(.send(let blogPostId, let formData, let isTest)):
    return await sendNewBlogPostEmailMiddleware(
      conn.map(const(blogPostId .*. formData .*. isTest .*. unit))
    )
    .performAsync()

  case .newBlogPostEmail(.index):
    return await showNewBlogPostEmailMiddleware(conn.map { _ in unit })
      .performAsync()

  case .newEpisodeEmail(
    .send(let episodeId, let subscriberAnnouncement, let nonSubscriberAnnouncement, let isTest)
  ):
    return await sendNewEpisodeEmailMiddleware(
      conn.map(
        const(
          episodeId .*. subscriberAnnouncement .*. nonSubscriberAnnouncement .*. isTest .*. unit
        )
      )
    )
    .performAsync()

  case .newEpisodeEmail(.show):
    return showNewEpisodeEmailMiddleware(conn)
  }
}
