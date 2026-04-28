import Dependencies
import Models
import PointFreeRouter
import StyleguideV2

struct ProWelcomeEmail: EmailDocument {
  @Dependency(\.siteRouter) var siteRouter
  let user: User
  var ownerName: String? = nil

  var body: some HTML {
    WelcomeSubscribeEmailLayout {
      tr {
        td {
          EmailMarkdown {
            """
            ## Welcome to Point-Free!

            """
            if let ownerName {
              """
              Hey \(user.displayName)! You have joined **\(ownerName)’s** Point-Free team.
              """
            } else {
              """
              Hey \(user.displayName)! Thanks so much for becoming a Point-Free member. We're excited \
              to have you on board.
              """
            }
            """

            Here’s what you now have access to:

            * **All episodes and videos**: Our entire back catalog of episodes covering \
            advanced topics in Swift, the Composable Architecture, SwiftUI, and much more. Browse \
            all  [episodes](\(siteRouter.url(for: .episodes(.list(.all))))).

            * **The Point-Free Way**: A CLI tool that puts the principles from our videos into \
            practice for your AI agents. Check it out [here](\(siteRouter.url(for: .theWay))).

            * **Private podcast feed**: Listen to episodes on the go with your own private, \
            offline podcast feed. Set it up from \
            [your account](\(siteRouter.url(for: .account(.index)))).

            * **On-demand livestream access**: Watch our [livestreams](/collections/livestreams) \
            on demand, anytime.


            If you have any questions or feedback, don’t hesitate to reach out at \
            [support@pointfree.co](mailto:support@pointfree.co).

            ---

            **Want even more Point-Free?** [Upgrade to \
            Max](\(siteRouter.url(for: .pricingLanding))) for access to \
            [beta previews](\(siteRouter.url(for: .betas(.landing)))) of our libraries and private \
            office hour livestreams.

            ---
            """
          }
        }
      }
    }
  }
}

struct MaxWelcomeEmail: EmailDocument {
  @Dependency(\.siteRouter) var siteRouter
  let user: User
  var ownerName: String? = nil

  var body: some HTML {
    WelcomeSubscribeEmailLayout {
      tr {
        td {
          EmailMarkdown {
            """
            ## Welcome to Point-Free Max!

            """
            if let ownerName {
              """
              Hey \(user.displayName)! You have joined **\(ownerName)’s** Point-Free Max team.
              """
            } else {
              """
              Hey \(user.displayName)! Thanks so much for upgrading to the **Max** tier. Your support \
              means a lot to us and helps sustain the Point-Free ecosystem of videos and open source \
              libraries.
              """
            }
            """

            Here’s what you now have access to:

            * **Beta previews**: Get early access to our libraries and tools before they are \
            publicly released. Check out the latest \
            [beta previews](\(siteRouter.url(for: .betas(.landing)))).

            * **Input on future libraries**: Help shape the direction of our open source work by \
            giving us feedback on what libraries and tools you’d like to see next.

            * **Private office hour live streams**: In the future we will be hosting private live \
            streams exclusively for Max members where you can ask us anything.

            """
            if ownerName == nil {
              """
              * **Supporting the Point-Free ecosystem**: Your membership directly supports the \
              development of our open source libraries, including the Composable Architecture, \
              SQLiteData, SnapshotTesting, and more.
              """
            } else {
              """
              * **Supporting the Point-Free ecosystem**: Your team’s membership directly supports \
              the development of our open source libraries, including the Composable Architecture, \
              SQLiteData, SnapshotTesting, and more.
              """
            }
            """

            * **More to come**: We have a lot more planned for Max members, so stay tuned!
            
            As well as everything that is included with the **Pro** membership tier:

            * **All episodes and videos**: Our entire back catalog of episodes covering \
            advanced topics in Swift, the Composable Architecture, SwiftUI, and much more. Browse \
            all [episodes](\(siteRouter.url(for: .episodes(.list(.all))))).

            * **The Point-Free Way**: A CLI tool that puts the principles from our videos into \
            practice for your AI agents. Check it out [here](\(siteRouter.url(for: .theWay))).

            * **Private podcast feed**: Listen to episodes on the go with your own private, \
            offline podcast feed. Set it up from \
            [your account](\(siteRouter.url(for: .account(.index)))).

            * **On-demand livestream access**: Watch our [livestreams](/collections/livestreams) \
            on demand, anytime.


            If you have any questions or feedback, don’t hesitate to reach out at \
            [support@pointfree.co](mailto:support@pointfree.co).
            """
          }
        }
      }
    }
  }
}

private struct WelcomeSubscribeEmailLayout<Content: HTML>: HTML {
  @HTMLBuilder let content: Content
  @Dependency(\.siteRouter) var siteRouter


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
