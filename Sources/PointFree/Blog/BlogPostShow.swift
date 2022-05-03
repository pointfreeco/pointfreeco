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
  >=> map(lower)
  >>> respond(
    view: blogPostShowView,
    layoutData: {
      (
        post: BlogPost, currentUser: User?, subscriberState: SubscriberState,
        currentRoute: SiteRoute?
      ) in
      SimplePageLayoutData(
        currentRoute: currentRoute,
        currentSubscriberState: subscriberState,
        currentUser: currentUser,
        data: (Current.date(), post, subscriberState),
        description: post.blurb,
        extraStyles: markdownBlockStyles,
        image: post.coverImage ?? Current.assets.emailHeaderImgSrc,
        openGraphType: .website,
        style: .base(.mountains(.blog)),
        title: post.title,
        twitterCard: .summaryLargeImage,
        usePrismJs: true
      )
    }
  )

private let fetchBlogPostForParam:
  MT<
    Tuple4<Either<String, BlogPost.Id>, User?, SubscriberState, SiteRoute?>,
    Tuple4<BlogPost, User?, SubscriberState, SiteRoute?>
  > = filterMap(
    over1(fetchBlogPost(forParam:) >>> pure) >>> sequence1 >>> map(require1),
    or: redirect(to: .home)
  )

func fetchBlogPost(forParam param: Either<String, BlogPost.Id>) -> BlogPost? {
  return Current.blogPosts()
    .first(where: {
      param.right == .some($0.id)
        || param.left == .some($0.slug)
    })
}
