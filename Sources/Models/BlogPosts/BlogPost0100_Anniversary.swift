import Foundation

public let post0100_Anniversary = BlogPost(
  author: .pointfree,
  blurb: """
    We launched Point-Free 5 years ago today! There's still so much more we want to do, but we'll
    start with two things that many people have asked for: livestreams and a community Slack!
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Five years ago, to the day, we launched Point-Free with a pair of episodes
        ([functions](/episodes/ep1-functions) and [side-effects](/episodes/ep2-side-effects)),
        and since then have released 220 episodes, 132 hours of video, and have had nearly half a
        million visitors to the site.

        In some ways we are only just getting started. We still haven't released the 1.0 of
        [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture),
        we still haven't talked about one of our favorite subjects
        (the deep connection between math and programming), and there's still so much more to say
        about Swift concurrency.

        All of that will come in due time, but in the meantime there's two things happening this
        week that people have been asking for a long time: livestreams and a Point-Free Slack
        community!

        ## Livestreams

        We are extremely excited to announce our first ever livestream. Everyone can access this
        livestream, whether you are a [subscriber](/pricing) or not, and it will begin at 9am PST
        (5pm GMT) this Wednesday, Feburary 1st:
        """###,
      type: .paragraph
    ),
    .init(
      content: "Watch Feb 1 @ 9am PST / 5pm GMT",
      type: .button(href: "/live")
    ),
    .init(
      content: ###"""
        We will be discussing [modern SwiftUI](/collections/swiftui-modern-swiftui) techniques,
        our new [Dependencies library](http://github.com/pointfreeco/swift-dependencies),
        [non-exhaustive testing][non-exhaustive-testing-blog], as well as taking questions from our
        viewers. Please join us, and bring any questions you might have. In fact, you can already
        start asking questions and vote on other people's questions. Just click the "Ask" button
        at the bottom of chat.

        We have plans for a lot more livestreams in the future, especially in tandem with new
        library releases and new episodic releases. Some will be free for all, and some will be
        for subscribers only, so consider [subscribing today](/pricing). 😁

        ## Point-Free community slack

        We currently field questions and comments from many different places: emails sent to us
        personally, [Twitter](http://twitter.com/pointfreeco) messages,
        [discussions][tca-discussions] on our GitHub repos, the [Swift forums][tca-forums], and
        there's a [popular Slack](http://iosdevelopers.slack.com) with an active
        "#composable-architecture" channel. We really enjoy interacting with the community, but it can
        be difficult to keep track of conversations in so many places.

        That is why we are excited to announce a new Slack just for the Point-Free community:

        [tca-discussions]: https://github.com/pointfreeco/swift-composable-architecture/discussions
        [tca-forums]: https://forums.swift.org/c/related-projects/swift-composable-architecture/61
        [non-exhaustive-testing-blog]: /blog/posts/83-non-exhaustive-testing-in-the-composable-architecture
        """###,
      type: .paragraph
    ),
    .init(
      content: "Join the Point-Free Community Slack",
      type: .button(
        href:
          "https://join.slack.com/t/pointfreecommunity/shared_invite/zt-1o8l02r36-lygnfRjdoCZA3GtpG9bo_Q"
      )
    ),
    .init(
      content: ###"""
        This is the best place for chat about our open source repos, about our episode content,
        and anything else Point-Free related. For more long form conversations we recommend opening
        a discussion on the appropriate GitHub repo (did you know we have one for all of our
        [episode code samples][episode-code-samples]?). While we will casually check the Swift
        forums and iOS developers Slack, we will not actively monitor them as much as we do our own
        Slack and repo discussions.

        ## One more thing

        We have also added a little easter egg feature that makes it easy for you to resume your
        most recently watched episode, or start up the next one. Just point your browser to
        [pointfree.co/resume](/resume) and it will do the rest. We plan on adding more features
        like this to the site soon.

        ## To 5 more years!

        We are enternally grateful to all of our subscribers, who make it possible for us to create
        our episodes and work on open source projects. We wouldn't be here without you. Here's
        to five more years! 🥳

        [episode-code-samples]: https://github.com/pointfreeco/episode-code-samples/discussions
        """###,
      type: .paragraph
    ),
  ],
  coverImage: nil,
  id: 100,
  publishedAt: yearMonthDayFormatter.date(from: "2023-01-29")!,
  title: "Point-Free turns 5"
)
