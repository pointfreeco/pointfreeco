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
    return await emailPreview(conn.map(const(template)))

  case .episodeCredits(.add(userId: let userId, episodeSequence: let episodeSequence)):
    return await redeemEpisodeCreditMiddleware(conn.map(const(userId .*. episodeSequence .*. unit)))
      .performAsync()

  case .episodeCredits(.show):
    return await showEpisodeCreditsMiddleware(conn.map { _ in })
      .performAsync()

  case .index:
    return await adminIndex(conn.map { _ in })
      .performAsync()

  case .freeEpisodeEmail(.index):
    return await indexFreeEpisodeEmailMiddleware(conn.map { _ in })
      .performAsync()

  case .freeEpisodeEmail(.send(let episodeId)):
    return await sendFreeEpisodeEmailMiddleware(conn.map { _ in episodeId })
      .performAsync()

  case .ghost(.index):
    return ghostIndexMiddleware(conn.map { _ in })

  case .ghost(.start(let ghosteeID)):
    return await ghostStartMiddleware(conn.map { _ in }, ghoster: currentUser, ghosteeID: ghosteeID)

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
    return await showNewEpisodeEmailMiddleware(conn.map { _ in unit })
      .performAsync()
  }
}
