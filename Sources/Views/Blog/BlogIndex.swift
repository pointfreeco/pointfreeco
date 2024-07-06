import Css
import Dependencies
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func blogIndexView(blogPosts: [BlogPost]) -> Node {
  @Dependency(\.date.now) var now

  let allPosts =
    blogPosts
    .sorted(by: their(\.id, >))
    .filter { !$0.hidden.isCurrentlyHidden(date: now) }
  let newPosts = allPosts.prefix(1)
  let oldPosts = allPosts.dropFirst(1)

  return [
    .gridRow(
      attributes: [.class([Class.padding([.mobile: [.leftRight: 3], .desktop: [.leftRight: 4]])])],
      .gridColumn(
        sizes: [.mobile: 12, .desktop: 9],
        attributes: [.style(margin(leftRight: .auto))],
        .div(.fragment(newPosts.map(newBlogPostView))),
        oldBlogPostsView(oldPosts)
      )
    )
  ]
}

import StyleguideV2

private func newBlogPostView(_ post: BlogPost) -> Node {
  return [
    .div(
      attributes: [.class([Class.padding([.mobile: [.topBottom: 3], .desktop: [.topBottom: 4]])])],
      blogPostContentView(post)
    ),
    .hr(attributes: [.class([Class.pf.components.divider])]),
  ]
}

private func oldBlogPostsView(_ posts: some Collection<BlogPost>) -> Node {
  guard !posts.isEmpty else { return [] }

  return [
    subscriberCalloutView,
    .div(
      attributes: [.class([Class.padding([.mobile: [.top: 4, .bottom: 2]])])],
      .h5(attributes: [.class([Class.pf.type.responsiveTitle5])], ["Older blog posts"])
    ),
    .div(
      attributes: [.class([Class.padding([.mobile: [.bottom: 3]])])],
      .fragment(posts.map(oldBlogPostView))
    ),
  ]
}

var subscriberCalloutView: Node {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  guard subscriberState.isNonSubscriber else { return [] }

  return [
    divider,
    .gridRow(
      .gridColumn(
        sizes: [.desktop: 9, .mobile: 12],
        attributes: [.style(margin(leftRight: .auto))],
        .div(
          attributes: [
            .class(
              [
                Class.margin([.mobile: [.all: 4]]),
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
          .p(
            "👋 Hey there! See anything you like? You may be interested in ",
            .a(
              attributes: [
                .href(siteRouter.path(for: .pricingLanding)),
                .class([Class.pf.type.underlineLink]),
              ],
              "subscribing"
            ),
            " so that you get access to these episodes and all future ones."
          )
        )
      )
    ),
  ]
}

private func oldBlogPostView(_ post: BlogPost) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .div(
      attributes: [.class([Class.padding([.mobile: [.topBottom: 2]])])],
      .div(
        .p(
          attributes: [.class([Class.pf.colors.fg.gray400, Class.pf.type.body.small])],
          .text(episodeDateFormatter.string(from: post.publishedAt))
        )
      ),

      .h1(
        attributes: [.class([Class.pf.type.responsiveTitle5])],
        .a(
          attributes: [.href(siteRouter.url(for: .blog(.show(slug: post.slug))))],
          .text(post.title)
        )
      ),

      .div(
        .p(
          attributes: [.class([Class.pf.type.body.regular])],
          .text(post.blurb)
        )
      )
    )
  ]
}
