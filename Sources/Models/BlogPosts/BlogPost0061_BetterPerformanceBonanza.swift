import Foundation

public let post0061_BetterPerformanceBonanza = BlogPost(
  author: .pointfree,
  blurb: """
The past 3 weeks we've shipped 3 library releases focused on improving the performance of your Composable Architecture applications, and more!
""",
  contentBlocks: [
  .init(
    content: #"""
This past month we spent time improving the performance of several of our more popular libraries that are used in building applications in the Composable Architecture. Let's recap those changes, explore some improvements that came in from the community, and celebrate the release of a branch new library.

## Composable Architecture 0.21.0

First, we released a [new version](https://github.com/pointfreeco/swift-composable-architecture/releases/0.20.0) of the Composable Architecture, our library for building applications in a consistent and understandable way, with composition, testing, and ergonomics in mind. It includes a number of performance improvements in the architecture's runtime, which were covered in a [dedicated episode](/episodes/ep151-composable-architecture-performance-view-stores-and-scoping). In particular we [reduced](https://github.com/pointfreeco/swift-composable-architecture/pull/616) the number of times scoping transformations and equality operators are invoked. This helps massively [reduce](https://github.com/pointfreeco/swift-composable-architecture/pull/616/files#diff-7ab38c8d80571066ebf95b63685ffdafaa82c427dee15c78672d5576ebe802f6L197-R199) the work performed for well-modularized applications.

While we made some great strides in this release, we did note that there was still more room for improvement, and a member of the community quickly came in to close the gap! Just a day later, [Pat Brown](https://github.com/iampatbrown) submitted [a pull request](https://github.com/pointfreeco/swift-composable-architecture/pull/624) that fully minimized the number of equality checks performed in the view store. 😃

These changes have since been merged and today will be available in [a new version](https://github.com/pointfreeco/swift-composable-architecture/releases/0.21.0).

## Case Paths 0.4.0

Next, we released a new version of [Case Paths](https://github.com/pointfreeco/swift-case-paths), our library that brings the power and ergonomics of key paths to enums. While key paths let you write code that abstracts over a field of a struct, case paths let you write code that abstracts over a particular case of an enum. Case paths are quite useful in their own right, but they also play an integral part in modularizing applications, especially those written in the Composable Architecture, which comes with many compositional operations that take key paths and case paths.

While a key path consists of a getter and setter, a case path consists of a pair of functions that can attempt to extract a value from, or embed a value in, a particular enum. For example, given an enum with a couple cases:

```swift
enum AppState {
  case loggedIn(LoggedInState)
  case loggedOut(LoggedOutState)
}
```

We can construct a case path for the `loggedIn` case that can embed or extract a value of `LoggedInState`:

```swift
CasePath(
  embed: AppState.loggedIn,
  extract: { appState in
    guard case let .loggedIn(state) = appState else { return nil }
    return state
  }
)
```

This is, unfortunately, a lot of boilerplate to write and maintain for what should be simple, especially when we consider that Swift's key paths come with a very succinct syntax:

```swift
\String.count
```

And this is why we [used reflection and a custom operator](/episodes/ep89-case-paths-for-free) to make case paths just as ergonomic and concise:

```swift
/AppState.loggedIn
```

Unfortunately, reflection can be quite slow when compared to the work done in a more manual way, as a benchmark will show:

```
name       time        std         iterations
---------------------------------------------
Manual       41.000 ns ± 243.49 %     1000000
Reflection 8169.000 ns ±  55.03 %      106802
```

So we focused on closing the gap by [utilizing the Swift runtime](https://github.com/pointfreeco/swift-case-paths/pull/35) metadata, a change that shipped in [a new version](https://github.com/pointfreeco/swift-case-paths/releases/0.3.0). We covered these improvements in [last week's episode](/episodes/ep152-composable-architecture-performance-case-paths).

With these changes, the happy path of extracting a value was over twice as fast as it was previously, while the path for failure was almost as fast as manual failure.

```
name                time        std        iterations
-----------------------------------------------------
Manual                39.000 ns ± 266.87 %    1000000
Reflection          3399.000 ns ±  85.54 %     354827
Manual: Failure       36.000 ns ± 608.33 %    1000000
Reflection: Failure   80.000 ns ± 588.42 %    1000000
```

But it gets even better! Again, shortly after release, a member of the community stepped in to make case path reflection almost as fast as the manual alternative. [Rob Mayoff](https://twitter.com/rmayoff) dove deeper into the Swift runtime and surfaced with [a pull request](https://github.com/pointfreeco/swift-case-paths/pull/36) that leverages runtime functionality that can extract a value from an enum case without any of the reflection overhead:

```
name               time       std        iterations
---------------------------------------------------
Success.Manual      35.000 ns ± 158.00 %    1000000
Success.Reflection 167.000 ns ±  70.60 %    1000000
Failure.Manual      37.000 ns ± 197.47 %    1000000
Failure.Reflection  82.000 ns ± 135.63 %    1000000
```

That's over 50x faster than the original! 🤯

You can already see these improvements in [CasePaths 0.4.0](https://github.com/pointfreeco/swift-case-paths/releases/0.4.0), released late last week.

## Identified Collections 0.1.0

Finally, on Monday [we open sourced a _brand new library_](/blog/posts/60-open-sourcing-identified-collections) called [IdentifiedCollections](https://github.com/pointfreeco/swift-identified-collections). This library hosts `IdentifiedArray`, a feature that shipped with [the initial release](/blog/posts/41-composable-architecture-the-library) of the Composable Architecture.

This data structure has now been extracted to its own package and rewritten to be more performant and correct. Check out [the announcement](/blog/posts/60-open-sourcing-identified-collections) for more details!

## Try them out today!

If you're building a Composable Architecture application, upgrade to [version 0.21.0](https://github.com/pointfreeco/swift-composable-architecture/releases/0.21.0) today to see all of these improvements. Or even if you don't use the Composable Architecture, you may find [CasePaths 0.4.0](https://github.com/pointfreeco/swift-case-paths/releases/0.4.0) and [IdentifiedCollections 0.1.0](https://github.com/pointfreeco/swift-identified-collections/releases/0.1.0) useful on their own.
"""#,
    type: .paragraph
  )
  ],
  coverImage: nil,
  id: 61,
  publishedAt: Date(timeIntervalSince1970: 1626238800),
  title: "Better Performance Bonanza"
)
