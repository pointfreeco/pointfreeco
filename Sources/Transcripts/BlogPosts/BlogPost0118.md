To celebrate the release of Swift macros we are releasing updates to 4 of our popular libraries to 
greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
[SwiftUINavigation][sui-nav-gh], [ComposableArchitecture][tca-gh], and 
[XCTestDynamicOverlay][xctdo-gh]. Each day this week we will detail how macros have allowed us to 
massively simplify one of these libraries, and increase their powers.

And today we are discussing our popular library, the [Composable Architecture][tca-gh]. A brand new 
`@Reducer` macro has been introduced that can automate some of the aspects of building features
in the library, and greatly simplify the tools of the library. See the [1.4 migration 
guide][1.4-migration] article for more information about this release.

[1.4-migration]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/Migratingto14
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

It's a very tiny change, but it comes with a number of benefits:

### Simpler case paths for actions

The `@Reducer` macro automatically adds the `@CasePathable` macro to your feature's `Action` enum, 
which immediately gives you keypath-like syntax for referring to the cases of your enum. This means 
you can invoke the various reducer operators that require case paths for isolating a child feature's 
action with a simple key path:

```diff
 Reduce { state, action in 
   // …
 }
-.ifLet(\.child, action: /Action.child)
+.ifLet(\.child, action: \.child)
```

Every API in the library that takes a case path has been updated to be usable with this new syntax.

### Enum state

The `@Reducer` macro will also apply the `@CasePathable` macro to your feature's `State` type if it
is an enum, and further apply the `@dynamicMemberLookup` annotation. This allows you to greatly
simplify how you use the library's navigation view modifiers when dealing with an enum of 
destinations.

For example, previously the following was necessary to describing driving a sheet from a particular
case of an enum of destinations:

```swift
.sheet(
  store: self.store.scope(state: \.$destination, action: { .destination($0) }),
  state: /Feature.Destination.State.editForm,
  action: Feature.Destination.Action.editForm
)
```

It's quite verbose and unfortunately we cannot leverage type inference to omit the long type names.

But now that getters are derived for each case of the destination enum, we can simplify to just 
this:

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

### Simpler testing of effects

One of the super powers of the Composable Architecture is its ease of [testing][testing-article].
However, there is one aspect of testing that is quite verbose, and that is asserting when an effect
emits an action.

Currently when you assert that the store receives an action, you have to construct the exact, 
concrete action:

```swift
store.receive(.response(.success("Hello"))) {
  $0.message = "Hello"
}
```

If the store received a different action than the one specified it will fail the test suite. This
is very useful for proving you know exactly how your feature is behaving,

This does have a few drawbacks though. First of all, when testing deeply nested features, which is 
especially common with integration tests, you will need to construct a very verbose, deeply nested 
enum value:

```swift
store.receive(.destination(.presented(.child(.response.success("Hello"))))) {
  $0.message = "Hello"
}
```

Second, the `receive` method on `TestStore` does an equality check on the action received to make
sure you are exhaustively proving that you know which action is being sent into the system. However,
typically we don't need to assert on the data _inside_ the action because we already get a decent
amount of coverage on that in the trailing state assertion closure. It also forces the `Action` enum
in reducers to be `Equatable`, which can be annoying sometimes.

Well, now thanks to the `@Reducer` and `@CasePathable` macros we have a very short syntax for 
describing which enum case we expect the store to receive without specifying the data:

```swift
store.receive(\.response.success) {
  $0.message = "Hello"
}
```

And it works especially well when testing deeply nested features too:

```swift
store.receive(\.destination.presented.child.response.success) {
  $0.message = "Hello"
}
```

And this works even if none of your actions are `Equatable`. In fact, because of the simplicity of
this we have even decided to soft-deprecate [`TaskResult`][task-result-docs], which only exists to 
help make actions equatable. Refer to the [1.4 migration guide][1.4-migration] for more information.

### Basic feature linting

The macro is capable of detecting potential problems in your reducer and alerting you
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

…is considered programmer error. This is an invalid reducer because the `body` property will never 
be called. The `@Reducer` macro can diagnos the problem and provide you with a helpful warning:

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

## Get started today

Update your dependency on the Composable Architecture to [1.4][tca-1.4] today to start taking 
advantage of the new `@Reducer` macro, and more. Tomorrow we will discuss how these new case 
path tools have massively improved our [SwiftUINavigation][sui-nav-gh] library. 

[tca-1.4]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.4.0
[reducer-macro-docs]: todo
[reducer-protocol-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducer
[tree-nav-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/treebasednavigation
[stack-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/stackbasednavigation
[sui-nav-gh]: https://github.com/pointfreeco/swiftui-navigation 
[testing-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/testing
[1.4-migration]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/Migratingto14
[task-result-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/taskresult
