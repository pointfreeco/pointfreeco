!> [warning]: There are some [episode spoilers](/collections/composable-architecture/sharing-and-persisting-state) contained in this announcement!

Today we are excited to announce a [new beta][shared-state-beta] for the Composable Architecture.
Past betas have included the [concurrency beta][concurrency-beta], the 
[`Reducer` protocol beta][protocol-beta], and most recently the 
[observation beta][observation-beta]. And we think this one may be more exciting than all of those!

This beta focuses on providing the tools necessary for sharing state throughout your app. We
also went above and beyond by providing tools for persisting state to user defaults and the file
system, as well as providing a way create your own persistence strategies.

Join us for a quick overview of the tools, and be sure to [check out the beta][shared-state-beta]
today!

[shared-state-beta]: https://github.com/pointfreeco/swift-composable-architecture/discussions/2857
[concurrency-beta]: https://github.com/pointfreeco/swift-composable-architecture/discussions/1186
[protocol-beta]: https://github.com/pointfreeco/swift-composable-architecture/discussions/1282
[observation-beta]: https://github.com/pointfreeco/swift-composable-architecture/discussions/2594

## The @Shared property wrapper

The primary tool provided in this beta is the [`@Shared`][shared-pw-docs] property wrapper. It
represents a piece of state that will be shared with another part of the application, or potentially
with the _entire_ application. It can be used with any data type, and it cannot be set to a default
value.

[shared-pw-docs]: https://github.com/pointfreeco/swift-composable-architecture/blob/9e03cb40f3097290f85c3663109a468a513a7ba6/Sources/ComposableArchitecture/SharedState/Shared.swift#L13

For example, suppose you have a feature that holds a count and you want to be able to hand a shared
reference to that count to other features. You can do so by holding onto a `@Shared` property in the
feature's state:

```swift
@Reducer
struct ParentFeature {
  @ObservableState
  struct State {
    @Shared var count: Int
    // Other properties
  }
  // ...
}
```

!> [note]: It is not possible to provide a default to a `@Shared` value. It must be passed to this feature's state from a parent feature.

Then suppose that this feature can present a child feature that wants access to this shared `count`
value. The child feature would also would hold onto an `@Shared` property to a count:

```swift
@Reducer
struct ChildFeature {
  @ObservableState
  struct State {
    @Shared var count: Int
    // Other properties
  }
  // ...
}
```

When the parent features creates the child feature's state, it can pass a _reference_ to the shared
count rather than the actual count value by using the `$count` projected value:

```swift
case .presentButtonTapped:
  state.child = ChildFeature.State(count: state.$count)
  // ...
```

Now any mutation the `ChildFeature` makes to its `count` will be instantly made to the 
`ParentFeature`'s count too, and vice-versa.

The `Shared` type works by holding onto a reference type so that multiple parts of the application
can see the same state and can each make mutations with it. Historically, reference types in state
were problematic for two main reasons:

* Reference types do not play nicely with SwiftUI view invalidation. It was possible for the data
inside a reference to change without notifying the view that it changed, cause the view to show
out-of-date information.
* Reference types do not play nicely with testing. Classes do not easily conform to `Equatable`,
and even when they do you cannot compare them before and after a mutation is made in order to
exhaustively prove how it changes.

However, there are now solutions to both of these problems:

* Thanks to Swift's new observation tools (and our [backport][perception-blog] of those tools),
reference types can now properly communicate to views when they change so that the view can
invalidate and re-render.
* And thanks to the `@Shared` property wrapper, we are able to make shared test 100% testable, even
_exhaustively_! When using the `TestStore` to test your features you will be forced to assert on
how all state changes in your feature, even state held in `@Shared`.

[perception-blog]: https://www.pointfree.co/blog/posts/129-perception-a-back-port-of-observable

## Persistence

The `@Shared` property wrapper can also be used in conjunction with a persistence strategy that
makes the state available globally throughout the entire application, _and_ persists the data
to some external system so that it can be made available across application launches.

For example, to save the `count` described above in user defaults so that any changes are 
automatically persisted and made available next time the app launches, simply use the `.appStorage`
persistence strategy with `@Shared`:

```diff
 @Reducer
 struct ParentFeature {
   @ObservableState
   struct State {
-    @Shared var count: Int
+    @Shared(.appStorage("count")) var count = 0
     // Other properties
   }
   // ...
 }
```

!> [note]: You must provide a default value when using a persistence stategy. It is only used upon first access of the state and when there is no previously saved state (for example, the first launch of the app).

That's all it takes. Now any part of the application can instantly access this state by using
the same `@Shared` configuration, and it does not even need to be explicitly passed in from the 
parent feature. Any changes made to this state will be immediately persisted to user defaults, and
further if something writes to the "count" key in user defaults directly without going through
`@Shared`, the state in your feature will be immediately updated too.

The `.appStorage` persistence strategy is limited by the kinds of data you can store in it since
user defaults has those limitations. It's mostly appropriate for very simple data, such as strings,
integers, booleans, etc.

There is also a `.fileStorage` strategy you can use to persist data. It requires that your state
is `Codable`, and it's more appropriate for complex data types rather than simpler values. We use
this kind of persistence in our [SyncUps][syncups-file-storage] demo application for persisting 
the list of sync up meetings to disk: 

```swift
@ObservableState
struct State: Equatable {
  @Presents var destination: Destination.State?
  @Shared(.fileStorage(.syncUps)) var syncUps: IdentifiedArrayOf<SyncUp> = []
}
```

[syncups-file-storage]: https://github.com/pointfreeco/swift-composable-architecture/blob/7bd346042b3168894b538f49803d25497885c81c/Examples/SyncUps/SyncUps/SyncUpsList.swift#L18

