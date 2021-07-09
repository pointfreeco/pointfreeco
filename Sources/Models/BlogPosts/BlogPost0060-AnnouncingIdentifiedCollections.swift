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

## Motivation

When modeling a collection of elements in your application's state, it is easy to reach for a standard `Array`. However, as your application becomes more complex, this approach can break down in many ways.

For example, if you were building a "Todos" application in SwiftUI, you might model an individual todo in an identifiable value type:

```swift
struct Todo: Identifiable {
  var description = ""
  let id: UUID
  var isComplete = false
}
```

And you would hold an array of these todos as a published field in your app's state:

```swift
class TodosViewModel: ObservableObject {
  @Published var todos: [Todo] = []
}
```

A view can render a list of these todos quite simply, and because they are identifiable we can even omit the `id` parameter of `List`:

```swift
struct TodosView: View {
  @ObservedObject var viewModel: TodosViewModel

  var body: some View {
    List(self.viewModel.todos) { todo in
      ...
    }
  }
}
```

If your deployment target is set to the latest version of SwiftUI, you may be tempted to pass along a binding to the list so that each row is given mutable access to its todo. This will work for simple cases, but as soon as you introduce side effects, like API clients or analytics, or want to write unit tests, you must push this logic into a view model, instead. And that means each row must be able to communicate its actions back to the view model.

You could do so by introducing some endpoints:

```swift
class TodosViewModel: ObservableObject {
  ...
  func todoCheckboxToggled(at id: Todo.ID) {
    guard let index = self.todos.firstIndex(where: { $0.id == id })
    else { return }

    self.todos[index].isComplete.toggle()
    // TODO: sync with API
  }
}
```

This code is simple enough, but it can require a full traversal of the array to do its job.

Perhaps it would be more performant for a row to communicate its index back to the view model instead, and then it could mutate the todo directly via its index subscript. But this makes the view more complicated:

```swift
List(self.viewModel.todos.enumerated(), id: \.element.id) { index, todo in
  ...
}
```

This isn't so bad, but at the moment it doesn't even compile. An [evolution proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0312-indexed-and-enumerated-zip-collections.md) may change that soon, but in the meantime `List` and `ForEach` must be passed a `RandomAccessCollection`, which is perhaps most achieved done by constructing another array:

```swift
List(Array(self.viewModel.todos.enumerated()), id: \.element.id) { index, todo in
  ...
}
```

This compiles, but we've just moved the performance problem to the view: every time this body is evaluated there's the possibility a whole new array is being allocated.

But even if it were possible to pass an enumerated collection directly to these views, identifying an element of mutable state by an index introduces a number of other problems.

While it's true that we can greatly simplify and improve the performance of any view model methods that mutate an element through its index subscript:

```swift
class TodosViewModel: ObservableObject {
  ...
  func todoCheckboxToggled(at index: Int) {
    self.todos[index].isComplete.toggle()
    // TODO: sync with API
  }
}
```

Any asynchronous work that we add to this endpoint must take great care in _not_ using this index later on. An index is not a stable identifier: todos can be moved and removed at any time, and an index identifying "Buy lettuce" at one moment may identify "Call Mom" the next, or worse, may be a completely invalid index and crash your application!

```swift
class TodosViewModel: ObservableObject {
  ...
  func todoCheckboxToggled(at index: Int) {
    self.todos[index].isComplete.toggle()

    self.apiClient.updateTodo(self.todos[index]) { updatedTodo, error in
      guard let updatedTodo = updatedTodo else { ... }

      // Could update the wrong todo, or crash!
      self.todos[index] = updatedTodo // ❌
    }
  }
}
```

Whenever you need to access a particular todo after performing some asynchronous work, you _must_ do the work of traversing the array:

```swift
class TodosViewModel: ObservableObject {
  ...
  func todoCheckboxToggled(at index: Int) {
    self.todos[index].isComplete.toggle()

    // 1️⃣ Get a reference to the todo's id before kicking off the async work
    let id = self.todos[index].id

    self.apiClient.updateTodo(self.todos[index]) { updatedTodo, error in
      guard
        let updatedTodo = updatedTodo,
        // 2️⃣ Find the updated index of the todo
        let updatedIndex = self.todos.firstIndex(where: { $0.id == id })
      else { ... }

      // 3️⃣ Update the correct todo
      self.todos[updatedIndex] = updatedTodo
    }
  }
}
```

## Introducing: identified collections

Identified collections are designed to solve all of these problems by providing data structures for working with collections of identifiable elements in an ergonomic, performant way.

