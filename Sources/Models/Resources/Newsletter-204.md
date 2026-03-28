We are excited to announce a new feature of Point-Free: [Beta Previews]. It's
a great way for our most dedicated subscribers to help shape the future of our libraries and the
greater Point-Free ecosystem. And we are launching today with two betas already: a brand new 
library for exhaustively testing reference types, and a preview of Composable Architecture 2.0.

[Beta Previews]: /betas

## What are Beta Previews?

When we're working on a major new release or building a brand new library, there's a period where 
the code is functional but not yet ready for the public. During that time we're iterating on APIs, fixing
edge cases, and stress-testing ideas against real-world usage.

Historically we have used the development of [episodes](/episodes) to help finalize APIs and 
features of these libraries, but now [Beta Previews] give _you_ access to our experimental work before 
it goes public. You get a private GitHub invitation to the pre-release repo, where you can:

- Pull the library into your own projects and try it out
- Open issues and give feedback on API design
- Influence the direction of the library before it's locked in

We're launching with two betas today, and we plan to add more as new projects take shape.

---

## DebugSnapshots

The first beta is a brand new library: **DebugSnapshots**. It solves a problem that comes up
constantly when building apps with reference types, such as `@Observable` classes: how do you test 
them?

Classes cannot be meaningfully made `Equatable` due to their reference characteristics. It is
_not correct_ to use their underlying data for the `Equatable` conformance (and doing so can cause 
[many problems](/collections/back-to-basics/equatable-and-hashable)), but they often hold data that 
you do want to assert on as it changes over time. DebugSnapshots gives you a way to assert on the 
_content_ of your models, not their identity.

Once you apply the `@DebugSnapshot` macro to your class, the library generates an equatable, 
value-type snapshot of the class's underlying data. You can then use the `expect` function to
exhaustively assert how the data changes in the class after an action takes place.

Take for instance a feature model that allows you to increment a count and then fetch a fact
for that number:

```swift
@DebugSnapshot
@Observable
final class NumberFactModel {
  var count = 0
  var fact: String?
  var isLoading = false
  
  func incrementButtonTapped() {
    count += 1
    fact = nil
  }

  func factButtonTapped() async throws {
    isLoading = true
    defer { isLoading = false }
    fact = try await factClient.fetch(count)
  }
}
```

> Note: We are assuming we have a `factClient` dependency that can fetch facts for a number. You
may want to use our [Dependencies] library to control that dependency.

[Dependencies]: https://github.com/pointfreeco/swift-dependencies

Now you can write tests that exhaustively describe how the model changes when its various methods
are invoked:

```swift
@Test func increment() async {
  let model = NumberFactModel()

  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 1
  }
}
```

The first trailing closure allows you to execute any logic in your model, and the second trailing
closure allows you to assert how the underlying data in the model changed from _before_ that logic
to _after_ that logic. The `$0` handed to the closure is actually a value-type representation of 
the data in the class. That's the magic that allows you to exhaustively assert on this state even
though it's held in a reference type.

If you forget to assert a change, the test fails with a clear diff showing exactly what you missed:

```swift:7:fail
@Test func increment() async {
  let model = NumberFactModel()

  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 2
  }
}
```

> Failed: Issue recorded: Expected changes do not match: ...
>
> ```
>     #1 NumberFactModel.DebugSnapshot(
>   −   count: 2,
>   +   count: 1,
>       fact: nil,
>       isLoading: false
>     )
> 
> (Expected: −, Actual: +)
> ```

This is giving you exhaustive testing for classes, something that was previously only possible with 
value types.

The macro is also smart about what it includes. It automatically skips private properties, 
underscored properties, and computed properties. But, you can use `@DebugSnapshotTracked` to include
any of those properties if you wish.

This can be incredibly powerful to gain exhaustive testing on even computed properties:

```swift
@DebugSnapshot
@Observable
final class NumberFactModel {
  …
  @DebugSnapshotTracked var countIsEven: Bool {
    count.isMultiple(of: 2)
  }
}
```

Now when using `expect` you must assert how the computed property changes, otherwise you will
get a test failure:

```swift
@Test func increment() async {
  let model = NumberFactModel()

  expect(model) {
    model.incrementButtonTapped()
  } changes: {
    $0.count = 1
    $0.countIsEven = false
  }
}
```

You can also apply the `@DebugSnapshotConvertible` macro to reference-type properties in order to 
recursively snapshot nested `@DebugSnapshot` models:

```swift
@DebugSnapshot
@Observable
final class AppModel {
  @DebugSnapshotConvertible var settings: SettingsModel
  @DebugSnapshotConvertible var profile: ProfileModel
  …
}
```

Then in tests you can perform a nested mutation to assert how state changes:

```swift
expect(model) {
  model.disableNotificationsButtonTapped()
} changes: {
  $0.settings.isEmailOn = false
  $0.settings.isPushOn = false
  $0.settings.isTextOn = false
}
```

This is only a small preview of what the library is capable of.

---

## Composable Architecture 2.0

The second beta is the one many of you have been waiting for: **Composable Architecture 2.0**. This
is our biggest release ever, and is a fundamental redesign of how features are built, how side
effects are managed, and how composition works. The result is dramatically less boilerplate, a more
intuitive mental model, and testing that is more powerful than ever.

### The `@Feature` macro

The most visible change in 2.0, 



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

### Migration path

CLAUDE-DO: write about how we have a ComposableArchitecture1 shim module that can be linked to 
provide a smooth migration path to ComposableArchitecture 2.0. and talk about the SPM traits trick
we wrote about previously in Newsletter-203.md to also provide a smooth migration path.

---

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
