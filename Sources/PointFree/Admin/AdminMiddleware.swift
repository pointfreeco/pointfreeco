import ApplicativeRouter
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple

let adminMiddleware =
  requireAdmin
    <| _adminMiddleware

private func _adminMiddleware(
  conn: Conn<StatusLineOpen, Tuple2<User, Admin>>
  )
  -> IO<Conn<ResponseEnded, Data>> {

    let (user, route) = lower(conn.data)

    switch route {
    case let .episodeCredits(.add(userId: userId, episodeSequence: episodeSequence)):
      return conn.map(const(user .*. userId .*. episodeSequence .*. unit))
        |> redeemEpisodeCreditMiddleware

    case .episodeCredits(.show):
      return conn.map(const(user .*. unit))
        |> showEpisodeCreditsMiddleware

    case .index:
      return conn.map(const(user .*. unit))
        |> adminIndex

    case .freeEpisodeEmail(.index):
      return conn.map(const(user .*. unit))
        |> indexFreeEpisodeEmailMiddleware

    case let .freeEpisodeEmail(.send(episodeId)):
      return conn.map(const(user .*. episodeId .*. unit))
        |> sendFreeEpisodeEmailMiddleware

    case .ghost(.index):
      return conn.map(const(unit))
        |> ghostIndexMiddleware

    case let .ghost(.start(userId)):
      return conn.map(const(user .*. userId .*. unit))
        |> ghostStartMiddleware

    case let .newBlogPostEmail(.send(blogPostId, formData, isTest)):
      return conn.map(const(user .*. blogPostId .*. formData .*. isTest .*. unit))
        |> sendNewBlogPostEmailMiddleware

    case .newBlogPostEmail(.index):
      return conn.map(const(user .*. unit))
        |> showNewBlogPostEmailMiddleware

    case let .newEpisodeEmail(.send(episodeId, subscriberAnnouncement, nonSubscriberAnnouncement, isTest)):
      return conn.map(const(user .*. episodeId .*. subscriberAnnouncement .*. nonSubscriberAnnouncement .*. isTest .*. unit))
        |> sendNewEpisodeEmailMiddleware

    case .newEpisodeEmail(.show):
      return conn.map(const(user .*. unit))
        |> showNewEpisodeEmailMiddleware

    }
}
