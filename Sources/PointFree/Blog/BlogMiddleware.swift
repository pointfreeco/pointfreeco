import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter

func blogMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  route: SiteRoute.Blog
) -> Conn<ResponseEnded, Data> {
  @Dependency(\.blogPosts) var blogPosts

  switch route {
  case .feed:
    return blogAtomFeedResponse(conn, posts: blogPosts())

  case .index:
    return newsletterIndex(conn)

  case .slackFeed:
    return blogAtomFeedResponse(
      conn,
      posts: blogPosts().filter { !$0.hideFromSlackRSS }
    )

  case let .show(postParam):
    return newsletterDetail(conn, postParam)
  }
}
