import Foundation

public let post0034_SnapshotTestingSwiftUI = BlogPost(
  author: .pointfree,
  blurb: """
Snapshot testing gives us broad test coverage on our SwiftUI views with very little up front work.
""",
  contentBlocks: [
    Episode.TranscriptBlock(
      content: #"""
SwiftUI is an incredible technology for building UI that is going to drastically change the way we build iOS applications. In UIKit we manage views by coordinating a bunch of mutable objects, but SwiftUI allows us to avoid all of those messy details by providing a declarative framework that lets us simply describe the view hierarchy.

However, since we are still in the early days of this technology, it is not yet clear how we are supposed to test a SwiftUI application. Almost everything that happens in a SwiftUI `View` is hidden from us, and so it can be hard to make assertions on logic that is happening inside the view.

Luckily there’s a very simple way to get broad test coverage on any SwiftUI view today, and it’s done using the [snapshot testing](https://github.com/pointfreeco/swift-snapshot-testing) library we open sourced one year ago!

In this week’s [free episode](/episodes/ep86-snapshot-testing-swiftui) we demonstrate how to add [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) to the application we have been building over the past many weeks. We show off lots of really cool things:

- It’s easy to add [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) to our project via the Swift Package Manager.
- We can immediately get snapshot test coverage on any SwiftUI view by using `UIHostingController`.
- We can further get test coverage on alerts and modals if we properly host the controller in a test application with a `UIWindow`.
- We can even further perform a kind of “integration test” by using the composable architecture to play a script of user actions and take screen shots of the UI every step of the way.
- And finally, we demonstrate how this form of testing compares with the XCUITest framework that Apple gives us.

If you find any of this interesting, hop on over to our 100% [free episode](/episodes/ep86-snapshot-testing-swiftui) demonstrating how all of this (and more) is possible!
"""#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 34,
  publishedAt: Date(timeIntervalSince1970: 1577080800),
  title: "Snapshot Testing SwiftUI"
)
