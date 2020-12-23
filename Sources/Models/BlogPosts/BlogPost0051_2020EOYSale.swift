import Foundation

public let post0051_2020EOYSale = BlogPost(
  author: .pointfree,
  blurb: """
Through the new year, we're offering personal Point-Free subscriptions for 25% off the first year!
""",
  contentBlocks: [
    Episode.TranscriptBlock(
      content: #"""
We’re happy to announce [an end-of-year sale](/discounts/2020-is-over) by offering 25% off the first year of your subscription!

Once subscribed you'll get instant access to all 130 episodes (and growing) of Point-Free, including popular collections that have grown this past year:

- [Composable Architecture](/collections/composable-architecture): We started developing the Composable Architecture from first principles after breaking down the problems app architecture should solve, all the way back in July 2019. We continued to refine things over _17 hours_ (so far) in this collection of episodes, while covering aspects of SwiftUI, Combine, and more general concepts like testing and dependencies! We finally bundled things up into [an open source library](https://github.com/pointfreeco/swift-composable-architecture) so that you can immediately put these concepts to use in your applications!

- [Parsing](/collections/parsing): When we define "parsing" as transforming some kind of unstructured data into something more structured, it turns out that parsing is quite a ubiquitous problem that shows up in a lot of the everyday code we write! It also turns out that functional programming has a lot to say about parsing. We first started covering the topic last year, but many viewers have requested more content, and we made some truly impressive progress, showing how parsers [generalize](/collections/parsing/generalization), and how composed parsers can be [as performant](/collections/parsing/performance) as highly-tuned, more ad-hoc hand-written parsers. We even ended the year with our first release of [Parsing](https://github.com/pointfreeco/swift-parsing), a production ready library that bundles up everything we've covered so far and more.

In addition to these topics, we covered:

- [SwiftUI bindings](/episodes/ep107-composable-swiftui-bindings-the-problem) and how they compose
- [SwiftUI's new `redacted` API](/episodes/ep115-redacted-swiftui-the-problem)
- [Combine's Scheduler API](/episodes/ep104-combine-schedulers-testing-time) and how to test Combine code
- [How to design your app's dependencies](/episodes/ep110-designing-dependencies-the-problem)
- And what do you get when you design a Swift key path for enums? [Case paths!](https://www.pointfree.co/episodes/ep87-the-case-for-case-paths-introduction)

[Click here](/discounts/2020-is-over) to redeem the coupon code now. The offer will only remain valid through the end of the year 😱
"""#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil,
  hidden: true,
  id: 51,
  publishedAt: .distantFuture,
  title: "End-of-year sale: 25% off Point-Free"
)
