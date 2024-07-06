import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

struct BlogPosts: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let blogPosts: [BlogPost]

  init(blogPosts: [BlogPost]) {
    self.blogPosts = blogPosts
  }

  init(limit: Int = 3) {
    @Dependency(\.blogPosts) var blogPosts
    @Dependency(\.date.now) var now

    self.blogPosts = blogPosts()
      .filter { !$0.hidden.isCurrentlyHidden(date: now) }.suffix(limit)
      .reversed()
  }

  var body: some HTML {
    PageModule(
      title: "Newsletter",
      seeAllURL: siteRouter.path(for: .blog(.index)),
      theme: .content
    ) {
      ul {
        for post in blogPosts {
          li {
            BlogPostEntry(post: post)
          }
          li {
            Divider()
          }
          .inlineStyle("margin", "2rem 0")
          .inlineStyle("display", "none", pseudo: .lastChild)
        }
      }
      .listStyle(.reset)
    }
  }
}

struct BlogPostEntry: HTML {
  let post: BlogPost
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    div {
      HTMLText(post.publishedAt.monthDayYear())
    }
    .color(.gray500.dark(.gray650))
    div {
      Header(4) {
        Link(href: siteRouter.path(for: .blog(.show(.left(post.slug))))) {
          HTMLMarkdown(post.title)
        }
        .color(.offBlack.dark(.offWhite))
      }
    }
    .inlineStyle("margin-top", "0.5rem")
    div {
      HTMLMarkdown(post.blurb)
    }
    .color(.gray400.dark(.gray650))
  }
}
