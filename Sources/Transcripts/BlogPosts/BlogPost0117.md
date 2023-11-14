!> [preamble]: To celebrate the release of Swift macros we releasing updates to 4 of our popular 
> libraries to greatly simplify and enhance their abilities: [CasePaths][case-paths-gh], 
> [ComposableArchitecture][tca-gh], [SwiftUINavigation][sui-nav-gh], and 
> [Dependencies][dependencies-gh]. Each day this week we will detail how macros have allowed us to 
> massively simplify one of these libraries, and increase their powers.
> * [**Macro Bonanza: CasePaths**](/blog/posts/117-macro-bonanza-case-paths)
> * [Macro Bonanza: Composable Architecture](/blog/posts/118-macro-bonanza-composable-architecture)
> * [Macro Bonanza: SwiftUINavigation](/blog/posts/119-macro-bonanza-swiftui-navigation)
> * _Macro Bonanza: Dependencies (tomorrow!)_
> 
> [case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
> [tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
> [sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
> [dependencies-gh]: http://github.com/pointfreeco/swift-dependencies

When we first saw macros we knew they had the ability to completely transform our 
[CasePaths][case-paths-gh] library, which currently heavily depends on runtime reflection to work. 
We feel we have settled on a design that brings many of the powers of key paths to enums. Join
us for a quick overview, and be sure to check out version [1.1 of CasePaths][case-paths-1.1] today!

[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[case-paths-1.1]: https://github.com/pointfreeco/swift-case-paths/releases/tag/1.1.0

## `@CasePathable`

The only macro added to the CasePaths library is [`@CasePathable`][casepathable-docs], and it can 
be applied to any enum:

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
uses case paths on action enums in order to isolate a child domain. For example, the 
[`Scope`][scope-docs] reducer is the fundamental unit for composing a child reducer into a parent.
We can now use a more familiar syntax to do this composition:

[scope-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/scope

```diff
 var body: some ReducerOf<Self> {
-  Scope(state: \.child, action: /Action.child) {
+  Scope(state: \.child, action: \.child) {
     ChildFeature()
   }
 }
```

Similarly, when enhancing a parent feature with the functionality of an optional feature one turns
to the [`ifLet`][iflet-docs] reducer operator, and we can again use familiar key path syntax to do 
this:

[iflet-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducer/iflet(_:action:destination:fileid:line:)

```diff
 Reduce { state, action in 
   // ...
 }
-.ifLet(\.child, action: /Action.child)
+.ifLet(\.child, action: \.child)
```

And when enhance a parent feature with the functionality of a collection of features, one
can use the [`forEach`][foreach-docs] operator, and again with familiar key path syntax:

[foreach-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducer/foreach(_:action:element:fileid:line:)

```diff
 Reduce { state, action in 
   // ...
 }
-.forEach(\.rows, action: /Action.row(id:action:))
+.forEach(\.rows, action: \.rows)
```

And even better, the new key path syntax for case paths works better with Xcode autocomplete and 
Swift type inference.

This greatly simplifies nearly every reducer operator in the Composable Architecture, but it can
also be used to simplify other libraries using case paths such as our 
[SwiftUI Navigation][sui-nav-gh] library. But we will discuss that more later this week.

## Expressive case checking

But even if you are not using a library out there that uses case paths, you may still have 
use of case paths directly in your application. It makes it possible to easily check if an enum
value is of a particular case, and you can immediately access getter properties for each case of 
your enum.

For example, if you mark your enum with the [`@CasePathable`][casepathable-docs] macro: 

```swift
@CasePathable
enum Destination {
  case activity(ActivityModel)
  case settings(SettingsModel)
}
```

…then you immediately get access to an `is` method on your enum. It allows you to quickly check
the case of an enum value as an expression:

```swift
let destination: Destination = .activity(ActivityModel())

destination.is(\.activity)  // true
```

Typically this must be done as a statement, such as with an `if case let` or `guard case let`.
But now you can do it quickly, and inline as an expression.

## Case getters

Further, if you mark the `Destination` enum from above with both the 
[`@CasePathable`][casepathable-docs] macro _and_ `@dynamicMemberLookup`:

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
let activityModels = destinations.compactMap(\.activity)  // [ActivityModel]
```

All of this comes for free with CasePaths, but you do have to opt into the functionality by applying
`@dynamicMemberLookup` to your enum. If you only need the case paths for your enum and don't want
to clutter your type with unneeded properties, then you can use [`@CasePathable`][casepathable-docs]
by itself.

This tool also helps simplify a common pattern in Composable Architecture applications, which we
will show off tomorrow.

## Get started today

Update your dependency on CasePaths to [1.1][case-paths-1.1] today to start taking advantage of
the new [`@CasePathable`][casepathable-docs] macro, and more. Tomorrow we will discuss how these new 
case path tools have massively improved our [Composable Architecture][tca-gh] library. 

[case-paths-1.1]: https://github.com/pointfreeco/swift-case-paths/releases/tag/1.1.0
[casepathable-docs]: https://pointfreeco.github.io/swift-case-paths/main/documentation/casepaths/swift59
[case-paths-gh]: http://github.com/pointfreeco/swift-case-paths
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[sui-nav-gh]: http://github.com/pointfreeco/swiftui-navigation
[dependencies-gh]: http://github.com/pointfreeco/swift-dependencies
