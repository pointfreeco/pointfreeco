import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

struct MaxWelcomeEmail: EmailDocument {
  @Dependency(\.siteRouter) var siteRouter
  let user: User

  var body: some HTML {
    EmailLayout(user: user) {
      tr {
        td {
          EmailMarkdown {
            """
            ## Welcome to Point-Free Max!

            Hey \(user.displayName)! Thanks so much for upgrading to the **Max** tier. Your support \
            means a lot to us and helps sustain the Point-Free ecosystem of videos and open source \
            libraries.

            Here's what you now have access to:

            * **Beta previews**: Get early access to our libraries and tools before they are \
            publicly released. Check out the latest \
            [beta previews](\(siteRouter.url(for: .betas(.landing)))).

            * **Input on future libraries**: Help shape the direction of our open source work by \
            giving us feedback on what libraries and tools you'd like to see next.

            * **Private office hour live streams**: In the future we will be hosting private live \
            streams exclusively for Max members where you can ask us anything.

            * **Supporting the Point-Free ecosystem**: Your membership directly supports the \
            development of our open source libraries, including the Composable Architecture, \
            SQLiteData, SnapshotTesting, and more.

            * **More to come**: We have a lot more planned for Max members, so stay tuned!

            If you have any questions or feedback, don't hesitate to reach out at \
            [support@pointfree.co](mailto:support@pointfree.co).
            """
          }
        }
      }
    }
  }
}

struct EmailLayout<Content: HTML>: HTML {
  let content: Content
  let user: User
  @Dependency(\.envVars.appSecret) var appSecret
  @Dependency(\.siteRouter) var siteRouter

  init(
    user: User,
    @HTMLBuilder content: () -> Content
  ) {
    self.content = content()
    self.user = user
  }

  var body: some HTML {
    table {
      content

      tr {
        td {
          EmailMarkdown {
            """
            Your hosts,

            [Brandon Williams](http://x.com/mbrandonw) & [Stephen Celis](http://x.com/stephencelis)
            """
          }
        }
      }

      tr {
        td {
          div {
            EmailMarkdown {
              """
              Contact us via email at [support@pointfree.co](mailto:support@pointfree.co), \
              [Twitter](http://x.com/pointfreeco), or on \
              [Mastodon](https://hachyderm.io/@pointfreeco). Our postal address: 139 Skillman #5C, \
              Brooklyn, NY 11211.
              """
            }
            .color(.gray300)
            .fontStyle(.body(.small))
            .linkColor(.offBlack)
          }
          .backgroundColor(.gray900)
          .inlineStyle("padding", "2rem 2rem 1.5rem 2rem")
          .inlineStyle("margin", "2rem 0")
        }
      }
    }
    .attribute("role", "presentation")
    .attribute("height", "100%")
    .attribute("width", "100%")
    .attribute("border-collapse", "collapse")
    .attribute("border-spacing", "0 0.5rem")
    .attribute("align", "center")
    .inlineStyle("display", "block")
    .inlineStyle("width", "100%")
    .inlineStyle("max-width", "600px")
    .inlineStyle("margin", "0 auto")
    .inlineStyle("clear", "both")
    .linkStyle(LinkStyle(color: .purple, underline: true))
  }
}
