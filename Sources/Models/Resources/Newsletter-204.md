<!--
We are excited to announce a new feature of the Point-Free website:
[Beta Previews](/betas). It's something we've wanted to do for a long time, and we think it's going
to be a great way for our most dedicated subscribers to help shape the future of our libraries.

## What are Beta Previews?

When we're working on a major new release or building a brand new library, there's a period where the
code is functional but not yet ready for the public. During that time we're iterating on APIs, fixing
edge cases, and stress-testing ideas against real-world usage.

Beta Previews give you access to that work _before_ it goes public. You get a private GitHub
invitation to the pre-release repo, where you can:

- Pull the library into your own projects and try it out
- Open issues and give feedback on API design
- Influence the direction of the library before it's locked in

We're launching with two betas today, and we plan to add more as new projects take shape.

## Composable Architecture 2.0

The first beta is the one many of you have been waiting for: **Composable Architecture 2.0**. This
is our biggest release ever — a fundamental redesign that rethinks how features are built, how side
effects are managed, and how composition works. The result is dramatically less boilerplate, a more
intuitive mental model, and testing that is more powerful than ever.

### The `@Feature` macro

In TCA 1.x you defined features by conforming to the `Reducer` protocol. In 2.0, the `@Feature`
macro does the heavy lifting:

```swift
@Feature struct Counter {
  struct State {
    var count = 0
  }
  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
  }
  var body: some Feature {
    Update { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
      case .incrementButtonTapped:
        state.count += 1
      }
    }
  }
}
```

The macro generates all the conformances and wiring you used to write by hand. State and action
types are just plain types nested inside the feature, and the `body` property uses a builder to
compose your feature's logic — similar to how SwiftUI's `View` protocol describes UI, `Feature`
describes business logic.

Notice there's no `Effect` return type. In TCA 2.0 the `Update` feature handles synchronous state
mutations directly, and async work is handled through a completely new mechanism.

### Side effects with `store`

TCA 1.x required you to return `Effect` values from your reducer. In 2.0, you use the `store`
property to kick off async work directly:

```swift
@Feature struct FactFeature {
  struct State {
    var count = 0
    var fact: String?
    var isLoading = false
    @StoreTaskID var factRequest
  }
  enum Action {
    case factButtonTapped
    case cancelButtonTapped
    case factResponse(String)
  }
  var body: some Feature {
    Update { state, action in
      switch action {
      case .factButtonTapped:
        state.isLoading = true
        store.addTask(id: state.factRequest) {
          let (data, _) = try await URLSession.shared
            .data(from: URL(string: "http://numberapi.com/\(store.count)")!)
          try store.send(.factResponse(String(decoding: data, as: UTF8.self)))
        }
      case .cancelButtonTapped:
        store.addTask { await store.factRequest.cancel() }
      case .factResponse(let fact):
        state.fact = fact
        state.isLoading = false
      }
    }
  }
}
```

`store.addTask` schedules async work, and `@StoreTaskID` gives you automatic cancellation tracking
— no more managing raw cancellation IDs by hand.

### Lifecycle hooks

TCA 2.0 adds lifecycle hooks that replace many patterns that were awkward in 1.x:

```swift
Update { state, action in
  // ...
}
.onMount { state in
  state.isLoading = true
}
.onChange(of: state.query) { oldValue, state in
  store.addTask(id: state.searchRequest) {
    try await Task.sleep(for: .seconds(0.3))
    let results = try await search(store.query)
    try store.send(.searchResponse(results))
  }
}
.onDismount { state in
  try await cleanup(state)
}
```

`onMount` runs once when the feature's store is created, `onChange` reacts to state changes, and
`onDismount` handles cleanup. These replace the common pattern of sending an `.onAppear` action from
SwiftUI.

### Composition

Child features compose naturally with `Scope`, `ifLet`, and `forEach`:

