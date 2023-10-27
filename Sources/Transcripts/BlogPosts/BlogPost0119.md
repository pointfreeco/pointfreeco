To celebrate the release of Swift macros we releasing updates to 4 of our popular libraries to 
greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
[SwiftUINavigation][sui-nav-gh], [ComposableArchitecture][tca-gh], and 
[XCTestDynamicOverlay][xctdo-gh]. Each day this week we will detail how macros have allowed us to 
massively simplify one of these libraries, and increase their powers.

And today we are discussing our popular library, the [Composable Architecture][tca-gh]. A brand new 
`@Reducer` macro has been introduced that can automate some of the aspects of building features
in the library.

[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[xctdo-gh]: http://github.com/pointfreeco/xctest-dynamic-overlay

## @Reducer

The new [`@Reducer`][reducer-macro-docs] macro can now be used instead of directly conforming to
the [`Reducer`][reducer-protocol-docs] protocol:

```diff
-struct Feature: Reducer {
+@Reducer
+struct Feature {
   // …
 }
```

It's a very tiny change, but it comes with a number of benefits.

It will automatically add the `@CasePathable` macro to your `Action` enum, which immediately gives
you keypath-like syntax for referring to the cases of your enum. This means you can invoke the 
various reducer operators that require case paths for isolating a child feature's action with
a simple key path:

```diff
 Reduce { state, action in 
   // …
 }
-.ifLet(\.child, action: /Action.child)
+.ifLet(\.child, action: \.child)
```

Further, the macro is capable of detecting potential problems in your reducer and alerting you
at compile time rather than runtime. For example, implementing your reducer by accidentally
specifing the `reduce(into:action:)` method _and_ the `body` property like so: 

```swift
@Reducer
struct Feature {
  struct State {
  }
  enum Action {
  }
  func reduce(into state: inout State, action: Action) -> EffectOf<Self> {
    …
  }
  var body: some ReducerOf<Self> {
    …
  }
}
```

This is an invalid reducer because the `body` property will never be called. The `@Reducer` macro
can diagnos the problem and provide you with a helpful warning:

```swift
@Reducer
struct Feature {
  struct State {
  }
  enum Action {
  }
  func reduce(into state: inout State, action: Action) -> EffectOf<Self> {
    // ┬─────
    // ╰─ ⚠️ A 'reduce' method should not be defined in a reducer with a 
    //       'body'; it takes precedence and 'body' will never be invoked.
    …
  }
  var body: some ReducerOf<Self> {
    …
  }
}
```

The `@Reducer` macro will also apply the `@CasePathable` macro to your feature's `State` type if it
is an enum, and further apply the `@dynamicMemberLookup` annotation. Doing so allows you to
simplify your use of our navigation view modifiers from something like this:

```swift
.sheet(
  store: self.store.scope(state: \.$destination, action: { .destination($0) }),
  state: /Feature.Destination.State.editForm,
  action: Feature.Destination.Action.editForm
)
```

…to something like this:

```swift
.sheet(
  store: self.store.scope(state: \.$destination, action: { .destination($0) }),
  state: \.editForm,
  action: { .editForm($0) }
)
```

And in the future the `@Reducer` macro may acquire even more powers for helping you avoid the 
boilerplate of implementing `Destination` features for [tree-based navigation][tree-nav-docs] and 
`Path` features for [stack-based navigation][stack-docs]. 

## Get started today

Update your dependency on the Composable Architecture to [1.4][tca-1.4] today to start taking 
advantage of the new `@Reducer` macro, and more. Tomorrow we will discuss how these new case 
path tools have massively improved our [XCTestDynamicOverlay][xctdo-gh] library. 

[tca-1.4]: todo
[reducer-macro-docs]: todo
[reducer-protocol-docs]: todo
[tree-nav-docs]: todo
[stack-docs]: todo
[xctdo-gh]: todo
