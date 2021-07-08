import Foundation

public let post0060_BetterPerformanceBonanza = BlogPost(
  author: .pointfree,
  blurb: """
The past 3 weeks we've shipped 3 library releases focussed on improving the performance of your Composable Architecture applications, and more!
""",
  contentBlocks: [
  .init(
    content: #"""
This past month we spent time improving the performance of several of our more popular libraries that are used in building applications in the Composable Architecture. Let's recap those changes, explore some improvements that came in from the community, and celebrate the release of a branch new library.

## Composable Architecture 0.21.0

First, we released a new version of [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture), our library for building applications in a consistent and understandable way, with composition, testing, and ergonomics in mind. It included [a number of performance improvements](https://github.com/pointfreeco/swift-composable-architecture/releases/0.20.0) in the architecture's runtime. We reduced the amount of work performed by the store and view store by pushing [a few small changes](https://github.com/pointfreeco/swift-composable-architecture/pull/616). We covered these changes in [a dedicated episode](https://www.pointfree.co/episodes/ep151-composable-architecture-performance-view-stores-and-scoping) that both identified the problem and worked through the solution.

While we made some great strides in this release, we did note that there was still more room for improvement, and a member of the community quickly came in to close the gap! Just a day later, [Pat Brown](https://github.com/iampatbrown) submitted [a pull request](https://github.com/pointfreeco/swift-composable-architecture/pull/624) that completely eliminated extra work being done in the view store. 😃

These changes have since been merged and today will be available in [a new version](https://github.com/pointfreeco/swift-composable-architecture/releases/0.21.0).

## Case Paths 0.4.0

Next, we released a new version of [Case Paths](https://github.com/pointfreeco/swift-case-paths), our library that brings the power and ergonomics of key paths to enums. While key paths let you write code that abstracts over the field of a struct, case paths let you write code that abstracts over a particular case of an enum. Case paths are quite useful in their own right, but they also play an integral part in modularizing applications, especially those written in the Composable Architecture, which comes with many compositional operations that take key paths and case paths.

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

And this is why we [used reflection and a custom operator](https://www.pointfree.co/episodes/ep89-case-paths-for-free) to make case paths just as ergonomic and concise:

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

So we focused on closing the gap by [utilizing the Swift runtime](https://github.com/pointfreeco/swift-case-paths/pull/35) metadata, a change that shipped in [a new version](https://github.com/pointfreeco/swift-case-paths/releases/0.3.0). We covered these improvements in [last week's episode](https://www.pointfree.co/episodes/ep152-composable-architecture-performance-case-paths).

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

## Identified Arrays 0.1.0

Finally, this week we are releasing a _brand new library_ for a feature that shipped with the Composable Architecture on day one. When we [first open sourced](/blog/posts/41-composable-architecture-the-library) the library, it came with tools that assisted in breaking down larger features that work on collections of state into smaller features that work on individual elements of state.

For example, you may have a Todos app that has been broken down so that a particular todo has its own domain and logic:

```swift
struct TodoState: Identifiable {
  var description = ""
  let id: UUID
  var isComplete = false
}

enum TodoAction {
  case descriptionChanged(String)
  case tappedCheckBox
}

struct TodoEnvironment { ... }

let todoReducer = Reducer<TodoState, TodoAction, TodoEnvironment> { ... }
```

The larger application can then integrate this domain into a collection of todos by holding them in state, introducing an action to communicate todo actions to particular elements, and using the `Reducer.forEach` operation to glue it all together:

```swift
struct AppState {
  var todos: [TodoState] = []
}

enum AppAction {
  // An action that can be sent to a todo at a particular offset.
  case todo(index: Int, action: TodoAction)
}

struct AppEnvironment { ... }

// We can use `forEach` to transform a reducer on a todo into a reducer on a array of
// todos, so long as we can provide the correct transformations.
let appReducer = todoReducer.forEach(
  state: \.todos,
  action: /AppAction.todo(index:action:),
  environment: { ... }
)
```

Unfortunately, arrays are not a great structure for solving this problem: while index offsets are an efficient means of executing a child domain's logic, they are not stable identifiers. A parent domain can move or remove elements from an array, which means an in-flight effect could deliver its action to the wrong element, or worse, crash the application!

One could avoid these issues by searching for an element with a particular id instead of subscripting into a particular offset:

```swift
let index = todos.firstIndex(where: { $0.id == id })
todoReducer.run(&todos[index], todoAction, todoEnvironment)
```

But this is much less efficient operation, as we may have to traverse the entire array to locate a particular element.

And so the Composable Architecture offered a solution to these problems with its very own data structure, called [`IdentifiedArray`](https://github.com/pointfreeco/swift-composable-architecture/blob/d2240d0e76c1a758dbadbf737ceefc888b2e807c/Sources/ComposableArchitecture/SwiftUI/IdentifiedArray.swift). It evokes SwiftUI's collection-friendly APIs, like `ForEach`, by bundling up a sequence of identifiable elements. Unlike the standard `Array`, identified arrays can efficiently read and modify elements with a particular identifier, which can be performance-critical when managing large collections of elements in state.

With a few changes to our Todos domain, we can leverage this type:

```swift
struct AppState {
  var todos: IdentifiedArrayOf<TodoState> = []
}

enum AppAction {
  // An action that can be sent to a todo with a particular id.
  case todo(id: TodoState.ID, action: TodoAction)
}

struct AppEnvironment { ... }

// The `forEach` operation works just as well for identified arrays, but the action
// identifies an element by its id, not offset.
let appReducer = todoReducer.forEach(
  state: \.todos,
  action: /AppAction.todo(id:action:),
  environment: { ... }
)
```

While `IdentifiedArray` solved a real problem on day one, it wasn't without [its issues](https://github.com/pointfreeco/swift-composable-architecture/search?q=identifiedarray&type=issues), and outside the efficiency of reading and modifying elements, it was completely unoptimized.

Well, this week we've turned our attention to these issues by extracting `IdentifiedArray` to its own library: [IdentifiedCollections](https://github.com/pointfreeco/swift-identified-collections). `IdentifiedArray` has been completely rewritten as a safer, more performant wrapper around the `OrderedDictionary` type from Apple's [Swift Collections](https://github.com/apple/swift-collections). It even has similar performance characteristics.

![IdentifiedArray benchmarks from swift-collections-benchmark](TODO)

In order to avoid some of the pitfalls from earlier releases, we took inspiration from Swift Collections by only partially conforming `IdentifiedArray` to some of the more problematic collection protocols.

The latest release of the Composable Architecture already depends on it, so upgrade today and take it for a spin.

## Try them out today!

If you're building a Composable Architecture application, upgrade to [version 0.21.0](https://github.com/pointfreeco/swift-composable-architecture/releases/0.21.0) today to see all of these improvements. Or even if you don't use the Composable Architecture, you may find [CasePaths 0.4.0](https://github.com/pointfreeco/swift-case-paths/releases/0.4.0) and [IdentifiedCollections 0.1.0](https://github.com/pointfreeco/swift-identified-collections/releases/0.1.0) useful on their own.
"""#,
    type: .paragraph
  )
  ],
  coverImage: nil,
  id: 60,
  publishedAt: Date(timeIntervalSince1970: 1626066000),
  title: "Better Performance Bonanza"
)
