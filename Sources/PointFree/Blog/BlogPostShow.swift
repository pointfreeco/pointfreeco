import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Prelude
import Styleguide
import Tuple

let blogPostShowMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple4<BlogPost, Database.User?, SubscriberState, Route?>, Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: blogPostShowView,
      layoutData: { (post: BlogPost, currentUser: Database.User?, subscriberState: SubscriberState, currentRoute: Route?) in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (post, subscriberState),
          description: post.blurb,
          extraStyles: markdownBlockStyles,
          image: post.coverImage,
          openGraphType: .website,
          style: .base(.mountains(.blog)),
          title: post.title,
          twitterCard: .summaryLargeImage,
          usePrismJs: true
        )
    }
)

func fetchBlogPost(forParam param: Either<String, Int>) -> BlogPost? {
  return Current.blogPosts()
    .first(where: {
      param.right == .some($0.id.rawValue)
        || param.left == .some($0.slug)
    })
}

private let blogPostShowView = View<(BlogPost, SubscriberState)> { post, subscriberState in

  [
    gridRow(
      [`class`([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]])])],
      [
        gridColumn(
          sizes: [.mobile: 12, .desktop: 9],
          [style(margin(leftRight: .auto))],
          [
            div(
              [`class`([Class.padding([.mobile: [.topBottom: 3], .desktop: [.topBottom: 4]])])],
              blogPostContentView.view(post)
                <> subscriberCalloutView.view(subscriberState)
            )
          ]
        )
      ]
    )
  ]
}

private let subscriberCalloutView = View<SubscriberState> { subscriberState -> [Node] in
  guard !subscriberState.isActive else { return [] }

  return [
    hr([`class`([Class.pf.components.divider, Class.margin([.mobile: [.topBottom: 4]])])]),

    div(
      [
        `class`(
          [
            Class.margin([.mobile: [.leftRight: 3]]),
            Class.padding([.mobile: [.all: 3]]),
            Class.pf.colors.bg.gray900
          ]
        )
      ],
      [
        h4(
          [
            `class`(
              [
                Class.pf.type.responsiveTitle4,
                Class.padding([.mobile: [.bottom: 2]])
              ]
            )
          ],
          ["Subscribe to Point-Free"]
        ),
        p(
          [
            "👋 Hey there! If you got this far, then you must have enjoyed this post. You may want to also",
            " check out ",
            a(
              [
                href(path(to: .home)),
                `class`([Class.pf.type.underlineLink])
              ],
              ["Point-Free"]
            ),
            ", a video series on functional programming and Swift."
          ]
        )
      ]
    )
  ]
}

let blogPostContentView = View<BlogPost> { post in
  [
    h1(
      [`class`([Class.pf.type.responsiveTitle3]),],
      [
        a(
          [href(url(to: .blog(.show(post))))],
          [text(post.title)]
        )
      ]
    ),

    div(
      [
        `class`([Class.flex.flex, Class.flex.items.baseline]),
        style(flex(direction: .row))
      ],
      [
        div([p([text(episodeDateFormatter.string(from: post.publishedAt))])]),
        div(
          [`class`([Class.margin([.mobile: [.left: 1]])])],
          [twitterShareLink(text: post.title, url: url(to: .blog(.show(post))), via: "pointfreeco")]
        )
      ]
    ),
 
    div(
      [
        style(width(.rem(3)) <> height(.px(2))),
        `class`(
          [
            Class.pf.colors.bg.green,
            Class.margin([.mobile: [.bottom: 3]])
          ]
        )
      ],
      []
    ),

    div(
      [`class`([Class.pf.colors.bg.white])],
      post.contentBlocks.flatMap(transcriptBlockView.view)
    )
  ]
}
