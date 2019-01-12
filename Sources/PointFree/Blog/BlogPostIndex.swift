import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Prelude
import Styleguide
import Tuple
import View

let blogIndexMiddleware: (Conn<StatusLineOpen, Tuple3<Database.User?, SubscriberState, Route?>>) -> IO<Conn<ResponseEnded, Data>> =
  writeStatus(.ok)
    >=> map(lower)
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
          image: "https://d1iqsrac68iyd8.cloudfront.net/common/pfp-social-logo.jpg",
          openGraphType: .website,
          style: .base(.mountains(.blog)),
          title: "Point-Free Pointers",
          twitterCard: .summaryLargeImage,
          usePrismJs: true
        )
    }
)

private let blogIndexView = View<(Database.User?, SubscriberState)> { currentUser, subscriberState -> Node in

  let allPosts = Current.blogPosts()
    .sorted(by: their(^\.id, >))
  let newPosts = allPosts.prefix(3)
  let oldPosts = allPosts.dropFirst(3)

  return gridRow(
    [`class`([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]])])],
    [
      gridColumn(
        sizes: [.mobile: 12, .desktop: 9],
        [style(margin(leftRight: .auto))],
        [div(newPosts.flatMap(newBlogPostView.view))]
          <> oldBlogPostsView.view(oldPosts)
      )
    ]
  )
}

private let newBlogPostView = View<BlogPost> { post in
  [
    div(
      [`class`([Class.padding([.mobile: [.topBottom: 3], .desktop: [.topBottom: 4]])])],
      blogPostContentView.view(post)
    ),
    divider
  ]
}

private let oldBlogPostsView = View<ArraySlice<BlogPost>> { posts -> [Node] in
  guard !posts.isEmpty else { return [] }
  
  return [
    div(
      [`class`([Class.padding([.mobile: [.top: 4, .bottom: 2]])])],
      [h5([`class`([Class.pf.type.responsiveTitle6])], ["Older blog posts"])]
    ),

    div(
      [`class`([Class.padding([.mobile: [.bottom: 3]])])],
      posts.flatMap(oldBlogPostView.view)
    )
  ]
}

private let oldBlogPostView = View<BlogPost> { post in
  [
    div(
      [`class`([Class.padding([.mobile: [.topBottom: 2]])])],
      [
        div(
          [
            p(
              [`class`([Class.pf.colors.fg.gray400, Class.pf.type.body.small])],
              [.text(episodeDateFormatter.string(from: post.publishedAt))]
            )
          ]
        ),

        h1(
          [`class`([Class.pf.type.responsiveTitle5]),],
          [
            a(
              [href(url(to: .blog(.show(post))))],
              [.text(post.title)]
            )
          ]
        ),

        div(
          [
            p(
              [`class`([Class.pf.type.body.regular])],
              [.text(post.blurb)]
            )
          ]
        )
      ]
    )
  ]
}
