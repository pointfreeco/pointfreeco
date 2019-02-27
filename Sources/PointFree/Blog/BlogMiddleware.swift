import ApplicativeRouterHttpPipelineSupport
import Either
import Foundation
import HttpPipeline
import Models
import Optics
import PointFreeRouter
import Prelude
import Styleguide
import Tuple

func blogMiddleware(
  conn: Conn<StatusLineOpen, Tuple4<User?, SubscriberState, Route, Route.Blog>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let (user, subscriberState, route, subRoute) = lower(conn.data)

  switch subRoute {
  case .feed:
    return conn.map(const(Current.blogPosts()))
      |> blogAtomFeedResponse

  case .index:
    return conn.map(const(user .*. subscriberState .*. route .*. unit))
      |> blogIndexMiddleware

  case let .show(post):
    // TODO
    return conn
      |> writeStatus(.ok)
      >=> end
//    return conn.map(const(post .*. user .*. subscriberState .*. route .*. unit))
//      |> blogPostShowMiddleware
  }
}
