import Dependencies
import Models
import StyleguideV2

public struct NewsletterIndex: HTML {
  @Dependency(\.blogPosts) var blogPosts
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now

  public init() {}

  public var body: some HTML {
    PageHeader {
      "Newsletter"
    } blurb: {
      """
      Explore advanced programming topics in Swift.
      """
    }

    let blogPosts = blogPosts()
      .sorted { $0.id > $1.id }
      .filter { !$0.hidden.isCurrentlyHidden(date: now) }

    if let mostRecentPost = blogPosts.first {
      NewsletterDetailModule(blogPost: mostRecentPost)
    }

    if currentUser == nil {
      GetStartedModule(style: .solid)
    }

    PageModule(
      title: "Older posts",
      theme: .content
    ) {
      ul {
        for post in blogPosts.dropFirst() {
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
