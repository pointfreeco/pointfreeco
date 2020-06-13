import Foundation

public let post0034_TestingSwiftUI = BlogPost(
  author: .pointfree,
  blurb: """
    A free video exploring how to test SwiftUI.
    """,
  contentBlocks: [
    Episode.TranscriptBlock(
      content: #"""
        This past WWDC, Apple introduced [SwiftUI](https://developer.apple.com/xcode/swiftui/), a rethinking of how to build UI on Apple's platforms. It allows us to think of our views in a declarative manner so that we can simply describe the view hierarchy rather than think about all the messy details of how to coordinate various objects to get UI on the screen.

        Even though it's early days, Apple has given us a ton of guidance on how to use this technology, including an in-depth collection of [tutorials](https://developer.apple.com/tutorials/SwiftUI), but one thing that's still missing is how to _test_ SwiftUI.

        This week we explore just that in [a free video](https://www.pointfree.co/episodes/ep85-testable-state-management-the-point)! We explore what it means to test SwiftUI logic and its various state management solutions, including `@Binding`, `@ObservedObject`, and `@State`. [Click here](https://www.pointfree.co/episodes/ep85-testable-state-management-the-point) to watch it today!

        If you're interested in learning even more about SwiftUI and Combine, check out [our other free videos](https://www.pointfree.co/blog/posts/32-a-crash-course-in-combine).
        """#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: "https://i.vimeocdn.com/video/837834979.jpg",
  id: 34,
  publishedAt: Date(timeIntervalSince1970: 1_576_648_800),
  title: "Free Video: Testing SwiftUI"
)
