After [2 months][obs-beta-blog] in beta, we are [finally releasing][1.7-release] the 
Composable Architecture with Swift 5.9's observation tools tightly integrated. This 
simplifies nearly every facet of the library, and allows us to drastically reduce the APIs in the 
library and leverage SwiftUI's APIs more fully.

And best of all, this release is 100% backwards compatible with the last release of the library, 
which means you can start incrementally using these tools _today_. Oh, and we also 
[backported][perception-blog-post] all of the observation tools so that they work on older Apple 
platforms going all the way back to
iOS 13!

Join us for a quick overview of the changes, and also be sure to check out the 
[migration guide][1.7-migration-guide] and [update your project to 1.7][1.7-release] today to get
all of the benefits.

[1.7-release]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.7.0
[obs-beta-blog]: /blog/posts/125-observable-architecture-beta
[1.7-migration-guide]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.7
[perception-blog-post]: /blog/posts/129-perception-a-back-port-of-observable
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture
[isowords-gh]: https://github.com/pointfreeco/isowords 

!> [announcement]: Today is our [6 year anniversary](/blog/posts/131-point-free-turns-6)! 🥳 <br><br> To celebrate we have announced a [live stream](/live) for next week, Feburary 5th at 9am PST / 5pm GMT. We will dive into the observation tools live, field questions from our viewers, and announce two brand new features of the Composable Architecture that no one has seen. 😲

## 👋 Goodbye view stores!

By far the most substantial improvement to the library is that view stores, and a flurry of related
concepts, are no longer needed. View stores were necessary in the beginning because one needed to 
be able to hold a lot of state in a feature, yet observe only a small part of the state. Now that
is all handled automatically for us thanks to Swift's new observation tools.

To update your features, simply annotate the `State` type of your reducers with the 
`@ObservableState` macro (it works with both structs and enums):

```diff
 @Reducer
 struct Feature {
+  @ObservableState
   struct State { /* ... */ }
   …
 }
``` 

And then in the view you can drop any usage of `WithViewStore` and simply access state directly 
from the store:

```diff
 var body: some View {
-  WithViewStore(store, observe: ViewState.init) { store in
   Form {
-    Text(viewStore.count.description)
+    Text(store.count.description)
-    Button("+") { viewStore.send(.incrementButtonTapped) }
+    Button("+") { store.send(.incrementButtonTapped) }
   }
-  }
 }
```

All state access is immediately tracked so that the view will only observe changes to that state,
and nothing else.

