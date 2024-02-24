!> [warning]: There are some [episode spoilers]() contained in this announcement!

Today we are excited to announce a [new beta][shared-state-beta] for the Composable Architecture.
Past betas have included the [concurrency beta][concurrency-beta], the 
[`Reducer` protocol beta][protocol-beta], and most recently the 
[observation beta][observation-beta]. And we think this one may be more exciting than all of those!

The beta focuses on providing the tools necessary for sharing state through your applications. We
also went above and beyond by providing tools for persisting state to user defaults and the file
system, as well as provide a way for users of the library to create their own persistence 
strategies.

Join us for a quick overview of the tools, and be sure to [check out the beta][shared-state-beta]
today!

[shared-state-beta]: todo
[concurrency-beta]: https://github.com/pointfreeco/swift-composable-architecture/discussions/1186
[protocol-beta]: https://github.com/pointfreeco/swift-composable-architecture/discussions/1282
[observation-beta]: https://github.com/pointfreeco/swift-composable-architecture/discussions/2594

## The @Shared property wrapper

The primary tool provided in this beta is the [`@Shared`][shared-pw-docs] property wrapper. It
represents a piece of state that will be shared with another part of the application, or potentially
with the _entire_ application. It can be used with any data type, and it cannot be set to a default
value.

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