```swift
@Feature struct ParentFeature {
  struct State {
    var counter = Counter.State()
    var detail: Detail.State?
    var items: [Item.State] = []
  }
  // ...
  var body: some Feature {
    Update { state, action in ... }
    Scope(state: \.counter, action: \.counter) {
      Counter()
    }
    .ifLet(\.detail, action: \.detail) {
      Detail()
    }
    .forEach(\.items, action: \.item, id: \.id) {
      Item()
    }
  }
}
```

### Testing

`TestStore` integrates with our new [DebugSnapshots](#debugsnapshots) library for snapshot-based
state assertions:

```swift
@Test func incrementAndLoadFact() async {
  let store = TestStore(initialState: FactFeature.State()) {
    FactFeature()
  }

  store.send(.incrementButtonTapped) {
    $0.count = 1
  }
  store.send(.factButtonTapped) {
    $0.isLoading = true
  }
  await store.receive(\.factResponse) {
    $0.fact = "1 is the loneliest number."
    $0.isLoading = false
  }
}
```

Because `TestStore` uses snapshots under the hood, it can test features whose state contains
non-equatable types and reference types — something that was impossible in 1.x.

## DebugSnapshots

The second beta is a brand new library: **DebugSnapshots**. It solves a problem that comes up
constantly when building apps with `@Observable` classes: how do you test them?

Classes aren't `Equatable`, they can contain closures and other non-equatable types, and their
reference semantics make simple equality assertions meaningless. DebugSnapshots gives you a way to
assert on the _content_ of your models, not their identity.

The core idea: apply the `@DebugSnapshot` macro to your class, and the library generates an
equatable, value-type snapshot that mirrors your model's public state. You can then use the `expect`
function to assert exactly how that snapshot changes:

```swift
@DebugSnapshot
@Observable
final class SearchModel {
  var query = ""
  var results: [String] = []
  var isLoading = false

  func searchButtonTapped() async {
    isLoading = true
    results = await search(query)
    isLoading = false
  }
}
```

Now you can write tests that exhaustively describe how the model changes:

```swift
@Test func search() async {
  let model = SearchModel()
  model.query = "Blob"

  await expect(model) {
    await model.searchButtonTapped()
  } changes: {
    $0.results = ["Blob", "Blob Jr.", "Blob Sr."]
  }
}
```

If you forget to assert a change — say `isLoading` flipped to `true` and back — the test fails with
a clear diff showing exactly what you missed. This is exhaustive testing for classes, something that
was previously only possible with value types.

The macro is smart about what it includes. It automatically skips private properties, underscored
properties, and computed properties. You can override this with `@DebugSnapshotTracked` to include
a computed property, `@DebugSnapshotIgnored` to exclude a public one, or
`@DebugSnapshotConvertible` to recursively snapshot nested `@DebugSnapshot` models:

```swift
@DebugSnapshot
@Observable
final class AppModel {
  var userName = ""
  @DebugSnapshotConvertible var settings: SettingsModel?
  @DebugSnapshotIgnored var analyticsID: UUID
  @DebugSnapshotTracked var isLoggedIn: Bool {
    !userName.isEmpty
  }
}
```

You can also use `expect` non-exhaustively — without an `operation` closure — to assert on just the
fields you care about:

```swift
model.query = "Blob"
expect(model) {
  $0.query = "Blob"
}
```

And for debugging, the `diff` function prints how a model changes over an operation:

```swift
diff(model) {
  model.searchButtonTapped()
}
// Difference: ...
//
//     SearchModel(
//   -   results: []
//   +   results: ["Blob", "Blob Jr."]
//     )
//
// (Before: -, After: +)
```

## How to get access

Beta Previews are available exclusively to subscribers of our
[Point-Free Max](/pricing) plan. Max subscribers can visit the
[Beta Previews](/betas) page and join any open beta with a single click. You'll receive a GitHub
invitation to the private repo, and from there you can pull the library into your projects
immediately.

If you're already a Max subscriber, head over to [Beta Previews](/betas) now to get started. If
you're not yet a member, check out our [plans](/pricing) to see everything that's included.

We have more betas planned, and Max subscribers will automatically get access to every new one as
it opens. We can't wait to hear what you think.

[custom-dump-gh]: https://github.com/pointfreeco/swift-custom-dump
--!>
