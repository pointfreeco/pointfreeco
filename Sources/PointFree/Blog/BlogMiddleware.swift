import Either
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tuple

func blogMiddleware(
  conn: Conn<StatusLineOpen, SiteRoute.Blog>
) -> IO<Conn<ResponseEnded, Data>> {

  let subRoute = conn.data

  switch subRoute {
  case .feed:
    return conn.map(const(Current.blogPosts()))
      |> blogAtomFeedResponse

  case .index:
    return conn.map(const(Current.blogPosts()))
      |> blogIndexMiddleware

  case let .show(postParam):
    return conn.map(const(postParam))
      |> blogPostShowMiddleware
  }
}
