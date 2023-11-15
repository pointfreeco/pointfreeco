To celebrate the release of Swift macros we released updates to 4 of our popular libraries to 
greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
[ComposableArchitecture][tca-gh], [SwiftUINavigation][sui-nav-gh], and 
[Dependencies][dependencies-gh]. Each day this week we detailed how macros have allowed us to
massively simplify one of these libraries, and increase their powers.

Join us now for a recap of all the releases we had over the past week, and see just how powerful
Swift macros can be. 

* [@CasePathable](#CasePathable)
* [@Reducer](#Reducer)
* [Better SwiftUI navigation APIs](#Better-SwiftUI-navigation-APIs)
* [@DependencyClient](#DependencyClient)
* [Macro testing](#Macro-testing)

<div id="CasePathable"></div>

### @CasePathable

The first release of the week brought a massive update to our [CasePaths][case-paths-gh] library.
This library aims to bring many of the affordances of key paths to the cases of enums, but sadly
it never really live up to its potential. Until now, that is.

By using the new `@CasePathable` macro on enums you can obtain a key path for each case of the enum
that abstractly represents the two fundamental things one can do with an enum value: try to extract
a case's value out of the enum, or embed a case's value into the enum:

```swift
@CasePathable
enum Destination {
  case activity(ActivityModel)
  case settings(SettingsModel)
}

let activityPath = \Destination.Cases.activity  // CaseKeyPath<Destination, ActivityModel>
```

This unlocks a lot of interesting possibilities in API design, but the most immediate benefit to 
you is that you immediately get access to an `is` method for determining if an enum value matches
a particular case:

```swift
let destination = Destination.activity(…)

if destination.is(\.activity) {
  …
}
```

Further, if you apply the `@dynamicMemberLookup` attribute to your enum:

```swift
@CasePathable
enum Destination { 
  …
}
```

…then you get instant access to a computed property for each of your enum's cases:

```swift
let destination = Destination.activity(…)

destination.activity  // Optional(ActivityModel)
destination.settings  // nil
```

This gives you very easy access to the data in your enums, and you can even use key path syntax
when using standard library APIs, such as `compactMap`:

```swift
let destinations: [Destination] = […]

let activityModels = destinations.compactMap(\.activity)
```

<div id="Reducer"></div>

### @Reducer

The second release we had this week was [version 1.4][tca-1.4] of the 
[Composable Architecture][tca-gh]. This release introduced the `@Reducer` macro that automates a 
few things for you:

```swift
@Reducer 
struct Feature {
  …
} 
```

It automatically applies the `@CasePathable` macro to your `Action` enum inside (and even `State`
if it's an enum), and it lints for some simple gotchas that we can detect.

But most importantly, by using `@CasePathable` on the feature's enums we unlock simpler versions of
the APIs offered by the library. The various compositional operators, such as `Scope`, `ifLet`, 
`forEach`, etc. can now be written with simple key path syntax:  

```diff
 Reduce { state, action in 
   …
 }
-.ifLet(\.child, action: /Action.child) {
+.ifLet(\.child, action: \.child) {
   ChildFeature()
 }
```

The navigation view modifiers that the library provides can be massively simplified. You can now 
perform the full transformation of describing the optional `destination` state and case of the enum 
that powers navigation in a single line:

```diff
-.sheet(
-  store: self.store.scope(
-    state: \.$destination, 
-    action: { .destination($0) }
-  ),
-  state: /Feature.Destination.State.editForm,
-  action: Feature.Destination.Action.editForm
+.sheet(
+  store: self.store.scope(
+    state: \.$destination.editForm, 
+    action: \.destination.editForm
+  ) 
 ) { store in
   EditForm(store: store) 
 }
```

And key paths have also allowed us to simplify how one asserts against actions received by effects 
while testing. Currently you must specify the exact, concrete action that is received by the test
store, but now that can be shorted to the key path describing the case of the action enum:

```diff
-store.receive(.response(.success("Hello"))) {
+store.receive(\.response.success) {
   …
 }
```

This starts to really pay off when testing deeply nested actions, as is often the case with testing
the integration of many features together:

```diff
-store.receive(.destination(.presented(.child(.response.success("Hello"))))) {
+store.receive(\.destination.child.response.success) {
   $0.message = "Hello"
 }
```

<div id="Better-SwiftUI-navigation-APIs"><div>

### Better SwiftUI navigation APIs

The third release of the week updated our [SwiftUINavigation][sui-nav-gh] library to take advantage
of the `@CasePathable` macro. When that macro is applied to your enums describing all possible
navigation destinations for a feature:

```swift
@Observable
class FeatureModel {
  var destination: Destination?
  
  @CasePathable
  enum Destination {
    case activity(ActivityModel)
    case settings(SettingsModel)
  }
  
  …
}
```

…then you get instant access to a simpler way of driving navigation off of that state:

```diff
-.navigationDestination(
-  unwrapping: self.$model.destination,
-  case: /FeatureModel.Destination.activity
-) { model in
+.navigationDestination(item: self.$model.destination.activity) { model in
   ActivityView(model: model) 
 }
-.sheet(
-  unwrapping: self.$model.destination,
-  case: /FeatureModel.Destination.settings
-) { model in
+.sheet(item: self.$model.destination.settings) { model in
   SettingsView(model: model)
 }
```

There's no need to use a custom view modifier, and you get the benefits of Xcode autocomplete
and type inference.

<div id="DependencyClient"></div>

### @DependencyClient 

And finally we released an update to our [Dependencies][dependencies-gh] library that introduces
a new `@DependencyClient` macro. If you design your dependencies using a struct interface rather
than protocol, then you can apply this macro to your dependency like so:

```swift
@DependencyClient
struct AudioPlayerClient {
  var loop: (_ url: URL) async throws -> Void
  var play: (_ url: URL) async throws -> Void
  var setVolume: (_ volume: Float) async -> Void
  var stop: () async -> Void
}
```

This does a few things for you:

* It automatically generates a default implementation of the interface that simply throws an error 
and triggers an XCTest failure in each endpoint. You can create this instance by doing 
`AudioPlayerClient()`, and this is the best implementation to use for [`testValue`][test-value-docs]
when registering the dependency with the library.
* It defines methods with named arguments for each closure endpoint in the interface. This fixes
one of the biggest downsides to using structs to model dependencies:
  ```diff
  -audioPlayer.play(URL(string: …))
  +audioPlayer.play(url: URL(string: …))
  ```
* It generates a public initializer for the client type that specifies every property in the type.
That means you do not need to provide this initializer yourself if you 
[separate the interface][separating-interface] of your dependency from its implmenetation in 
separate modules, as is recommended for dependencies that take a long time to compile.

<div id="Macro-testing"></div>

### Macro testing

We did not release any updates to our [Macro Testing][macro-testing-gh] this week, but we did want
to give it a special shoutout for making it possible to test each of the macros released this week.
Our [`assertMacro`][assert-macro-docs] tool was immensely helpful in testing all of the tiny edge
cases of our macros, of which there were many.

Shortly after releasing `@CasePathable` it was brought to our attention that we were not handling
cases with multiple wildcard argument labels, for example:

```swift
case action(_ id: Int, _ message: String)
```

Luckily [the fix][case-paths-pr] was straightforward, and in order to test the fix all one has to
do is invoke `assertMacro` with the string of code that you want to be expanded: 

```swift
func testWildcard() {
  assertMacro {
    """
    @CasePathable enum Foo {
      case bar(_ int: Int, _ bool: Bool)
    }
    """
  }
}
``` 

Then run the test, and the expanded macro code will be generated and inserted [directly into the 
test file][case-paths-pr-test]. This makes it incredible easy to write as many tests as it takes
to get confidence that you have covered all of your bases.

And we wrote _a lot_ of tests. For example, our [Dependencies][dependencies-gh] library has 40 tests
for its macros, exercising every little edge case we could think of:

* What happens when your client has a mixture of [`public` and `private`][public-private-test] 
endpoints?
* What happens when your client has [computed properties][computed-prop-test]?
* What happens with [`@Sendable` and `@MainActor`][main-actor-test] attributes applied to closures?
* [And _a lot_ more…][dep-macros-tests]

We are even able to write simple tests that assert our macro's _diagnostics_ behave how we expect.
For example, the `@Reducer` macro performs a [light touch of linting][reducer-diagnostic] on your 
reducer in order to make sure you don't accidentally implement the `reduce(into:action:)` 
requirement _and_ `body` requirement at the same time. Doing so is invalid, but the Swift compiler 
can't help you, whereas our macro can.

And if all of that wasn't good enough, if we ever make a fundamental change to our macro and want 
to re-record _all_ macro expansions at once, that is as easy as a 
[single line change][deps-invoke-test]:

```swift
override func invokeTest() {
  withMacroTesting(
    isRecording: true,
    macros: [DependencyClientMacro.self]
  ) {
    super.invokeTest()
  }
}
``` 

By putting the test suite in "record mode", the Macro Testing library will automatically write the
freshest macro expansion into the test files. 

### Get started today!

That concludes this week's Macro Bonanza! Make sure you update all of your dependencies on our
libraries to take advantage of these new tools, and let us know what you think! 

[assert-macro-docs]: https://swiftpackageindex.com/pointfreeco/swift-macro-testing/main/documentation/macrotesting/assertmacro(_:record:of:diagnostics:fixes:expansion:file:function:line:column:)-6hxgm
[separating-interface]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/livepreviewtest#Separating-interface-and-implementation
[test-value-docs]: https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/livepreviewtest#Test-value
[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[tca-1.4]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.4.0
[sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies
[macro-testing-gh]: http://github.com/pointfreeco/swift-macro-testing
[reducer-diagnostic]: https://github.com/pointfreeco/swift-composable-architecture/blob/6bb85c8736cc58b41de35e6ef974563ccae77d6b/Tests/ComposableArchitectureMacrosTests/ReducerMacroTests.swift#L151-L155
[deps-invoke-test]: https://github.com/pointfreeco/swift-dependencies/blob/1b0c4b535d729f76ca6177f0ff1101ddfb0c8eaf/Tests/DependenciesMacrosPluginTests/DependencyClientMacroTests.swift#L6-L13
[dep-macros-tests]: https://github.com/pointfreeco/swift-dependencies/tree/1b0c4b535d729f76ca6177f0ff1101ddfb0c8eaf/Tests/DependenciesMacrosPluginTests
[computed-prop-test]: https://github.com/pointfreeco/swift-dependencies/blob/1b0c4b535d729f76ca6177f0ff1101ddfb0c8eaf/Tests/DependenciesMacrosPluginTests/DependencyClientMacroTests.swift#L393-L426
[public-private-test]: https://github.com/pointfreeco/swift-dependencies/blob/1b0c4b535d729f76ca6177f0ff1101ddfb0c8eaf/Tests/DependenciesMacrosPluginTests/DependencyClientMacroTests.swift#L274-L301
[sendable-test]: https://github.com/pointfreeco/swift-dependencies/blob/1b0c4b535d729f76ca6177f0ff1101ddfb0c8eaf/Tests/DependenciesMacrosPluginTests/DependencyClientMacroTests.swift#L332-L357
[main-actor-test]: https://github.com/pointfreeco/swift-dependencies/blob/1b0c4b535d729f76ca6177f0ff1101ddfb0c8eaf/Tests/DependenciesMacrosPluginTests/DependencyEndpointMacroTests.swift#L413-L448
[case-paths-pr]: https://github.com/pointfreeco/swift-case-paths/pull/130/
[case-paths-pr-test]: https://github.com/pointfreeco/swift-case-paths/pull/130/files#diff-54daa5f733b1f7882b9a27f25434806dd990deaaa7305470016c7c9c9556ca3bR307
[deps-pr-test]: https://github.com/pointfreeco/swift-dependencies/blob/1b0c4b535d729f76ca6177f0ff1101ddfb0c8eaf/Tests/DependenciesMacrosPluginTests/DependencyClientMacroTests.swift#L501-L507
