import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Prelude
import Styleguide
import Tuple

let blogIndexMiddleware: (Conn<StatusLineOpen, Tuple3<Database.User?, SubscriberState, Route?>>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: blogIndexView,
      layoutData: { currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (currentUser, subscriberState),
          description: "A companion blog to Point-Free, exploring functional programming and Swift.",
          extraStyles: markdownBlockStyles,
          image: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pfp-twitter-card-large.jpg",
          openGraphType: .website,
          style: .base(.mountains(.blog)),
          title: "Point-Free Pointers",
          twitterCard: .summaryLargeImage
        )
    }
)

private let blogIndexView = View<(Database.User?, SubscriberState)> { currentUser, subscriberState in

  [
    gridRow(
      [`class`([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]])])],
      [
        gridColumn(
          sizes: [.mobile: 12, .desktop: 9],
          [style(margin(leftRight: .auto))],
          [
            div(
              [
              ],
              AppEnvironment.current.blogPosts()
                .sorted(by: their(^\.id.unwrap, >))
                .flatMap { post in
                  [
                    div(
                      [`class`([Class.padding([.mobile: [.topBottom: 3], .desktop: [.topBottom: 4]])])],
                      blogPostContentView.view(post)
                    ),
                    divider
                  ]
              }
            )
          ]
        )
      ]
    )
  ]
}
