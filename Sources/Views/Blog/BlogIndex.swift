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

  let allPosts =
    blogPosts
    .sorted(by: their(\.id, >))
    .filter { !$0.hidden }
  let newPosts = allPosts.prefix(3)
  let oldPosts = allPosts.dropFirst(3)

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

private func newBlogPostView(_ post: BlogPost) -> Node {
  return [
    .div(
      attributes: [.class([Class.padding([.mobile: [.topBottom: 3], .desktop: [.topBottom: 4]])])],
      blogPostContentView(post)
    ),
    .hr(attributes: [.class([Class.pf.components.divider])]),
  ]
}

private func oldBlogPostsView(_ posts: ArraySlice<BlogPost>) -> Node {
  guard !posts.isEmpty else { return [] }

  return [
    .div(
      attributes: [.class([Class.padding([.mobile: [.top: 4, .bottom: 2]])])],
      .h5(attributes: [.class([Class.pf.type.responsiveTitle6])], ["Older blog posts"])
    ),
    .div(
      attributes: [.class([Class.padding([.mobile: [.bottom: 3]])])],
      .fragment(posts.map(oldBlogPostView))
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
          attributes: [.href(siteRouter.path(for: .blog(.show(slug: post.slug))))],
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
