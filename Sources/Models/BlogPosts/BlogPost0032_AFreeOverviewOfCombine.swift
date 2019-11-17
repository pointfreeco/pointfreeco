import Foundation

public let post0032_AnOverviewOfCombine = BlogPost(
  author: .pointfree,
  blurb: """
Two free videos exploring Apple's new Combine framework, its core components, and how to integrate it in your code.
""",
  contentBlocks: [
    Episode.TranscriptBlock(
      content: #"""
---

At this year's WWDC, Apple introduced [the Combine Framework](https://developer.apple.com/documentation/combine), a composable library for handling asynchronous events over time, providing another alternative to open source libraries like [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) and [RxSwift](https://github.com/ReactiveX/RxSwift).

The Combine framework is seriously powerful, and is responsible for handling a lot of [SwiftUI](https://developer.apple.com/xcode/swiftui/)'s high-level state management solutions under the hood! It's a great library in its own right, and a worthy addition to your own libraries and application code.

The past couple weeks we have released two completely free videos dedicated to studying the Combine framework from first principles and showing how you can incorporate it into a library or application of your own:

- [The Combine Framework and Effects: Part 1](https://www.pointfree.co/episodes/ep80-the-combine-framework-and-effects-part-1): In this video, we explore Combine's core components, including the `Publisher` and `Subscriber` protocols. We also cover some convenience functions and operators, which are layered over these more basic units.
- [The Combine Framework and Effects: Part 2](https://www.pointfree.co/episodes/ep81-the-combine-framework-and-effects-part-2): In this video we show how the Combine framework can be used to describe side effects in a reducer-based architecture, like [Redux](https://redux.js.org). We take an existing library we've been experimenting with and use Combine to help solve a critical problem.

If you're curious about what SwiftUI has to say about architecture (and what it doesn't have to say), we also have 3 free videos that explore just that:

- [SwiftUI and State Management: Part 1](https://www.pointfree.co/episodes/ep65-swiftui-and-state-management-part-1)
- [SwiftUI and State Management: Part 2](https://www.pointfree.co/episodes/ep66-swiftui-and-state-management-part-2)
- [SwiftUI and State Management: Part 3](https://www.pointfree.co/episodes/ep67-swiftui-and-state-management-part-3)

We're pretty excited about what Apple introduced this year and we can't wait to see what it enables folks to build and how it evolves in the future!
"""#,
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: "TODO",
  id: 32, // TODO
  publishedAt: .distantFuture, // TODO
  title: "A Crash Course in Combine"
)
