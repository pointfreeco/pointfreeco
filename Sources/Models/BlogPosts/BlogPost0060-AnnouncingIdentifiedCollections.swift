import Foundation

public let post0060_OpenSourcingIdentifiedCollections = BlogPost(
  author: .pointfree,
  blurb: """
Today we are open sourcing Identified Collections, a library of data structures for working with collections of identifiable elements in a performant way.
""",
  contentBlocks: [
    .init(
      content: #"""
We are excited to announce the 0.1.0 release of [Identified Collections](https://github.com/pointfreeco/swift-identified-collections) and its first member, `IdentifiedArray`: a data structure for working with collections of identifiable elements in a performant way.

This data structure may sound familiar because it first shipped with the initial release of the Composable Architecture. When we [open sourced](/blog/posts/41-composable-architecture-the-library) the library, it came with tools that assisted in breaking down larger features that work on collections of state into smaller features that work on individual elements of state. We even dedicated an [episode](/collections/case-studies/derived-behavior/ep148-derived-behavior-collections) to this topic recently.

For example, you may have a Todos app whose domain has been broken down and modularized so that a particular todo has its own isolated domain and logic:

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

The larger application can then integrate this domain into a collection of todos by holding them in state, introducing an action that can communicate todo actions to particular elements, and using the `Reducer.forEach` operation to glue everything together:

```swift
struct AppState {
  // 1️⃣ Hold onto a collection of todo states.
  var todos: [TodoState] = []
}

enum AppAction {
  // 2️⃣ Define an action that can be sent to a todo at a particular index.
  case todo(index: Int, action: TodoAction)
}

struct AppEnvironment { ... }

// 3️⃣ Use `forEach` to transform a reducer on a todo into a reducer on a collection of todos,
//    so long as we can provide the correct transformations.
let appReducer = todoReducer.forEach(
  state: \.todos,
  action: /AppAction.todo(index:action:),
  environment: { ... }
)
```

Unfortunately, arrays are not a great structure for solving this problem: while index offsets are an efficient means of executing a child domain's logic, they are not stable identifiers. A parent domain can move or remove elements from an array, which means an in-flight effect could lead to logic being performed on the wrong element, or worse, crash the application!

It is possible to avoid these issues by searching for an element with a particular id instead of subscripting into a particular offset:

```swift
let index = todos.firstIndex(where: { $0.id == id })
todoReducer.run(&todos[index], todoAction, todoEnvironment)
```

But this is a much less efficient operation, as we may have to traverse the entire array to locate a particular element.

So the Composable Architecture offered a solution to these problems with its very own data structure called [`IdentifiedArray`](https://github.com/pointfreeco/swift-composable-architecture/blob/d2240d0e76c1a758dbadbf737ceefc888b2e807c/Sources/ComposableArchitecture/SwiftUI/IdentifiedArray.swift). It evokes SwiftUI's collection-friendly APIs, like `ForEach`, by bundling up a collection of identifiable elements. Unlike the standard `Array`, identified arrays can efficiently read and modify elements with a particular identifier, which can be crucial to performance when managing large collections in your app's state.

With a few changes to our Todos domain, we can leverage this type:

```diff
 struct AppState {
   // 1️⃣ Hold onto a collection of todo states.
-  var todos: [TodoState] = []
+  var todos: IdentifiedArrayOf<TodoState> = []
 }

 enum AppAction {
-  // 2️⃣ Define an action that can be sent to a todo at a particular index.
-  case todo(index: Int, action: TodoAction)
+  // 2️⃣ Define an action that can be sent to a todo with a particular id.
+  case todo(id: TodoState.ID, action: TodoAction)
 }

 struct AppEnvironment { ... }

 // 3️⃣ Use `forEach` to transform a reducer on a todo into a reducer on a collection of todos,
 //    so long as we can provide the correct transformations.
 let appReducer = todoReducer.forEach(
   state: \.todos,
-  action: /AppAction.todo(index:action:),
+  action: /AppAction.todo(id:action:),
   environment: { ... }
 )
```

And now we can avoid all of the issues around indices and performance associated with standard arrays.

While `IdentifiedArray` solved a real problem on day one, it wasn't without [its issues](https://github.com/pointfreeco/swift-composable-architecture/search?q=identifiedarray&type=issues), and beyond the step it took to efficiently read and modify elements by their identifiers, it was completely unoptimized.

Well, we've turned our attention to these issues by extracting `IdentifiedArray` to its own library: [IdentifiedCollections](https://github.com/pointfreeco/swift-identified-collections). In it, `IdentifiedArray` has been completely rewritten as a safer, more performant wrapper around the `OrderedDictionary` type from Apple's [Swift Collections](https://github.com/apple/swift-collections). It even has similar performance characteristics.

![IdentifiedArray benchmarks from swift-collections-benchmark](TODO)

In order to avoid some of the pitfalls from the previous version of `IdentifiedArray` that shipped with the Composable Architecture, we [took inspiration](https://github.com/apple/swift-collections/blob/3426dba9ee5c9f8e4981b0fc9d39a818d36eec28/Documentation/OrderedDictionary.md#sequence-and-collection-operations) from Swift Collections by only partially conforming `IdentifiedArray` to some of collection protocols that are more problematic in producing invariants. While this is a breaking change, it should help prevent a whole slough of bugs, and we hope these changes will not affect most users. If you encounter any issues with the upgrade, or have any questions, please [start a GitHub discussion](https://github.com/pointfreeco/swift-identified-collections/discussions/new).

## Try it today

Head over to the [Identified Collections](https://github.com/pointfreeco/swift-identified-collections) repository to try the library out today. If you're building an application in the Composable Architecture, the [latest release](https://github.com/pointfreeco/swift-composable-architecture/releases/0.21.0) already uses IdentifiedCollections, so upgrade today and take it for a spin.
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 60,
  publishedAt: Date(timeIntervalSince1970: 1626066000),
  title: "Open Sourcing Identified Collections"
)
