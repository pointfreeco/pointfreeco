We are excited to announce a new feature of Point-Free: [Beta Previews]. It's
a great way for our most dedicated subscribers to help shape the future of our libraries and the
greater Point-Free ecosystem. And we are launching today with two betas already: a brand new 
library for exhaustively testing reference types, and a preview of ComposableArchitecture 2.0.

[Beta Previews]: /betas

# What are Beta Previews?

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

# DebugSnapshots

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
the data in the class, and that's how you can exhaustively assert on this state even though it's 
held in a reference type.

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
any of those properties if you wish. This can be incredibly powerful to gain exhaustive testing on 
even computed properties:

```swift
@DebugSnapshot
@Observable
final class NumberFactModel {
  …
  @DebugSnapshotTracked 
  var countIsEven: Bool {
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

This is only a small preview of what the library is capable of, and it turned out to be quite
important for the second beta we are previewing today…

---

# ComposableArchitecture 2.0

The second beta is the one many of you have been waiting for: **ComposableArchitecture 2.0**. This
is our biggest release ever, and is a fundamental redesign of how features are built, how side
effects are managed, how features communicate, how features are tested, and a lot more. The result 
is dramatically less boilerplate, a more intuitive mental model, and testing that is more powerful 
than ever.

If many of these APIs feel familiar, that's by design. We intentionally mirror SwiftUI's
vocabulary (`onChange`, preferences, etc.) so that the mental model you
already have for views translates directly to business logic. Where SwiftUI's `View` protocol
describes _what to render_, `Feature` describes _what to do_. And by moving these concepts into
a simpler, more controlled environment, it all becomes 100% unit testable.

- [The `@Feature` macro](#the-feature-macro)
- [Better bindings](#better-bindings)
- [Feature stores](#feature-stores)
- [Better encapsulation](#better-encapsulation)
- [Lifecycle hooks](#lifecycle-hooks)
- [Communication patterns](#communication-patterns)
- [Spawned stores](#spawned-stores)
- [Testing](#testing)
- [Feature isolation controlled through every layer](#feature-isolation-controlled-through-every-layer)
- [Migration path](#migration-path)

## The `@Feature` macro

The most visible change in 2.0, but also perhaps the most boring, is that we are moving away
from "reducer" terminology. While the roots of ComposableArchitecture were nourished by projects 
such as Redux and Elm, over time we have deviated so far from those ideas that it no longer feels
correct to channel their terminology.

In 2.0 we now offer the `@Feature` macro for defining features, and in the body of features we
provide `Update`:

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

It's a small change, but we hope it helps shed off any comparison to old libraries that aren't
relevant to the ComposableArchitecture anymore.

Also notice there's no return statements in `Update`. In ComposableArchitecture 2.0 the `Update` 
feature handles synchronous state mutations, and async work is handled through a completely new 
mechanism.

## Better bindings

In 1.x, two-way bindings between SwiftUI and your feature required conforming your action to
`BindableAction`, adding a `BindingReducer` to your body, and using a special `$store.scope`
syntax. In 2.0, bindings just work:

```swift
struct MyView: View {
  @Bindable var store: StoreOf<MyFeature>
  var body: some View {
    TextField("Name", text: $store.name)
    Toggle("Notifications", isOn: $store.isNotificationsEnabled)
  }
}
```

No protocol conformances, no extra reducers. Every writable property in your feature's state is
automatically bindable through `$store`.

## Feature stores

ComposableArchitecture 1.x required you to return `Effect` values from your reducer. In 2.0, every
feature implicitly has access to a `store` that can enqueue async work, and in that async work it
can further read and write state, and send actions. This opens up patterns that were previously 
impossible, and simplifies features by reducing the need to ping-pong actions back and forth.

To enqueue async work, use `store.addTask`:

```swift
case .startTimerButtonTapped:
  store.addTask {
    while true {
      try await Task.sleep(for: .seconds(1))
      try store.send(.timerTick)
    }
  }
