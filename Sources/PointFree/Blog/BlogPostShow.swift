import Dependencies
import Either
import Foundation
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

let blogPostShowMiddleware =
  fetchBlogPostForParam
  <| writeStatus(.ok)
  >=> respond(
    view: blogPostShowView,
    layoutData: { post in
      @Dependency(\.assets) var assets

      return SimplePageLayoutData(
        data: post,
        description: post.blurb,
        extraStyles: markdownBlockStyles,
        image: post.coverImage ?? assets.emailHeaderImgSrc,
        openGraphType: .website,
        style: .base(.mountains(.blog)),
        title: post.title,
        twitterCard: .summaryLargeImage,
        usePrismJs: true
      )
    }
  )

private func fetchBlogPostForParam(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, BlogPost, Data>
) -> Middleware<StatusLineOpen, ResponseEnded, Either<String, BlogPost.ID>, Data> {
  return { conn in
    guard let post = fetchBlogPost(forParam: conn.data)
    else { return conn |> redirect(to: .home) }

    return middleware(conn.map(const(post)))
  }
}

func fetchBlogPost(forParam param: Either<String, BlogPost.ID>) -> BlogPost? {
  @Dependency(\.blogPosts) var blogPosts

  return blogPosts()
    .first(where: {
      param.right == .some($0.id)
        || param.left == .some($0.slug)
    })
}