However, as the code is written above, this will only work on devices running iOS 17. If you are
deploying to iOS 16 or lower, then there is one small additional step you must take. We recently
[backported Swift's observation tools][perception-blog-post] so that they work on iOS 16 and 
earlier. But, in order for observation to be tracked properly, you must wrap your view in 
`WithPerceptionTracking`: 

```diff
 var body: some View {
+  WithPerceptionTracking {
     Form {
       Text(store.count.description)
       Button("+") { store.send(.incrementButtonTapped) }
     }
+  }
 }
``` 

That's all it takes to automatically get observation tracking, and you can run the app on iOS
versions going all the way back to 13!

## 👋 Goodbye IfLetStore, ForEachStore, SwitchStore, NavigationStackStore and navigation view modifiers!

Historically, the Composable Architecture needed to maintain a whole zoo of tools, views, and view 
modifiers in order to make SwiftUI work with the library, _and_ for state to be observed in the most 
minimal way possible. But now that observation happens automatically, and is based on what state is 
accessed in the view, we can completely get rid of those tools.

For example, to derive a `Store` to an optional child domain, one would previously use the 
`IfLetStore` helper view. But now one can simply use a vanilla Swift `if let` statement:

```diff
-IfLetStore(store: store.scope(state: \.child, action: \.child)) { childStore in
+if let childStore = store.scope(state: \.child, action: \.child)) {
   ChildView(store: childStore)
 } else: {
   Text("Nothing to show")
 }
```

Similarly, the library needed to provide a `ForEachStore` view helper in order to efficiently
observe collections of features, but now one can use a regular `ForEach` view and hand it a store
scoped to a collection of features:

```diff
-ForEachStore(store.scope(state: \.rows, action: \.rows)) { childStore in
+ForEach(store.scope(state: \.rows, action: \.rows)) { childStore in
   ChildView(store: childStore)
 }
```

The library also had to provide tools for efficiently switching over enums of features called
`SwitchStore` and `CaseLet`. These concepts now completely go away and one can use a regular 
`switch` statement:

```diff
-SwitchStore(store) {
-  switch $0 {
+  switch store.state {
   case .activity:
-    CaseLet(/Feature.State.activity, action: Feature.Action.activity) { store in
-      ActivityView(store: store)
-    }
+    store.scope(state: \.activity, action: \.activity).map(ActivityView.init)
   case .settings:
-    CaseLet(/Feature.State.settings, action: Feature.Action.settings) { store in
-      SettingsView(store: store)
-    }
+    store.scope(state: \.settings, action: \.settings).map(SettingsView.init)
   }
-}
```

Even navigation stacks needed their own helper, called `NavigationStackStore`. This too goes away
and one can now use the custom initializer the library provides for specifying the path of features
that drives navigation, as well as a trailing closure to describe the views to present for each 
feature: 

```diff
-NavigationStackStore(store.scope(state: \.path, action: \.path)) {
+NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
   RootView()
-} destination: {
-  switch $0 {
+} destination: { store in
+  switch store.state {
   case .activity:
-    CaseLet(/Feature.State.activity, action: Feature.Action.activity) { store in
-      ActivityView(store: store)
-    }
+    store.scope(state: \.activity, action: \.activity).map(ActivityView.init)
   case .settings:
-    CaseLet(/Feature.State.settings, action: Feature.Action.settings) { store in
-      SettingsView(store: store)
-    }
+    store.scope(state: \.settings, action: \.settings).map(SettingsView.init)
   }
 }
```

And the library also needed to supply a whole plethora of navigation view modifiers that mimic
the vanilla SwiftUI APIs, but tuned specifically for the Composable Architecture. This included
`sheet(store:)`, `popover(store:)`, `fullScreenCover(store:)`, and more. But now all of those go
away, and instead you can use the vanlla SwiftUI modifiers by deriving a binding from the store
for the feature you want to present:

```diff
-.sheet(store: store.scope(state: \.$child, action: \.child)) { store in
+.sheet(item: $store.scope(state: \.child, action: \.child)) { store in
   ChildView(store: store)
 }
```

This is only scratching the surface of what Swift's observation tools have allowed us to 
simplify. Be sure to follow the [migration guide][1.7-migration-guide] to update your application
to use all the newest tools.

And once we decide to release our next major version (2.0), we will be able to delete
thousands of lines of code and documentation, making the library lighter weight and improving
compile times for complex features. 

## UIKit

While the initial version of Swift's observation tools were clearly made with SwiftUI (and only 
SwiftUI) in mind, we still wanted to provide some tools for people using UIKit. Even if you were
to build a brand new application today hoping to use only the newest of SwiftUI's tools, you will
inevitably need to escape out of the SwiftUI world in order to accomplish something that SwiftUI
cannot do. For our [isowords][isowords-gh] game we had to escape out of the SwiftUI world in order
to fully interface with SceneKit.

So, the library comes with a tool called [`observe(_:)`][observe-docs] that lets you set up an 
observation loop for updating your UI when state changes. It is most appropriate to call once in the 
entry point of a view, such as `viewDidLoad` of a `UIViewController`:

```swift
override func viewDidLoad() {
  super.viewDidLoad()

  observe { [weak self] in
    guard let self else { return }

    countLabel.isHidden = store.isObservingCount
    if !countLabel.isHidden {
      countLabel.text = "\(store.count)"
    }
    factLabel.text = store.fact
  }
}
```

In the code above we are able to update the controller's UI components with state from the store,
and further the mere act of accessing state makes `observe` automatically observe changes to that
state. So, if `count` changes the `observe` trailing closure will execute again, allowing us to
update the label's text.

## Get started today

Follow the [migration guide][1.7-migration-guide] to upgrade your projects to 
[version 1.7][1.7-release] of the Composable Architecture to start making use of its new observation 
tools today. And we have some big plans for the library in the coming months, so stay tuned!

[1.7-release]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/1.7.0
[obs-beta-blog]: /blog/posts/125-observable-architecture-beta
[1.7-migration-guide]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.7
[perception-blog-post]: /blog/posts/129-perception-a-back-port-of-observable
[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture
[isowords-gh]: https://github.com/pointfreeco/isowords 
[observe-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/objectivec/nsobject/observe(_:)
