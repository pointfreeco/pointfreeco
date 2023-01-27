import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

let blogIndexMiddleware:
  Middleware<
    StatusLineOpen,
    ResponseEnded,
    [BlogPost],
    Data
  > =
    writeStatus(.ok)
    >=> respond(
      view: blogIndexView(blogPosts:),
      layoutData: { blogPosts in
        SimplePageLayoutData(
          data: blogPosts,
          description:
            "A companion blog to Point-Free, exploring functional programming and Swift.",
          image: "https://d1iqsrac68iyd8.cloudfront.net/common/pfp-social-logo.jpg",
          openGraphType: .website,
          style: .base(.mountains(.blog)),
          title: "Point-Free Pointers",
          twitterCard: .summaryLargeImage,
          usePrismJs: true
        )
      }
    )
