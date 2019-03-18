import Css
import FunctionalCss
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Models
import PointFreeRouter
import PointFreePrelude
import Prelude
import Styleguide
import Tuple
import View
import Views

let blogPostShowMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple4<Either<String, BlogPost.Id>, User?, SubscriberState, Route?>, Data> =
  filterMap(
    over1(fetchBlogPost(forParam:) >>> pure) >>> sequence1 >>> map(require1),
    or: redirect(to: .home)
    )
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: blogPostShowView,
      layoutData: { (post: BlogPost, currentUser: User?, subscriberState: SubscriberState, currentRoute: Route?) in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (post, subscriberState),
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

func fetchBlogPost(forParam param: Either<String, BlogPost.Id>) -> BlogPost? {
  return Current.blogPosts()
    .first(where: {
      param.right == .some($0.id)
        || param.left == .some($0.slug)
    })
}
