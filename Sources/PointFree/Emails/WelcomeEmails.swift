import Dependencies
import IssueReporting
import Models
import PointFreeRouter
import StyleguideV2

struct WelcomeEmail<Content: HTML>: HTML {
  let content: Content
  let preheader: String
  let user: User
  @Dependency(\.envVars.appSecret) var appSecret
  @Dependency(\.siteRouter) var siteRouter

  init(
    preheader: String = "",
    user: User,
    @HTMLBuilder content: () -> Content
  ) {
    self.content = content()
    self.preheader = preheader
    self.user = user
  }

  var body: some HTML {
    span {
      HTMLText(preheader)
    }
    .color(.init(rawValue: "transparent"))
    .inlineStyle("display", "none")
    .inlineStyle("opacity", "0")
    .inlineStyle("width", "0")
    .inlineStyle("height", "0")
    .inlineStyle("maxWidth", "0")
    .inlineStyle("maxHeight", "0")
    .inlineStyle("overflow", "hidden")

    table {
      content

      tr {
        td {
          Button(color: .purple) {
            "Subscribe to Point-Free"
          }
          .attribute("href", siteRouter.url(for: .pricingLanding))
          .inlineStyle("margin", "1rem 0rem")
          .inlineStyle("display", "inline-block")
        }
        .inlineStyle("text-align", "center")
      }

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
              Contact us via email at [support@pointfree.co](mailto:support@pointfree.co), 
              [Twitter](http://x.com/pointfreeco), or on 
              [Mastodon](https://hachyderm.io/@pointfreeco). Our postal address: 139 Skillman #5C, 
              Brooklyn, NY 11211.

              """
              if let unsubscribeURL {
                """
                You are receiving this email because you recently signed up for Point-Free. If you no 
                longer wish to receive emails like this, you can unsubscribe 
                [here](\(unsubscribeURL)).
                """
              }
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

  var unsubscribeURL: String? {
    let unsubscribeURL = (try? ExpressUnsubscribe().print((user.id, .welcomeEmails)))
      .flatMap({ Encrypted(String($0), with: appSecret) })
      .map({ siteRouter.url(for: .expressUnsubscribe(payload: $0)) })
    if unsubscribeURL == nil {
      reportIssue("Failed to generate unsubscribe link for user \(user.id)")
    }
    return unsubscribeURL
  }
}

struct WelcomeEmailWeek1: EmailDocument {
  @Dependency(\.siteRouter) var siteRouter
  let user: User

  var body: some HTML {
    WelcomeEmail(
      preheader: user.episodeCreditCount > 0
        ? """
        Use your episode credit to unlock any subscriber-only episode!
        """
        : """
        Explore our most popular episodes and join our vibrant Slack community!
        """,
      user: user
    ) {
      tr {
        td {
          EmailMarkdown {
            """
            ## 👋 Howdy!

            It's been a week since you signed up for [Point-Free](\(siteRouter.url(for: .home))). We 
            hope you've learned a thing or two new about Swift, and maybe even introduced a 
            new learning into your codebase. We'd love to [have you as a 
            subscriber](\(siteRouter.url(for: .pricingLanding))), so please let us know if you have 
            any questions. Just reply to this [email](mailto:support@pointfree.co).
            """
            if user.episodeCreditCount > 0 {
              """
              ## Get a free episode!

              In the meantime, it looks like you have a **free episode credit**! You can use this to 
              unlock *any* subscriber-only episode, completely for free. Just visit [our
              site](\(siteRouter.url(for: .home))), go to any episode, and click the 
              "\(useCreditCTA)" button.

              Here are some of our most popular collections of episodes:
              """
            } else {
              """
              ## Explore Point-Free

              In the meantime, explore everything that Point-Free has to offer. You can check out
              all of our [free episodes](\(siteRouter.url(for: .episodes(.list(.free))))), and here
              are some of our most popular collections on Point-Free:
              """
            }
            popularCollectionsList
            """
            ## Point-Free community

            We also have a vibrant [Point-Free Slack community](http://pointfree.co/slack-invite). 
            Join today to discuss episodes with other community members, ask questions about our 
            episodes or open source projects, and more.

            When you're ready to subscribe for yourself _or_ your team, visit our subscribe
            page:
            """
          }
        }
      }
    }
  }
}

struct WelcomeEmailWeek2: EmailDocument {
  @Dependency(\.episodes) var episodes
  @Dependency(\.siteRouter) var siteRouter
  let freeEpisodeCount: Int
  let user: User

  static let freeEpisodeIDs: [Episode.ID] = [
    214,  // Modern SwiftUI
    281,  // Modern UIKit
    259,  // Observable Architecture
    291,  // Cross-platform Swift
    277,  // Shared state in practice
    250,  // Testing/debugging macros
    238,  // Reliable async tests
  ]

  var body: some HTML {
    WelcomeEmail(
      preheader: """
        Explore our \(freeEpisodeCount) free episodes!
        """,
      user: user
    ) {
      tr {
        td {
          EmailMarkdown {
            """
            ## Hey there!

            You signed up for a [Point-Free](\(siteRouter.url(for: .home))) account a couple weeks 
            ago but still haven't subscribed!

            If you're still on the fence and want to see a little more of what we have to offer, we 
            have a number of [free episodes](\(siteRouter.url(for: .episodes(.list(.free))))) for 
            you to check out:
            """
            for id in Self.freeEpisodeIDs {
              if let episode = episodes().first(where: { $0.id == id }) {
                """
                * [\(episode.title)](\(siteRouter.url(for: .episodes(.show(episode)))))
                """
              }
            }
            """
            * [_And a lot more…_](\(siteRouter.url(for: .episodes(.list(.free)))))

            """
            if user.episodeCreditCount > 0 {
              """
              You *also* have a **free episode credit** you can use to see *any* _subscriber-only_
              episode, completely for free. Just visit [our site](\(siteRouter.url(for: .home))), go 
              to an episode, and click the "\(useCreditCTA)" button.
              """
            }
            """

            If you have any questions, don't hesitate to reply to this 
            [email](support@pointfree.co). When you're ready to subscribe for yourself _or_ your 
            team, visit our subscribe page:
            """
          }
        }
      }
    }
  }
}

struct WelcomeEmailWeek3: EmailDocument {
  @Dependency(\.date) var date
  @Dependency(\.siteRouter) var siteRouter
  let user: User

  var body: some HTML {
    WelcomeEmail(
      preheader: """
        Level up your engineering skills with a subscription to Point-Free.
        """,
      user: user
    ) {
      tr {
        td {
          EmailMarkdown {
            """
            ## 👋 Hiya!

            It's been a few weeks since you signed up for 
            [Point-Free](\(siteRouter.url(for: .home))) and we wanted to reach out in the hope that 
            we might make a subscriber out of you yet. So, we've added an **episode credit** to your 
            account, allowing you to watch _any_ subscriber-only episode on our site for free.

            If you're having trouble deciding on an episode, here are a few of the most popular 
            collections on our site:
            """
            popularCollectionsList
            """
            If you have any questions, don't hesitate to reply to this 
            [email](support@pointfree.co). When you're ready to subscribe for yourself _or_ your 
            team, visit our subscribe page:
            """
          }
        }
      }
    }
  }
}

private let popularCollectionsList = """

  * [Composable
  Architecture](https://www.pointfree.co/collections/composable-architecture)
  * [SwiftUI](https://www.pointfree.co/collections/swiftui)
  * [Dependencies](https://www.pointfree.co/collections/dependencies)
  * [UIKit](https://www.pointfree.co/collections/uikit)
  * [Cross-platform Swift](https://www.pointfree.co/collections/cross-platform-swift)
  * _[And a whole lot more…](https://www.pointfree.co/collections)_

  """

private let useCreditCTA = "Use an episode credit"
