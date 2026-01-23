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
  _ param: Either<String, BlogPost.ID>
) -> Conn<ResponseEnded, Data> {
  @Dependency(\.blogPosts) var blogPosts

  guard
    let post = blogPosts()
      .first(where: { param.right == $0.id || param.left == $0.slug })
  else {
    return conn.redirect(to: .home) {
      $0.flash(.error, "Newsletter not found")
    }
  }

  @Dependency(\.assets) var assets

  return
    conn
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
