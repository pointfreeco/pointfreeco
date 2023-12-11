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
  conn: Conn<StatusLineOpen, SiteRoute.Blog>
) -> IO<Conn<ResponseEnded, Data>> {
  @Dependency(\.blogPosts) var blogPosts

  let subRoute = conn.data

  switch subRoute {
  case .feed:
    return conn.map(const(blogPosts()))
      |> blogAtomFeedResponse

  case .index:
    @Dependency(\.blogPosts) var blogPosts
    return conn.map(const(blogPosts()))
      |> blogIndexMiddleware

  case .slackFeed:
    return conn.map(
      const(
        blogPosts()
          .filter { !$0.hideFromSlackRSS }
      )
    )
      |> blogAtomFeedResponse

  case let .show(postParam):
    return conn.map(const(postParam))
      |> blogPostShowMiddleware
  }
}