Most of the time, you can simply swap an `Array` out for an `IdentifiedArray`:

```swift
import IdentifiedCollections

class TodosViewModel: ObservableObject {
  @Published var todos: IdentifiedArrayOf<Todo> = []
  ...
}
```

And then you can mutate an element directly via its id-based subscript, no traversals needed, even after asynchronous work is performed:

```swift
class TodosViewModel: ObservableObject {
  ...
  func todoCheckboxToggled(at id: Todo.ID) {
    self.todos[id: id]?.isComplete.toggle()

    self.apiClient.updateTodo(self.todos[index]) { updatedTodo, error in
      guard let updatedTodo = updatedTodo else { ... }

      self.todos[id: id] = updatedTodo // ✅
    }
  }
}
```

You can also simply pass the identified array to views like `List` and `ForEach` without any complications:

```swift
List(self.viewModel.todos) { todo in
  ...
}
```

Identified arrays are designed to integrate with SwiftUI applications, as well as applications written in [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).

## Design

`IdentifiedArray` is a lightweight wrapper around the [`OrderedDictionary`](https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md) type from Apple's [Swift Collections](https://github.com/apple/swift-collections). It shares many of the same performance characteristics and design considerations, but is better adapted to solving the problem of holding onto a collection of _identifiable_ elements in your application's state.

`IdentifiedArray` does not expose any of the details of `OrderedDictionary` that may lead to invariants. For example an `OrderedDictionary<ID, Identifiable>` may freely hold a value whose identifier does not match its key.

And unlike [`OrderedSet`](https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md), `IdentifiedArray` does not require that its `Element` type conforms to `Hashable` protocol, which may be difficult or impossible to do, and introduces questions around the quality of hashing, etc.

`IdentifiedArray` does not even require that its `Element` conforms to `Identifiable`. Just as SwiftUI's `List` and `ForEach` views take an `id` key path to an element's identifier, `IdentifiedArray`s can be constructed with a key path:

```swift
var numbers = IdentifiedArray(id: \Int.self)
```

## Performance

`IdentifiedArray` is designed to match the performance characteristics of `OrderedDictionary`. It has been benchmarked with [Swift Collections Benchmark](https://github.com/apple/swift-collections-benchmark):

![](https://github.com/pointfreeco/swift-identified-collections/raw/main/.github/benchmark.png)

## `IdentifiedArray` and the Composable Architecture

This data structure may sound familiar because it first shipped with the initial release of the Composable Architecture. When we [open sourced](/blog/posts/41-composable-architecture-the-library) the library over 15 months ago, it came with tools that assisted in breaking down larger features that work on collections of state into smaller features that work on individual elements of state, and this included `IdentifiedArray`. We even dedicated an [episode](/collections/case-studies/derived-behavior/ep148-derived-behavior-collections) to this topic recently.

While `IdentifiedArray` solved a real problem when we first introduced it, it wasn't without [its issues](https://github.com/pointfreeco/swift-composable-architecture/search?q=identifiedarray&type=issues). Its original implementation made it easy to break the semantics of the type (e.g. having exactly at most one element for each id), and it was mostly unoptimized, causing it to have quite bad performance characteristics for certain collection operations.

The `IdentifiedArray` that comes with [Identified Collections](https://github.com/pointfreeco/swift-identified-collections) has been completely rewritten as a safer, more performant wrapper around `OrderedDictionary`. In order to avoid some of the pitfalls from the previous version of `IdentifiedArray` that shipped with the Composable Architecture, we [took inspiration](https://github.com/apple/swift-collections/blob/3426dba9ee5c9f8e4981b0fc9d39a818d36eec28/Documentation/OrderedDictionary.md#sequence-and-collection-operations) from Swift Collections by only partially conforming `IdentifiedArray` to some of collection protocols that are more problematic in producing invariants. While this is a breaking change, it should help prevent a whole slew of bugs, and we hope these changes will not affect most users. If you encounter any issues with the upgrade, or have any questions, please [start a GitHub discussion](https://github.com/pointfreeco/swift-identified-collections/discussions/new).

## Try it today

Head over to the [Identified Collections](https://github.com/pointfreeco/swift-identified-collections) repository to try the library out today. If you're building an application in the Composable Architecture, the [latest release](https://github.com/pointfreeco/swift-composable-architecture/releases/0.21.0) already uses Identified Collections, so upgrade today and take it for a spin.
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 60,
  publishedAt: Date(timeIntervalSince1970: 1626066000),
  title: "Open Sourcing Identified Collections"
)
