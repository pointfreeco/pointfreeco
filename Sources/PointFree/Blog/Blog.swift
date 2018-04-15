import Foundation
import Html
import HttpPipeline
import Prelude
import Tuple

struct Blog {
  public typealias Id = Tagged<Blog, Int>

  public private(set) var title: String
  public private(set) var publishedAt: Date
  public private(set) var blurb: String
  public private(set) var id: Id
  public private(set) var video: Video?
  public private(set) var content: String

  public struct Video {
    public private(set) var sources: [String]
  }
}

let blogIndexMiddleware: (Conn<StatusLineOpen, Tuple3<Database.User?, Stripe.Subscription.Status?, Route?>>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: blogIndexView,
      layoutData: { currentUser, currentSubscriptionStatus, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriptionStatus: currentSubscriptionStatus,
          currentUser: currentUser,
          data: (currentUser, currentSubscriptionStatus),
          description: "Point-Free is a video series exploring functional programming and Swift.",
          extraStyles: markdownBlockStyles <> pricingExtraStyles,
          image: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
          navStyle: .mountains(.blog),
          openGraphType: .website,
          title: "Point-Free: A video series on functional programming and the Swift programming language.",
          twitterCard: .summaryLargeImage
        )
    }
)

private let blogIndexView = View<(Database.User?, Stripe.Subscription.Status?)> { currentUser, currentSubscriptionStatus in

  []
}
