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

func newsletterDetail(
  _ conn: Conn<StatusLineOpen, Void>,
  _ postParam: Either<String, BlogPost.ID>
) async -> Conn<ResponseEnded, Data> {
  guard let post = fetchBlogPost(forParam: postParam)
  else {
    return conn
      .redirect(to: .home) {
        $0.flash(.error, "Newsletter not found")
      }
  }

  @Dependency(\.assets) var assets

  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: String(stripping: post.blurb),
        image: post.coverImage ?? assets.emailHeaderImgSrc,
        title: String(stripping: post.title),
        usePrismJs: true
      )
    ) {
      NewsletterDetail(blogPost: post)
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
