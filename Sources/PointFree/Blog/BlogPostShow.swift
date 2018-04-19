import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import Prelude
import Styleguide
import Tuple

let blogPostShowMiddleware: (Conn<StatusLineOpen, Tuple4<Either<String, Int>, Database.User?, SubscriberState, Route?>>) -> IO<Conn<ResponseEnded, Data>> =
  filterMap(
    over1(blogPost(forParam:)) >>> require1 >>> pure,
    or: map(const(unit)) >>> routeNotFoundMiddleware
    )
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: blogPostShowView,
      layoutData: { post, currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: post,
          description: post.blurb,
          extraStyles: markdownBlockStyles,
          // TODO
          image: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/twitter-card-large.png",
          openGraphType: .website,
          style: .base(.mountains(.blog)),
          title: post.title,
          twitterCard: .summaryLargeImage
        )
    }
)

private func blogPost(forParam param: Either<String, Int>) -> BlogPost? {
  return AppEnvironment.current.blogPosts()
    .first(where: { param.right == .some($0.id.unwrap) })
}

private let blogPostShowView = View<BlogPost> { post in

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
                <> subscriberCalloutView.view(unit)
            )
          ]
        )
      ]
    )
  ]
}

private let subscriberCalloutView = View<Prelude.Unit> { _ in
  [
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
          [href(path(to: .blog(.show(.right(post.id.unwrap)))))],
          [text(post.title)]
        )
      ]
    ),

    p([text(episodeDateFormatter.string(from: post.publishedAt))]),
 
    div(
      [
        style(width(.rem(3)) <> height(.px(1))),
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
