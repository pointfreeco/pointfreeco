import Foundation

public let post0089_2022EOYSale = BlogPost(
  author: .pointfree,
  blurb: """
    Through the new year, we're offering personal Point-Free subscriptions for 25% off the first
    year!
    """,
  contentBlocks: [
    Episode.TranscriptBlock(
      content: #"""
        We’re happy to announce an end-of-year sale by offering 🎁[25% off the first
        year][eoy-discount]🎁 of your subscription! Once subscribed you'll get instant access to 
        all 218 episodes (and growing) of Point-Free, including popular collections that have grown 
        this past year:

        - [Concurrency][concurrency-collection]: We devoted a 5-part series of episodes to
        uncovering many of Apple’s concurrency tools from the past, present, and into the future.
        We dove deep into threads and queues, which have been around on Apple's platforms for many
        years, and then explored Swift's fancy new tools, including async/await, structured
        concurrency, actors, and clocks.

        - [SwiftUI Navigation][swiftui-nav-collection]: We expanded our existing SwiftUI navigation
        collection to cover iOS 16's new tools, and discovered all new tools that allow us to
        embrace simpler and more concise domains for driving navigation.

        - [Modern SwiftUI][modern-swiftui-collection]: We started a brand new collection (still
        in progress at the time of this blog post) to demonstrate modern, best practices for
        building vanilla SwiftUI applications. Many advance topics are covered, such as navigation,
        domain modeling, effects, dependencies, and testing.

        - [Composable Architecture][tca-collection]: We modernized many aspects of our popular
        SwiftUI architecture library: [the Composable Architecture][tca-gh]. This includes a deeper
        integration with Swift's concurrency tools, a new protocol-based approach to implementing
        features, and a powerful new dependency management system.

        - [Parsers][parsers-collection]: And last, but not least, we modernized our powerful
        [parsing][parsing-gh] library. We reimagined the syntax of constructing complex parsers
        using result builders, we added error messaging for when parsers fail, and we made it
        possible to _invert_ parsers so that they can turn well-structured data back into strings.

        That's a very brief recap of our 2022 (see more [here][eoy-2022]), and we have even bigger
        plans for 2023! [Click here][eoy-discount]🎁 to redeem the coupon code now. The offer will
        only remain valid through the end of the year! 🥳

        [eoy-discount]: /discounts/eoy-2022
        [swiftui-nav-collection]: /collections/swiftui/navigation
        [modern-swiftui-collection]: /collections/swiftui/modern-swiftui
        [parsers-collection]: /collections/parsing
        [tca-collection]: /collections/composable-architecture
        [concurrency-collection]: /collections/concurrency
        [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
        [parsing-gh]: http://github.com/pointfreeco/swift-parsing
        [eoy-2022]: /blog/posts/88-2022-year-in-review
        """#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil,
  hidden: .yes,
  id: 89,
  publishedAt: Date(timeIntervalSince1970: 1_671_602_400),
  title: "End-of-year sale: 25% off Point-Free"
)
