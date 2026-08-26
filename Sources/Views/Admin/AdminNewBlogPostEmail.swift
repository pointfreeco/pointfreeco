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
    style {
      """
      form:has(input[name="\(NewBlogPostFormData.CodingKeys.subscriberDeliver.rawValue)"]:checked) \
      label:has(input[name="\(NewBlogPostFormData.CodingKeys.maxSubscriberDeliver.rawValue)"]) {
        display: none;
      }
      """
    }
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
                  " Send to members"
                }

                label {
                  input()
                    .attribute("type", "checkbox")
                    .attribute(
                      "name", NewBlogPostFormData.CodingKeys.maxSubscriberDeliver.rawValue
                    )
                    .attribute("value", "true")
                  " Send to Max members only"
                }
                .inlineStyle("margin-left", "1.5rem")

                textarea { "" }
                  .attribute("name", NewBlogPostFormData.CodingKeys.subscriberAnnouncement.rawValue)
                  .attribute("placeholder", "Member announcement")

                label {
                  input()
                    .attribute("type", "checkbox")
                    .attribute("name", NewBlogPostFormData.CodingKeys.nonsubscriberDeliver.rawValue)
                    .attribute("value", "true")
                    .attribute("checked", "")
                  " Send to non-members"
                }

                textarea { "" }
                  .attribute("name", NewBlogPostFormData.CodingKeys.nonsubscriberAnnouncement.rawValue)
                  .attribute("placeholder", "Non-member announcement")

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
