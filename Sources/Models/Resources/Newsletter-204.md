We are excited to announce a new feature of Point-Free: [Beta Previews]. It's
a great way for our most dedicated subscribers to help shape the future of our libraries and the
greater Point-Free ecosystem. And we are launching today with two betas already: a brand new 
library for exhaustively testing reference types, and a preview of ComposableArchitecture 2.0.

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

## ComposableArchitecture 2.0

The second beta is the one many of you have been waiting for: **ComposableArchitecture 2.0**. This
is our biggest release ever, and is a fundamental redesign of how features are built, how side
effects are managed, and how composition works. The result is dramatically less boilerplate, a more
intuitive mental model, and testing that is more powerful than ever.

### The `@Feature` macro

The most visible change in 2.0, but also perhaps the most boring, is that we are moving away
from "reducer" terminology. While the roots of ComposableArchitecture were nurished by projects 
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

### Side effects with `store`

ComposableArchitecture 1.x required you to return `Effect` values from your reducer. In 2.0, every
feature implicitly has access to a `Store`-like object that can be used to enqueue async work:

```swift
case .startTimerButtonTapped:
  store.addTask {
    while true {
      try await Task.sleep(for: .seconds(1))
      try store.send(.timerTick)
    }
  }
```

The `store` variable is always available in the body of your features and `store.addTask` schedules
async work to be performed. It can be invoked as many times as you want and all tasks run 
concurrently.

This implicitly available store has other super powers too…

### Feature stores 

The store available to all features can be used to read and write state in your feature, send 
actions, and as mentioned above, enqueue async work. This opens up all new patterns that were 
previously impossible, and simplifies features by reducing the need to ping-pong many actions back 
and forth.

CLAUDE-DO: show example of reading state from store task
CLAUDE-DO: show example of writing state from store task
CLAUDE-DO: show example of `onChange`

### Lifecycle hooks

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
torn down. You can think of this tool as being analagous to SwiftUI's `task` view modifier, except
it is called only when the feature is created and destroyed, not everytime the feature merely 
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

### Communication patterns

The library includes all new tools to allow disparate features to communicate with each other
and decouple unrelated features.

CLAUDE-DO: explore the case studies in the TCA26 repo to implement these TODOs
CLAUDE-DO: describe preferences as a child-to-ancestor communication tool driven by state
CLAUDE-DO: describe events as a child-to-ancestor communication tool driven by notifications
CLAUDE-DO: describe triggers as a parent-to-child communication tool
CLAUDE-DO: describe delegate closures as a direct child-to-parent communication tool that replaces the need for delegate actions

### Testing

Testing is by far the most important feature of the ComposableArchitecture, and you may be worried
that some of the amazing tools shown off above would hurt testability. Well, we are happy to report
that all features built using those tools are still 100% testable, and exhaustively testable.
The `TestStore` will still catch you every step of the way to make sure you assert on every piece
of state change, every effect, and every dependency.

And we made three big improvements to `TestStore`s in 2.0:

* Tests involving asynchrony are now less flakey and more deterministic thanks to our full control
of isolation throughout the entire stack. In more applications there will be no need to splinkle
in sleeps and yields just to get tests passing.

* We integrated the `TestStore` with our new [DebugSnapshots](#debugsnapshots) library to allow
for testing without making the `State` of your features `Equatable`, and you can even store 
reference types in `State` without hurting testability.

* The `TestStore` type remains `@MainActor` bound, as it is in 1.x, but we are introducing a new
`TestStoreActor` that provides the same testing experience, but runs on a non-global actors.
This means you can maximize parallelization of your tests since all features will not be running
on the main thread.

### Feature isolation controlled through every layer

CLAUDE-DO: discuss how isolation is controlled through every layer of a feature (`Store`, `Feature`, `Update` and `addTask { … }`), which is how we are able to accomplish everything above. and dovetail this with our current collection of episodes discussing isolation from first principles


### Migration path

<!--
TODO: Audit

We've put a lot of thought into making the transition to 2.0 as smooth as possible. The package
ships with three modules:

- **`ComposableArchitecture2`**: The new APIs described above.
- **`ComposableArchitecture1`**: A compatibility shim that provides the familiar 1.x API surface
  (`Reducer`, `Effect`, `Reduce`, etc.) built on top of the 2.0 runtime. Your existing code
  continues to compile — everything is simply marked as deprecated with messages pointing you to
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
