import ApplicativeRouterHttpPipelineSupport
import Either
import Foundation
import HttpPipeline
import Optics
import Prelude
import Styleguide
import Tuple

func blogMiddleware(
  conn: Conn<StatusLineOpen, Tuple4<Database.User?, SubscriberState, Route, Route.Blog>>
  ) -> IO<Conn<ResponseEnded, Data>> {

  let (user, subscriberState, route, subRoute) = lower(conn.data)

  switch subRoute {
  case .feed(.atom):
    return conn.map(const(AppEnvironment.current.blogPosts()))
      |> blogAtomFeedResponse

  case .index:
    return conn.map(const(user .*. subscriberState .*. route .*. unit))
      |> blogIndexMiddleware

  case let .show(param):
    return conn.map(const(param .*. user .*. subscriberState .*. route .*. unit))
      |> blogPostShowMiddleware
  }
}


