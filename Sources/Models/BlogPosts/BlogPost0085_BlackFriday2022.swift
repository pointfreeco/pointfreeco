import Foundation

public let post0085_BlackFriday2022 = BlogPost(
  author: .pointfree,
  blurb: """
    We're offering a 30% discount for the first year of a Point-Free subscription!
    """,
  contentBlocks: [
    .init(
      content: sale2022(name: "Black Friday"),
      type: .paragraph
    )
  ],
  coverImage: nil,
  hidden: false,
  id: 85,
  publishedAt: Date(timeIntervalSince1970: 1669356000),
  title: "Black Friday Sale: 30% Off Point-Free"
)

func sale2022(name: String) -> String {
  """
  We do this only a few times a year: we're having a [rare, Point-Free sale][black-friday-sale]
  this \(name) by offering 30% off the first year of your subscription!

  Once subscribed you'll get instant access to all [214 episodes][pf] (126 hours of video and
  growing!) of Point-Free content. This includes popular [collections][collections] that were
  created or expanded this year, as well as all of the material we have planned for 2023!

  Here are just a few of our recent additions:

  ## [Concurrency][concurrency-collection]

  Swift 5.6 brought all new concurrency tools to the language, including async/await, actors,
  structured concurrency, "sendability", streams, clocks and more. Understanding all of these
  tools at once can be overwhelming, so we thought it would be best to uncover them from the
  perspective of the past tools on Apple's platforms.

  This includes threads, queues, Combine publishers and more. Each of those concurrency
  tools are powerful in their own way, and even have many features that async/await has,
  but also have significant shortcomings. Understanding this can help us understand why
  Swift's native tools were designed the way they were, and help us leverage them to the
  best of their abilities.

  ## [SwiftUI navigation][swiftui-nav-collection]

  Navigation in SwiftUI can be complex, but it doesn't have to be that way. In our [12-part
  series][swiftui-nav-collection] we show how all of SwiftUI's seemingly disparate forms of
  navigation (sheets, covers, popovers, links, alerts, and more!) can all be unified under
  essentially one API. This greatly simplifies the process of modeling the state for
  navigation in your features, and can even make your code safer and more concise.

  We also have an [open source library][swiftui-nav-gh] that makes it super easy to integrate
  these tools into your codebase.

  ## [Composable Architecture][tca-collection]

  We expanded our [Composable Architecture][tca-gh] collection of episodes by modernizing nearly
  every aspect of the library. It now has first class support for structured concurrency in
  effects, which allows you to use async/await and tie the lifetime of effects to the lifetime
  of views.

  And we introduced a protocol for defining reducers, which has much better ergnomics for
  implementing and composing features together. It also unlocks a whole new way of managing
  dependencies that makes is easier and safer to access dependencies from any part of your
  application code base.

  ## [Parsers][parsers-collection]

  We made significant updates to our [parser library][parsers-gh], including better error handling
  and error messaging, a new builder-style of creating parsers, and the ability to "invert"
  parsers, which allows you to print values back into a string format. These features make
  our parser library one of the most powerful ways to turn unstructured data into structured
  data, and our episodes show how we built it from the ground up.

  ## Subscribe today!

  We have plenty of exciting topics planned for 2023, including first class navigation
  tools for the Composable Architecture, more improvements to our parser builders, as well
  as all new styles of content (live streams!).

  Be sure to [subscribe today][black-friday-sale] to get access to all of this and more. The
  offer is valid for only a few days, so you better hurry!

  [tca-collection]: /collections/composable-architecture
  [concurrency-collection]: /collections/concurrency
  [black-friday-sale]: /discounts/black-friday-2022
  [swiftui-nav-collection]: /collections/swiftui/navigation
  [parsers-collection]: /collections/parsing
  [pf]: /
  [collections]: /collections
  [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
  [swiftui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
  [parsers-gh]: http://github.com/pointfreeco/swift-parsers
  """
}
