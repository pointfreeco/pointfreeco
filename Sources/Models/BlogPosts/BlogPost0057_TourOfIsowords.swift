import Foundation

public let post0057_tourOfIsowords = BlogPost(
  author: .pointfree,
  blurb: """
Four free videos exploring a real world Swift code base, including iOS client and Swift server.
""",
  contentBlocks: [
    Episode.TranscriptBlock(
      content: #"""
This past month we released four completely free videos dedicated to diving into the real-world Swift code base of an iOS game we recently [launched and open sourced](/blog/posts/55-open-sourcing-isowords): [isowords](https://www.isowords.xyz).

In them we explore the client app _and_ its backend Swift server to show how concepts covered in previous episodes of Point-Free can be applied to a production code base.

  - [A Tour of isowords: Part 1](https://www.pointfree.co/episodes/ep142-a-tour-of-isowords-part-1):
    We start the tour by pulling down the repo and bootstrapping the iOS app. Then, we dive into the code to show off our modern approach to project management using the Swift Package Manager. We also explore how [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), a library we built from first principles over [a number of Point-Free episodes](/collections/composable-architecture), powers the entire application.

  - [A Tour of isowords: Part 2](https://www.pointfree.co/episodes/ep143-a-tour-of-isowords-part-2):
    We explore how adopting the Composable Architecture aided in the ability to easily (and extensively) modularize the code base. This unlocked many things that would have otherwise been much more difficult, including the ability to add an onboarding experience without any changes to feature code, an App Clip experience, and even automated App Store assets.

  - [A Tour of isowords: Part 3](https://www.pointfree.co/episodes/ep144-a-tour-of-isowords-part-3):
    We take a peek at the Swift server that powers the game's backend. We get things running the server locally and explore some of the benefits of developing both client and server in Swift, such as simultaneously debugging both applications together, and how code and concepts can be shared across each application.

  - [A Tour of isowords: Part 4](https://www.pointfree.co/episodes/ep145-a-tour-of-isowords-part-4):
    We wrap up our tour by showing off two powerful ways the iOS client and Swift server share code: not only does the same code that routes server requests simultaneously power the API client, but we can write integration tests that exercise the full client-server lifecycle.

We hope these episodes provide a small taste of some ideas in application development and architecture that we find interesting, and we hope you do too. If you want a go deeper in your exploration of topics related to [architecture](/collections/composable-architecture), [dependency management](/collections/dependencies), [SwiftUI](/collections/swiftui), and more, check out [our ever-growing collections](/collections) of episodes today!
"""#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 57,
  publishedAt: .init(timeIntervalSince1970: 1620968400),
  title: "A Tour of isowords"
)
