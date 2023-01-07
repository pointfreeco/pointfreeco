import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tuple

func blogMiddleware(
  conn: Conn<StatusLineOpen, Tuple4<User?, SubscriberState, SiteRoute, SiteRoute.Blog>>
) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.blogPosts) var blogPosts

  let (user, subscriberState, route, subRoute) = lower(conn.data)

  switch subRoute {
  case .feed:
    return conn.map(const(blogPosts()))
      |> blogAtomFeedResponse

  case .index:
    return conn.map(const(blogPosts() .*. user .*. subscriberState .*. route .*. unit))
      |> blogIndexMiddleware

  case let .show(postParam):
    return conn.map(const(postParam .*. user .*. subscriberState .*. route .*. unit))
      |> blogPostShowMiddleware
  }
}
