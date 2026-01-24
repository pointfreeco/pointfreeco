import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

public struct AdminNewBlogPostEmailView: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let posts: [BlogPost]

  public init(posts: [BlogPost]) {
    self.posts = posts
  }

  public var body: some HTML {
    PageModule(title: "Send new blog post email", theme: .content) {
      VStack(alignment: .leading, spacing: 2) {
        HTMLForEach(posts) { post in
          VStack(alignment: .leading, spacing: 1) {
            Header(4) { "Blog Post: \(post.title)" }
            form {
              VStack(alignment: .leading, spacing: 0.75) {
                label {
                  input()
                    .attribute("type", "checkbox")
                    .attribute("name", NewBlogPostFormData.CodingKeys.subscriberDeliver.rawValue)
                    .attribute("value", "true")
                    .attribute("checked", "")
                  " Send to subscribers"
                }

                textarea { "" }
                  .attribute("name", NewBlogPostFormData.CodingKeys.subscriberAnnouncement.rawValue)
                  .attribute("placeholder", "Subscriber announcement")

                label {
                  input()
                    .attribute("type", "checkbox")
                    .attribute("name", NewBlogPostFormData.CodingKeys.nonsubscriberDeliver.rawValue)
                    .attribute("value", "true")
                    .attribute("checked", "")
                  " Send to non-subscribers"
                }

                textarea { "" }
                  .attribute("name", NewBlogPostFormData.CodingKeys.nonsubscriberAnnouncement.rawValue)
                  .attribute("placeholder", "Non-subscriber announcement")

                HStack(alignment: .center, spacing: 0.5) {
                  Button(tag: "input", color: .black, style: .outline)
                    .attribute("type", "submit")
                    .attribute("name", "test")
                    .attribute("value", "Test email!")
                  Button(tag: "input", color: .purple)
                    .attribute("type", "submit")
                    .attribute("name", "live")
                    .attribute("value", "Send email!")
                }
              }
            }
            .attribute(
              "action",
              siteRouter.path(for: .admin(.newBlogPostEmail(.send(post.id))))
            )
            .attribute("method", "post")
          }
        }
      }
    }
  }
}