```

It can be invoked as many times as you want and all tasks run concurrently.

But `store.addTask` is just the beginning. The `store` also gives you direct access to your
feature's state from inside async tasks, which was impossible in 1.x.

For example, suppose you have a timer counting down that you want to stop when it reaches 0. You
can now read that state directly in the task:

```swift
case .startCountdownButtonTapped:
  store.addTask {
    while try store.remainingSeconds > 0 {
      try await Task.sleep(for: .seconds(1))
      try store.send(.timerTick)
    }
  }
```

This is in stark contrast to 1.x which would have required us to send an action back into the
system to get access to the current feature state. We now get to implement the same logic with
fewer actions and less ping-ponging of logic.

You can also _write_ state from an async context using `store.modify`:

```swift
case .startCountdownButtonTapped:
  store.addTask {
    while try store.remainingSeconds > 0 {
      try await Task.sleep(for: .seconds(1))
      try store.modify { $0.remainingSeconds -= 1 }
    }
  }
```

Here we are decrementing `remainingSeconds` for each tick of the timer without sending an
intermediate `timerTick` action. This is all happening from within the async task. 

This may seem counter to ComposableArchitecture's core tenet that state only be modified in one 
place, but the isolation model makes it safe. All mutations made with `store.modify` are serialized 
on the store's actor, fully observable by SwiftUI, and fully visible to `TestStore`. Everything
is still 100% testable, whether you mutate state in `Update` or in a task.

The implicitly available store in each feature also gives us the ability to finally implement
`onChange` in a manner that aligns better with SwiftUI's `onChange`. You can now listen to _any_ 
state change in your feature, not just ones coming from sending actions:

```swift
.onChange(of: store.searchQuery) { oldValue, state in
  store.addTask {
    await analytics.track("Search query changed")
  }
}
```

This trailing closure will be invoked whenever `searchQuery` changes, no matter where it was
changed from, including parent features, effects, SwiftUI bindings, anywhere!

## Better encapsulation

2.0 makes it much easier to hide implementation details from parent features and views.

* **Private state is invisible to tests.** In 1.x, private properties in `State` were a pain because
`Equatable` conformance meant you still had to account for them in test assertions. In 2.0,
`TestStore` uses [DebugSnapshots](#debugsnapshots) under the hood, and `@DebugSnapshot` automatically
skips private properties. You can keep internal bookkeeping in private state without cluttering your
tests.

* **`@FeatureLocal` for truly local state.** Similar to SwiftUI's `@State`, `@FeatureLocal` gives
your feature state that is completely invisible to parent features:

  ```swift
  @Feature struct Editor {
    struct State { … }
    @FeatureLocal var isHighlighting = false
    var body: some Feature { … }
  }
  ```

  No parent can read or write `isHighlighting` as it's scoped entirely to the feature.

* **Private actions via events.** In 1.x, actions sent from effects (like `.factResponse`) had to be
  part of the public `Action` enum, which meant views could technically send them. In 2.0, you can
  model effect responses as private events instead:

  ```swift
  @Feature struct FactFeature {
    private enum Event: FeatureEventKey {
      typealias Value = String
    }
    var body: some Feature {
      Update { state, action in
        case .factButtonTapped:
          store.addTask {
            let fact = try await factClient.fetch(store.count)
            try store.post(key: Event.self, value: fact)
          }
      }
      .onEvent(Event.self) { fact, state in
        state.fact = fact
      }
    }
  }
  ```

  The event is private to the feature. Views can never trigger it, and the `Action` enum stays clean
  with only user-initiated actions.

## Lifecycle hooks

ComposableArchitecture 2.0 adds lifecycle hooks that replace many patterns that were awkward in 1.x.
Previously one would use `onAppear` actions to perform start-up work in features, but these are
no longer necessary. You can now use `onMount` to perform one-time work when your feature state
is first created:

```swift
Update { state, action in
  …
}
.onMount { state in
  store.addTask {
    try await analytics.track("Feature presented")
  }
}
```

Any async work enqueued when mounted will automatically be cancelled when the feature state is
torn down. You can think of this tool as being analogous to SwiftUI's `task` view modifier, except
it is called only when the feature is created, not every time the feature merely 
appears on the screen.

And like SwiftUI's `task` view modifier, there is also a variation of `onMount` that takes an `id`
argument that causes the trailing closure to be invoked again when the ID changes:

```swift
Update { state, action in
  …
}
.onMount(id: store.query) { state in
  store.addTask {
    try await searchClient.search(store.query)
  }
}
```

When the feature's `query` state changes any inflight async work will be cancelled and a new async
job will be enqueued and run.

And just as there is `onMount`, there is `onDismount`, which is called a single time when the 
feature is fully torn down:

```swift
Update { state, action in
  …
}
.onDismount { state in
  store.addTask {
    try await analytics.track("Feature dismissed")
  }
}
```

This fixes a long standing annoyance of 1.x in which it was not possible to send actions from
the `onDisappear` view modifier in SwiftUI views.

## Communication patterns

The library includes all new tools to allow disparate features to communicate with each other
and decouple unrelated features.

* **Preferences** let child features aggregate state upward through the feature tree, just like
preferences in SwiftUI. You define a preference key, publish values from children, and listen from 
an ancestor:

  ```swift
  private enum TotalBadgeCount: FeaturePreferenceKey {
    static let defaultValue = 0
    static func reduce(value: inout Value, nextValue: () -> Value) {
      value += nextValue()
    }
  }
  ```

  Any child feature can publish their badge count with 
  `.preference(key: TotalBadgeCount.self, value: store.badgeCount)`, and any parent listens with
  `.onPreferenceChange(TotalBadgeCount.self)`.

* **Events** let children notify ancestors of important occurrences. Unlike preferences, events are
one-shot notifications rather than continuous state:

  ```swift
  // 1. Declare the event
  private enum PresentSettings: FeatureEventKey {
  }

  // 2. Child posts an event:
  store.addTask {
    try store.post(key: PresentSettings.self)
  }

  // Any ancestor can listen for the event:
  .onEvent(PresentSettings.self) { _, state in
    state.isSettingsPresented = true
  }
  ```

  Events bubble upward through the feature tree and can optionally be consumed by intermediate
  features to stop propagation.

* **Triggers** let parents command children to perform an action:

  ```swift
  @Feature struct Child {
    struct State {
      @Trigger var refresh
    }
    var body: some Feature {
      Update { state, action in … }
      .onTrigger(store.refresh) { state in
        store.addTask { … }
      }
    }
  }

  // In parent:
  case .refreshAllButtonTapped:
    state.child.refresh()
  ```

  The parent mutates the child's trigger, and the child's `onTrigger` hook fires in response.
  This is a far more efficient way to achieve what one does today in 1.x, which is for the parent
  to explicitly send a child action.

* **Delegate closures** replace 1.x's delegate actions with a simpler pattern. The child holds
onto closures that represent events it wants to communicate to the parent:

  ```swift
  @Feature struct MessageComposer {
    let onSend: (String) throws -> Void
    var body: some Feature {
      Update { state, action in
        case .sendButtonTapped:
          store.addTask { [draft = state.draft] in
            try onSend(draft)
          }
          state.draft = ""
      }
    }
  }
  ```
  
  And the parent can provide closures when constructing the child feature, and can even modify
  feature state directly in those closures:

  ```swift
  // In parent:
  Scope(state: \.messageComposer, action: \.messageComposer) {
    MessageComposer { message in
      try store.modify {
        $0.messages.insert(message, at: 0)
      }
    }
  }
  ```

  No more delegate action enums or parent reducers switching on child actions.

## Spawned stores

While tightly integrating parent and child features together can be powerful, and is sometimes
necessary, not every child feature needs this. Sometimes the overhead of scoping from a parent
domain to a child domain is not worth the benefits. When a child feature operates
independently and doesn't need to send actions back through the parent, you can `spawn` it instead:

```swift
var body: some Feature {
  Update { state, action in
    …
  }
  .spawn(\.settings) { store in
    SettingsFeature()
  }
}
```

A spawned feature gets its own independent store backed by the parent's state at the given key path.
It processes its own actions without routing through the parent's `Update`, which means better
performance for features that don't need tight integration.

Best of all, all of the communication tools mentioned [above](#communication-patterns)
still work for spawned stores. Events bubble up from spawned stores to the root, preferences
aggregate, dependencies flow down, and even delegate closures work. You get the performance
benefits of independent stores without losing the communication tools that make the architecture
composable.

## Testing

Testing is by far the most important feature of the ComposableArchitecture, and you may be worried
that some of the amazing tools shown off above would hurt testability. Well, we are happy to report
that all features built using those tools are still 100% testable, and exhaustively testable.
The `TestStore` will still catch you every step of the way to make sure you assert on every piece
of state change, every effect, and every dependency.

And we made three big improvements to `TestStore`s in 2.0:

* Tests involving asynchrony are now less flaky and more deterministic thanks to our full control
of isolation throughout the entire stack. In most applications there will be no need to sprinkle
in sleeps and yields just to get tests passing.

* We integrated the `TestStore` with our new [DebugSnapshots](#debugsnapshots) library to allow
for testing without making the `State` of your features `Equatable`, and you can even store
reference types in `State` without hurting testability.

* The `TestStore` type remains `@MainActor` bound, as it is in 1.x, but we are introducing a new
`TestStoreActor` that provides the same testing experience, but runs on a non-global actor.
This means you can maximize parallelization of your tests since your features no longer need to run 
on the main thread.

## Feature isolation controlled through every layer

All of the features described above are only possible because isolation is controlled through every
layer of the stack. This requires use of nearly every advanced concurrency tool Swift offers, and,
surprisingly, shunning `Sendable` from nearly every type in the library.

`Store` is `@MainActor` by default, ensuring all state mutations and UI observations happen on the
main thread. When you call `store.addTask`, the task is automatically associated with the store's
actor, which allows one to synchronously read and write to the store from async contexts.

For features that don't need the main actor, `StoreActor` provides the same API on a custom actor,
enabling features to run _all_ of their logic and behavior off the main thread.

If you've been following our recent [collection on isolation](/collections/concurrency/isolation),
ComposableArchitecture 2.0 is the culmination of those ideas applied to a real framework. Every
layer, starting with the `Store` through to the `Feature`, `Update` and all the way to `addTask`,
has a clear isolation boundary, and the result is a system that is both safe and ergonomic.

<!--
## Migration path
TODO: Audit

We've put a lot of thought into making the transition to 2.0 as smooth as possible. The package
ships with three modules:

- **`ComposableArchitecture2`**: The new APIs described above.
- **`ComposableArchitecture1`**: A compatibility shim that provides the familiar 1.x API surface
  (`Reducer`, `Effect`, `Reduce`, etc.) built on top of the 2.0 runtime. Your existing code
  continues to compile. Everything is simply marked as deprecated with messages pointing you to
  the 2.0 equivalent.
- **`ComposableArchitecture`**: An umbrella module that re-exports `ComposableArchitecture1`. If
  you `import ComposableArchitecture` today, your code will keep working as-is.

This means you can adopt 2.0 incrementally: migrate one feature at a time by switching its import
from `ComposableArchitecture` to `ComposableArchitecture2`, and the rest of your app keeps running
on the compatibility shim.

And if you want a head start _before_ joining the beta, we recently
[wrote about](/blog/posts/203-hard-deprecations-and-soft-landings-with-swiftpm-traits) how you can
enable the `ComposableArchitecture2Deprecations` SwiftPM trait in version 1.25 today. This upgrades
soft deprecations to hard warnings, so you can work through the migration at your own pace with
compiler guidance.

-->

---

# How to get access

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

