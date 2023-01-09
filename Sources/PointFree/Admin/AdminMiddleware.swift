import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Tuple

public func adminMiddleware(conn: Conn<StatusLineOpen, Admin>) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.currentUser) var currentUser
  let route = conn.data

  guard let currentUser = currentUser
  else { return loginAndRedirect(conn) }

  guard currentUser.isAdmin
  else {
    return conn
      |> redirect(to: .home, headersMiddleware: flash(.error, "You don't have access to that."))
  }

  switch route {
  case let .episodeCredits(.add(userId: userId, episodeSequence: episodeSequence)):
    return conn.map(const(userId .*. episodeSequence .*. unit))
      |> redeemEpisodeCreditMiddleware

  case .episodeCredits(.show):
    return conn.map(const(()))
      |> showEpisodeCreditsMiddleware

  case .index:
    return conn.map(const(()))
      |> adminIndex

  case .freeEpisodeEmail(.index):
    return conn.map(const(()))
      |> indexFreeEpisodeEmailMiddleware

  case let .freeEpisodeEmail(.send(episodeId)):
    return conn.map(const(episodeId))
      |> sendFreeEpisodeEmailMiddleware

  case .ghost(.index):
    return conn.map(const(unit))
      |> ghostIndexMiddleware

  case let .ghost(.start(userId)):
    return conn.map(const(currentUser .*. userId .*. unit))
      |> ghostStartMiddleware

  case let .newBlogPostEmail(.send(blogPostId, formData, isTest)):
    return conn.map(const(blogPostId .*. formData .*. isTest .*. unit))
      |> sendNewBlogPostEmailMiddleware

  case .newBlogPostEmail(.index):
    return conn.map(const(unit))
      |> showNewBlogPostEmailMiddleware

  case let
      .newEpisodeEmail(.send(episodeId, subscriberAnnouncement, nonSubscriberAnnouncement, isTest)):
    return conn.map(
      const(episodeId .*. subscriberAnnouncement .*. nonSubscriberAnnouncement .*. isTest .*. unit))
      |> sendNewEpisodeEmailMiddleware

  case .newEpisodeEmail(.show):
    return conn.map(const(unit))
      |> showNewEpisodeEmailMiddleware
  }
}
