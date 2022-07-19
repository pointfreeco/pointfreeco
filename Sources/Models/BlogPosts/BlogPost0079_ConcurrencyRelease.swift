import Foundation

public let post0079_ConcurrencyRelease = BlogPost(
  author: .pointfree,
  blurb: """
    TODO
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Today is a very special day. It both marks the 200th episode of [Point-Free](/) _and_
        the biggest release of our popular library, the [Composable Architecture][tca-github], since
        its initial release over 2 years ago.

        This update brings all new concurrency tools to the library, allowing you to construct
        complex effects using structured concurrency, tie effect lifetimes to view lifetimes, and
        accomplishing all of that while keeping your code 100% testable.

        ## Structured effects

        The library now provides 3 main entry points into creating an effect that is returned from
        a reducer. Rather than using using Combine publishers and magical incantations to string
        together publisher operators for expressing your effects, you can now write complex effects
        from top-to-bottom using Swift's structured concurrency tools.

        

        ## Effect lifetimes

        ## Testable concurrency

        ## Start using 0.39.0 today!


        [tca-github]: http://github.com/pointfreeco/swift-composable-architecture
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 79,  // TODO
  publishedAt: .distantFuture,  // TODO
  title: "Async Composable Architecture"
)
