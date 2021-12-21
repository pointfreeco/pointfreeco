import Foundation

public let post0068_YIR2021 = BlogPost(
  author: .pointfree,
  blurb: """
TODO
""",
  contentBlocks: [
    .init(
      content: """
It's the end of the year again, and we’re feeling nostalgic 😊. We’re really proud of everything we produced for 2021, so join us for a quick review of some of our favorite highlights.

We are also offering [25% off](/discounts/2021-eoy) the first year for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now is the time!

# Highlights

2021 was our biggest year yet:

* **42** episodes released for a total of **29** hours of video.
* **72k** unique vistors to the site.
* Over **124k** video views, **4 years and 100 days** watching time, and over **42 terabytes** of video streamed.
* Open sourced **5** new [projects](#open-source).

But these high-level stats don’t scratch the surface of what we covered in 2021:

## SwiftUI Navigation

By far, the most ambitious series of episodes we tackled in 2021 was [SwiftUI Navigation](/collections/swiftui/navigation). Over the course of 9 episodes we gave a precise definition of what navigation means in an application, explored SwiftUI's navigation tools (including tabs, alerts, modal sheets, and links), and then showed how to build new navigation tools that allow us to model our domains more concisely and correctly.

After completing that series we [open sourced](/blog/posts/66-open-sourcing-swiftui-navigation) a [library](https://github.com/pointfreeco/swiftui-navigation) with all the tools discussed in the series. This makes it easy to model navigation in your application using optionals and enums, and makes it straightforward to drive deep-linking with your domain's state.

We also used the application built in the series to explore two additional topics at the end of the year. First, we rebuilt the application in UIKit ([part 1](/episodes/ep169-uikit-navigation-part-1), [part 2](/episodes/ep170-uikit-navigation-part-2)), all without making a single change to the view model layer. This shows just how powerful it is to drive navigation off of state. Second, we explored modularity ([part 1](/episodes/ep171-modularization-part-1), [part 2](/episodes/ep172-modularization-part-2)) by breaking down the application into many modules. Along the way to explored different types of modularity, how to structure a modern Xcode project with SPM, and how to build preview apps that allow you to run small portions of your code base without building the entire application.

<div id="open-source"></div>

## Open Source

Since launching Point-Free in 2018 we have open sourced over 20 projects, and this year alone we released 5 new projects (3 of which were extracted from our [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) library):

### [isowords](https://github.com/pointfreeco/isowords)

In May of this year we released a word game for iOS called [isowords](https://www.isowords.xyz). Alongside the release we also open sourced the entire code base. Both the client and server code are written in Swift, and the client code shows how to build a large, modularized application in SwiftUI and the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).

### [xctest-dynamic-overlay](https://github.com/pointfreeco/xctest-dynamic-overlay)

It is very common to write test support code for libraries and applications, but due to how Xcode works one cannot do this easily. If you import `XCTest` in a file, then that file cannot be compiled to run on a simulator or device. This forces you to extract test helper code into its own target/module, even though ideally the code should live right next to your library code.

The `xctest-dynamic-overlay` library makes it possible to use the `XCTFail` assertion function from `XCTest` in library and application code. It will dynamically find the `XCTFail` implementation in tests, and act as a no-op outside of tests.

### [swift-identified-collections](https://github.com/pointfreeco/swift-identified-collections)

When modeling a collection of elements in your application's state, it is easy to reach for a standard `Array`. However, as your application becomes more complex, this approach can break down in many ways, including accidentally making mutations to the wrong elements or even crashing. 😬

Identified collections are designed to solve all of these problems by providing data structures for working with collections of identifiable elements in an ergonomic, performant way.

### [swift-custom-dump](https://github.com/pointfreeco/swift-custom-dump)

Swift comes with a wonderful tool for debug-printing the contents of any value to a string, and it's called `dump`. It prints all the fields and sub-fields of a value into a tree-like description. However, the output is less than ideal: dictionaries are printed in non-deterministic order, values are printed with superfluous extra type information, and some types don't print any useful information at all.

The [swift-custom-dump](https://github.com/pointfreeco/swift-custom-dump) library ships with a function that emulates the behavior of dump, but provides a more refined output of nested structures, optimizing for readability. Further, it uses the more refined output to provide two additional tools. One for outputting a nicely formatted diff between two values of the same type, and another that acts as a drop-in replacement for `XCTAssertEqual` with a much better error message when a test fails.

### [swiftui-navigation](https://github.com/pointfreeco/swiftui-navigation)

A collection of tools for making SwiftUI navigation simpler, more ergonomic and more precise. The library allows you to model your application's navigation as optionals and enums, and then provides the tools for driving alerts, modal sheets, and navigation links from state.

# 🎉 2022 🎉

We're thankful to all of our subscribers for supporting us and helping us create this content and these libraries. We could not do it without you.

Next year we have even more planned, including a deep dive into Swift's new concurrency tools, improvements to the Composable Architecture to play better with concurrency and SwiftUI navigation, as well as all new parsing episodes (including result builders, reversible parsing, routing) and more!

To celebrate the end of the year we are also offering [25% off](/discounts/2021-eoy) the first year for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now is the time!

See you in 2022!
""",
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 68,
  publishedAt: Date(timeIntervalSince1970: 1640210400),
  title: "2021 Year-in-review"
)
