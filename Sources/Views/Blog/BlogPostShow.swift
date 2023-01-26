import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func blogPostShowView(post: BlogPost) -> Node {
  @Dependency(\.date.now) var now
  @Dependency(\.subscriberState) var subscriberState

  let showHolidaySpecialCallout =
    holidayDiscount2019Interval.contains(now.timeIntervalSince1970)
    && subscriberState.isNonSubscriber
    && post.id != 36

  return [
    .gridRow(
      attributes: [.class([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]])])],
      [
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 9],
          attributes: [.style(margin(leftRight: .auto))],
          showHolidaySpecialCallout ? holidaySpecialCallout : [],
          .div(
            attributes: [
              .class([Class.padding([.mobile: [.topBottom: 3], .desktop: [.topBottom: 4]])])
            ],
            blogPostContentView(post),
            subscriberCalloutView
          )
        )
      ]
    )
  ]
}

public func blogPostContentView(_ post: BlogPost) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .h1(
      attributes: [.class([Class.pf.type.responsiveTitle3])],
      .a(
        attributes: [.href(siteRouter.url(for: .blog(.show(slug: post.slug))))],
        .text(post.title)
      )
    ),

    .div(
      attributes: [
        .class([Class.flex.flex, Class.flex.items.baseline]),
        .style(flex(direction: .row)),
      ],
      .div(.p(.text(episodeDateFormatter.string(from: post.publishedAt)))),
      .div(
        attributes: [.class([Class.margin([.mobile: [.left: 1]])])],
        [
          .twitterShareLink(
            text: post.title,
            url: siteRouter.url(for: .blog(.show(slug: post.slug))),
            via: "pointfreeco"
          )
        ]
      )
    ),

    .div(
      attributes: [
        .style(width(.rem(3)) <> height(.px(2))),
        .class(
          [
            Class.pf.colors.bg.green,
            Class.margin([.mobile: [.bottom: 3]]),
          ]
        ),
      ]
    ),

    .div(
      attributes: [.class([Class.pf.colors.bg.white])],
      .fragment(post.contentBlocks.map { transcriptBlockView($0) })
    ),
  ]
}

var subscriberCalloutView: Node {
  @Dependency(\.subscriberState) var subscriberState
  guard !subscriberState.isActive else { return [] }

  @Dependency(\.siteRouter) var siteRouter

  return [
    .hr(attributes: [
      .class([Class.pf.components.divider, Class.margin([.mobile: [.topBottom: 4]])])
    ]),

    .div(
      attributes: [
        .class(
          [
            Class.margin([.mobile: [.leftRight: 3]]),
            Class.padding([.mobile: [.all: 3]]),
            Class.pf.colors.bg.gray900,
          ]
        )
      ],
      .h4(
        attributes: [
          .class(
            [
              Class.pf.type.responsiveTitle4,
              Class.padding([.mobile: [.bottom: 2]]),
            ]
          )
        ],
        "Subscribe to Point-Free"
      ),
      .markdownBlock("""
        👋 Hey there! If you got this far, then you must have enjoyed this post. You may want to
        also check out [Point-Free](/), a video series covering advanced programming topics in
        Swift. Consider [subscribing](/pricing) today!
        """)
    ),
  ]
}

private let holidaySpecialCallout: Node = .div(
  attributes: [
    .class([
      Class.margin([.mobile: [.top: 4], .desktop: [.leftRight: 4]])
    ])
  ],
  holidaySpecialContent
)

let episodeDateFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateFormat = "EEEE MMM d, yyyy"
  df.timeZone = TimeZone(secondsFromGMT: 0)
  return df
}()
