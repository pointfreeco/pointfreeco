Today we are releasing [version 1.8][1.8-release-notes] of the [Composable Architecture][tca-gh] 
that brings all new super powers to the `@Reducer` macro. Join us for a quick overview of the 
changes, and be sure to check out the [migration guide][1.8-migration] for more details on how
to update your applications.

## Progressive disclosure

The first super power brought to `@Reducer` is that it will automatically fill in any missing 
requirements from the `Reducer` protocol. For example, even something as simple as this:

```swift
@Reducer
struct Feature {
}
```

…now compiles. The `@Reducer` macro will automatically fill in an empty `State` struct, an empty
`Action` enum, and an empty reducer `body`. That satisfies all of the requirements of the
`Reducer` protocol, and so this is valid, compiling code.

Why would you want to do this though?

It makes it easy to stub out a simple feature for use in a view or for integrating into a parent
domain without needing to explicitly provide all of the requirements. For example, if using the 
destination reducer pattern for modeling navigation (as described in our 
[tree-based navigation article][tree-based-nav-article]), then you can already integrate the 
`Feature` reducer into your `Destination`:

```diff
 @Reducer
 struct Destination {
   @ObservableState
   enum State {
     // Other cases
+    case feature(Feature.State)
   }
   enum Action {
     // Other cases
+    case feature(Feature.Action)
   }
   var body: some ReducerOf<Self> {
     // Other scopes
+    Scope(state: \.feature, action: \.feature) {
+      Feature()
+    }
   }
 }
```

And you can present the feature's view using any SwiftUI navigation view modifier, such as 
`sheet(item:)`:

```swift
.sheet(item: $store.scope(state: \.destination?.feature, action: \.destination.feature)) { store in
  FeatureView(store: store) 
}
```

This makes it easy to slowly implement the logic and behavior in your features as needed.

## Codified destination and path reducer pattern

The second super power added to `@Reducer` is the ability for it to automatically generate most
of the code needed to implement the "destination reducer" and "path reducer" patterns. The 
destination pattern is described in our [tree-based navigation article][tree-based-nav-article],
and it is the process of representing all the places a feature can navigate to by integrating
them all together into a single `Destination` reducer.

For example, suppose an inventory feature could navigate to "Add" feature, a "Detail" feature,
and an "Edit" feature. This can be represented by the following single reducer that composes all
of those features together:

```swift
@Reducer
struct Destination {
  @ObservableState
  enum State {
    case add(FormFeature.State)
    case detail(DetailFeature.State)
    case edit(EditFeature.State)
  }
  enum Action {
    case add(FormFeature.Action)
    case detail(DetailFeature.Action)
    case edit(EditFeature.Action)  
  }
  var body: some ReducerOf<Self> {
    Scope(state: \.add, action: \.add) {
      FormFeature()
    }
    Scope(state: \.detail, action: \.detail) {
      DetailFeature()
    }
    Scope(state: \.edit, action: \.edit) {
      EditFeature()
    }
  }
}
```

And then the parent feature can hold onto a single piece of optional `Destination.State`:

```swift
struct State {
  @Presents var destination: Destination.State?
  // Other fields
}
```

The pros of this style is that we have one single piece of optional state that determines 
whether or not a navigation is active. The alternative is to hold onto an optional piece of state
for each destination, but that create 2^3 = 8 possibile combinations of `nil` and non-`nil` state, 
only 4 of which are actually valid: they are either all `nil` or exactly one is non-`nil`.

So, it's a powerful pattern, but maintaining the `Destination` reducer can be a bit of a pain.
Each new destination that is added requires adding a new case to the `State` enum, a new case to
the `Action` enum, and adding a `Scope` reducer to the `body`.

Well, now thanks to the new super powers of the `@Reducer` macro, the `Destination` reducer can be 
implemented simply as this:

```swift
@Reducer
enum Destination {
  case add(FormFeature)
  case detail(DetailFeature)
  case edit(EditFeature)
}
```

That's right, 24 lines of code becomes just 4. And further, when integrating the `Destination` 
reducer into the parent feature, one can use the `ifLet` operator without even specifying a 
trailing closure:  

```diff
 Reduce { state, action in
   // Core feature logic 
 }
 .ifLet(\.$destination, action: \.destination)
-{
-  Destination()
-}
```

The same simplifications can be made to `Path` reducers when using navigation stacks, as detailed
in our [stack-based navigation article][stack-based-nav-article].

## Get started today

Update your projects to [version 1.8][1.8-release-notes] of the Composable Architecture today to 
make use of these new super powers of the `@Reducer` macro.

[1.8-migration]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.8
[1.8-release-notes]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.8.0
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture
[tree-based-nav-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/treebasednavigation
[stack-based-nav-article]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/stackbasednavigation
