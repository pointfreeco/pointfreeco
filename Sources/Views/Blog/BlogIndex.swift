import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import View

public let blogIndexView = View<([BlogPost], User?, SubscriberState)> { blogPosts, currentUser, subscriberState -> Node in

  let allPosts = blogPosts.sorted(by: their(^\.id, >))
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
    hr([`class`([Class.pf.components.divider])])
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
              [href(pointFreeRouter.url(to: .blog(.show(slug: post.slug))))],
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