This persistence strategy behaves like `.appStorage` in many ways. Using it makes the state 
globally available to all parts of the application, and any change to the state will be persisted
to disk. Further, if the data on disk is changed outside of `@Shared`, that change will be 
immediately played back to any feature holding onto `@Shared`.

There is a third form of persistence that comes with the library called `.inMemory`. It has no
restrictions on the kind of value you can hold in it, but that's only because it doesn't actually
persist the data anywhere. It just makes the data globally available in your application, and it
will be cleared out between app launches. It is similar to the ["in-memory"][swiftdata-inmemory]
persistence storage from SwiftData.

[swiftdata-inmemory]: https://developer.apple.com/documentation/swiftdata/modelconfiguration/init(isstoredinmemoryonly:)

It is even possible for you to create your own persistence strategies! You can simply conform a new
type to the [`PersistentKey`][persistentkey-docs] protocol, implement a few requirements, and then
it will be available to use with `@Shared`.

[persistentkey-docs]

## Testing

Shared state behaves quite a bit different from the regular state held in Composable Architecture
features. It is capable of being changed by any part of the application, not just when an action is
sent to the store, and it has reference semantics rather than value semantics. Typically references
cause series problems with testing, especially exhaustive testing that the library prefers (see
[Testing][testing-docs]), because references cannot be copied and so one cannot inspect the changes 
before and after an action is sent.

[testing-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing

For this reason, the `@Shared` property wrapper does extra working during testing to preserve a 
previous snapshot of the state so that one can still exhaustive assert on shared state, even though 
it is a reference.

For the most part, shared state can be tested just like any regular state held in your features. For
example, consider the following simple counter feature that uses in-memory shared state for the
count:

```swift
@Reducer 
struct Feature {
  struct State: Equatable {
    @Shared var count: Int
  }
  enum Action {
    case incrementButtonTapped
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .incrementButtonTapped:
        state.count += 1
        return .none
      }
    }
  }
}
```

This feature can be tested in exactly the same way as when you are using non-shared state:

```swift
func testIncrement() async {
  let store = TestStore(initialState: Feature.State(count: Shared(0))) {
    Feature()
  }

  await store.send(.incrementButtonTapped) {
    $0.count = 1
  }
}
```

This test passes because we have described how the state changes. But even better, if we mutate the
`count` incorrectly:


```swift
func testIncrement() async {
  let store = TestStore(initialState: Feature.State(count: Shared(0))) {
    Feature()
  }

  await store.send(.incrementButtonTapped) {
    $0.count = 2
  }
}
```

…we immediately get a test failure letting us know exactly what went wrong:

```
❌ State was not expected to change, but a change occurred: …

    − Feature.State(_count: 2)
    + Feature.State(_count: 1)

(Expected: −, Actual: +)
```

This works even though the `@Shared` count is a reference type. The ``TestStore`` and ``Shared``
type work in unison to snapshot the state before and after the action is sent, allowing us to still
assert in an exhaustive manner.

However, exhaustively testing shared state is more complicated than testing non-shared state in
features. Shared state can be captured in effects and mutated directly, without ever sending an
action into system. This is in stark contrast to regular state, which can only ever be mutated when
sending an action.

For example, it is possible to alter the `incrementButtonTapped` action so that it captures the 
shared state in an effect, and then increments from the effect:

```swift
case .incrementButtonTapped:
  return .run { [count = state.$count] _ in
    count.wrappedValue += 1
  }
```

The only reason this is possible is because `@Shared` state is reference-like, and hence can 
technically be mutated from anywhere.

However, how does this affect testing? Since the `count` is no longer incremented directly in
the reducer we can drop the trailing closure from the test store assertion:

```swift
func testIncrement() async {
  let store = TestStore(initialState: SimpleFeature.State(count: Shared(0))) {
    SimpleFeature()
  }
  await store.send(.incrementButtonTapped)
}
```

This is technically correct, but we aren't testing the behavior of the effect at all.

Luckily the ``TestStore`` has our back. If you run this test you will immediately get a failure
letting you know that the shared count was mutated but we did not assert on the changes:

```
❌ Tracked changes to 'Shared<Int>@MyAppTests/FeatureTests.swift:10' but failed to assert: …

  − 0
  + 1

(Before: −, After: +)

Call 'Shared<Int>.assert' to exhaustively test these changes, or call 'skipChanges' to ignore them.
```

In order to get this test passing we have to explicitly assert on the shared counter state at
the end of the test, which we can do using the ``Shared/assert(_:file:line:)`` method:

```swift
func testIncrement() async {
  let store = TestStore(initialState: SimpleFeature.State(count: Shared(0))) {
    SimpleFeature()
  }
  await store.send(.incrementButtonTapped)
  store.state.$count.assert {
    $0 = 1
  }
}
```

Now the test passes.

So, even though the `@Shared` type opens our application up to a little bit more uncertainty due
to its reference semantics, it is still possible to get exhaustive test coverage on its changes.

## Get started today!

We are very excited about these new shared state tools in the Composable Architecture, and we would
love to get your feedback on it. Please consider pointing your project to the `shared-state-beta`
branch and letting us know if anything goes wrong. Also be sure to read the 
[Sharing State][sharingstate-article] article and [1.9 migration guide][migration-1.9] for
more information on the tools.

[sharingstate-article]: https://github.com/pointfreeco/swift-composable-architecture/blob/shared-state-beta/Sources/ComposableArchitecture/Documentation.docc/Articles/SharingState.md
[migration-1.9]: https://github.com/pointfreeco/swift-composable-architecture/blob/shared-state-beta/Sources/ComposableArchitecture/Documentation.docc/Articles/MigrationGuides/MigratingTo1.9.md
