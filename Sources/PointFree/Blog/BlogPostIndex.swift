import Css
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import View
import Views

let blogIndexMiddleware: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple4<[BlogPost], User?, SubscriberState, Route?>,
  Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: blogIndexView,
      layoutData: { blogPosts, currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (blogPosts, currentUser, subscriberState),
          description: "A companion blog to Point-Free, exploring functional programming and Swift.",
          extraStyles: markdownBlockStyles,
          image: "https://d1iqsrac68iyd8.cloudfront.net/common/pfp-social-logo.jpg",
          openGraphType: .website,
          style: .base(.mountains(.blog)),
          title: "Point-Free Pointers",
          twitterCard: .summaryLargeImage,
          usePrismJs: true
        )
    }
)
