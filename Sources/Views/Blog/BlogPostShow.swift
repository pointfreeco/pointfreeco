import Css
import Foundation
import FunctionalCss
import HtmlUpgrade
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func blogPostShowView(
  currentDate: Date,
  post: BlogPost,
  subscriberState: SubscriberState
) -> Node {
  let showHolidaySpecialCallout = holidayDiscount2019Interval.contains(currentDate.timeIntervalSince1970)
    && subscriberState.isNonSubscriber
    && post.id != 35

  return [
    .gridRow(
      attributes: [.class([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]])])],
      [
        .gridColumn(
          sizes: [.mobile: 12, .desktop: 9],
          attributes: [.style(margin(leftRight: .auto))],
          showHolidaySpecialCallout ? holidaySpecialCallout : [],
          .div(
            attributes: [.class([Class.padding([.mobile: [.topBottom: 3], .desktop: [.topBottom: 4]])])],
            blogPostContentView(post),
            subscriberCalloutView(subscriberState)
          )
        )
      ]
    )
  ]
}

public func blogPostContentView(_ post: BlogPost) -> Node {
  return [
    .h1(
      attributes: [.class([Class.pf.type.responsiveTitle3])],
      .a(
        attributes: [.href(pointFreeRouter.url(to: .blog(.show(slug: post.slug))))],
        .text(post.title)
      )
    ),

    .div(
      attributes: [
        .class([Class.flex.flex, Class.flex.items.baseline]),
        .style(flex(direction: .row))
      ],
      .div(.p(.text(episodeDateFormatter.string(from: post.publishedAt)))),
      .div(
        attributes: [.class([Class.margin([.mobile: [.left: 1]])])],
        [
          .twitterShareLink(
            text: post.title,
            url: pointFreeRouter.url(to: .blog(.show(slug: post.slug))),
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
            Class.margin([.mobile: [.bottom: 3]])
          ]
        )
      ]
    ),

    .div(
      attributes: [.class([Class.pf.colors.bg.white])],
      .fragment(post.contentBlocks.map(transcriptBlockView))
    )
  ]
}

private func subscriberCalloutView(_ subscriberState: SubscriberState) -> Node {
  guard !subscriberState.isActive else { return [] }

  return [
    .hr(attributes: [.class([Class.pf.components.divider, Class.margin([.mobile: [.topBottom: 4]])])]),

    .div(
      attributes: [
        .class(
          [
            Class.margin([.mobile: [.leftRight: 3]]),
            Class.padding([.mobile: [.all: 3]]),
            Class.pf.colors.bg.gray900
          ]
        )
      ],
      .h4(
        attributes: [
          .class(
            [
              Class.pf.type.responsiveTitle4,
              Class.padding([.mobile: [.bottom: 2]])
            ]
          )
        ],
        "Subscribe to Point-Free"
      ),
      .p(
        "👋 Hey there! If you got this far, then you must have enjoyed this post. You may want to also",
        " check out ",
        .a(
          attributes: [
            .href(pointFreeRouter.path(to: .home)),
            .class([Class.pf.type.underlineLink])
          ],
          "Point-Free"
        ),
        ", a video series on functional programming and Swift."
      )
    )
  ]
}

private let holidaySpecialCallout: Node = .div(
  attributes: [
    .class([
      Class.margin([.mobile: [.top: 4, .leftRight: 4]]),
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
