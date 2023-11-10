To celebrate the release of Swift macros we are releasing updates to 4 of our popular libraries to 
greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
[SwiftUINavigation][sui-nav-gh], [ComposableArchitecture][tca-gh], and 
[XCTestDynamicOverlay][xctdo-gh]. Each day this week we will detail how macros have allowed us to 
massively simplify one of these libraries, and increase their powers.

[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[xctdo-gh]: http://github.com/pointfreeco/xctest-dynamic-overlay

<!--
!> [preamble]: To celebrate the release of Swift macros we releasing updates to 4 of our popular 
> libraries to greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
> [SwiftUINavigation][sui-nav-gh], [ComposableArchitecture][tca-gh], and 
> [XCTestDynamicOverlay][xctdo-gh]. Each day this week we will detail how macros have allowed us to 
> massively simplify one of these libraries, and increase their powers.
> * **Macro Bonanza: CasePaths**
> * Macro Bonanza: SwiftUINavigation
> * Macro Bonanza: Composable Architecture
> * Macro Bonanza: XCTestDynamicOverlay
> 
> [case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
> [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
> [sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
> [xctdo-gh]: http://github.com/pointfreeco/xctest-dynamic-overlay
-->

And today we are starting with [CasePaths][case-paths-gh]. When we first saw macros we knew they
had the ability to completely transform our case paths library, and we feel we have settled on a 
design that brings many of the powers of key paths to enums.

## `@CasePathable`

The only macro added to the CasePaths library is `@CasePathable`, and it can be applied to any
enum:

```swift
@CasePathable
enum Destination {
  case activity(ActivityModel)
  case settings(SettingsModel)
}
```

That immediately gives you access to what is known as a `CaseKeyPath` for each case of the enum,
_and_ you can even use key path syntax to construct them:

```swift
let activityCase = \Destination.Cases.activity  // CaseKeyPath<Destination, ActivityModel>
```

Previously, case paths were constructed by using a custom prefix operator, `/`, which meant there 
was no type inference or autocomplete help from the compiler:

```swift
let activityCase = /Destination.activity  // CasePath<Destination, ActivityModel>
```

Now, case paths by themselves are not very useful, just as key paths by themselves are not very 
useful. Their use is only in generic algorithms that allow you to abstract over the shape of your
enums.

This concept is used heavily in our [Composable Architecture][tca-gh] library, where one often
uses case paths on action enums in order to isolate a child domain. For example, enchancing a parent
feature with the functionality of an optional feature can be done with the `ifLet` reducer operator,
but we can now use familiar key path syntax to do this:

```diff
 Reduce { state, action in 
   // …
 }
-.ifLet(\.child, action: /Action.child)
+.ifLet(\.child, action: \.child)
```

This greatly simplifies nearly every reducer operator in the Composable Architecture, but it can
also be used to simplify other libraries using case paths such as our [SwiftUI 
Navigation][sui-nav-gh] library. But we will discuss that more later this week.

## Expressive case checking

But even if you are not using a library out there that uses case paths, you may still have 
use of case paths directly in your application. It makes it possible to easily check if an enum
value is of a particular case, and you can immediately access getter properties for each case of 
your enum.

For example, for the `Destination` enum above you get immediate access to an `is` method defined
on any `CasePathable` conforming type that allows you to quickly check the case of an enum value
as an expression: 

```swift
let destination: Destination = …

if destination.is(\.activity) {
  // …
}
```

Typically this must be done as a statement, such as with an `if case let` or `guard case let`.

## Case getters

Further, if you mark the `Destination` enum from above with both the `@CasePathable` macro
_and_ `@dynamicMemberLookup`:

```swift
@CasePathable
@dynamicMemberLookup
enum Destination {
  case activity(ActivityModel)
  case settings(SettingsModel)
}
```

…then you can use the name of each case as a property on the destination to attempt to extract
that data from the enum:

```swift
let destination = Destination.activity(ActivityModel())
destination.activity  // ActivityModel
destination.settings  // nil
``` 

Or if you have a _collection_ of enum values, you can use `compactMap` with the property to extract
out all of the values matching a particular case:

```swift
let destinations: [Destination] = […]
let activityModels = destinations.compactMap(\.activity)
```

All of this comes for free with CasePaths, but you do have to opt into the functionality by applying
`@dynamicMemberLookup` to your enum. If you only need the case paths for your enum and don't want
to clutter your type with unneeded properties, then you can use `@CasePathable` by itself.

This tool also helps simplify a common pattern in Composable Architecture applications. It is 
common to represents the places a features can navigate to via a `Destination` reducer that has a 
case for each destination. This is a style we like to call [tree-based navigation][tree-nav-docs].

[tree-nav-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/treebasednavigation

However, the downside to this style of navigation is that the view modifier for specifying that 
navigation is driven from a particular case of a destination enum can be quite verbose:

```swift
.sheet(
  store: self.store.scope(state: \.$destination, action: { .destination($0) }),
  state: /Feature.Destination.State.editForm,
  action: Feature.Destination.Action.editForm
)
```

With the new properties added to an enum this can be shorted to just the following:

```diff
 .sheet(
   store: self.store.scope(state: \.$destination, action: { .destination($0) }),
-  state: /Feature.Destination.State.editForm,
-  action: Feature.Destination.Action.editForm
+  state: \.editForm,
+  action: { .editForm($0) }
 )
```

## Get started today

Update your dependency on CasePaths to [1.1][case-paths-1.1] today to start taking advantage of
the new `@CasePathable` macro, and more. Tomorrow we will discuss how these new case path tools have
massively improved our [Composable Architecture][tca-gh] library. 

[case-paths-1.1]: https://github.com/pointfreeco/swift-case-paths/releases/tag/1.1.0
