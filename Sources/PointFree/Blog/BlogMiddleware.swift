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
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.blogPosts) var blogPosts

  let subRoute = conn.data

  switch subRoute {
  case .feed:
    return await blogAtomFeedResponse(conn.map(const(blogPosts()))).performAsync()

  case .index:
    return await newsletterIndex(conn.map { _ in })

  case .slackFeed:
    return await blogAtomFeedResponse(
      conn.map(
        const(
          blogPosts()
            .filter { !$0.hideFromSlackRSS }
        )
      )
    )
    .performAsync()

  case let .show(postParam):
    return await newsletterDetail(conn.map { _ in }, postParam)
  }
}
