!> [warning]: There are some episode spoilers contained in this announcement! Reader beware!

Two very exciting things happened today: the [Composable Architecture][tca-gh] has crossed
10,000 stars on GitHub(!), and we are announcing a [beta preview][tca-obs-beta-discussion] for the 
biggest change we have made to the library in its history. We are integrating Swift's Observation 
framework into the library, and we are doing so in a way that is 100% backwards compatible with the 
current version of the library, _and_ back deployed to previous versions of iOS, going all the way 
back to iOS 13.

That's right!

Even though `@Observable` is restricted to iOS 17+, we have been able to backport those tools
specifically for the Composable Architecture. So no matter what version of iOS your app is currently
targeting, you will be able to take advantage of observation and all of the new tools we have added
to the library.

This week we are kicking off a [new series of episodes][observable-arch-eps] to integrate these
tools into the library from scratch, but join us for a quick overview of what these tools look like,
and be sure to give the [beta][tca-obs-beta-discussion] a spin and let us know if you run into any
issues!

[observable-arch-eps]: /collections/composable-architecture/observable-architecture
[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[tca-obs-beta-discussion]: todo

## @ObservableState

The Composable Architecture provides a new macro called `@ObservableState` which unlocks the new
observation super powers. As a very simple example, consider a counter reducer that has the 
`@ObservableState` macro applied:

```swift
@Reducer
struct CounterFeature {
  @ObservableState 
  struct State {
    var count = 0
  }
  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1 
        return .none
      case .incrementButtonTapped:
        state.count += 1 
        return .none
      } 
    }
  }
}
```

This doesn't look much different from how this feature would be built with the Composable 
Architecture _pre_-Observation. The only difference is that we have applied `@ObservableState` to 
the `State` struct.

But that small change has huge ramifications to how we build features with the library. For example,
a view to display this feature is now allowed to access state directly in the view like so:

```swift
struct CounterView: View {
  let store: StoreOf<CounterFeature>
  
  var body: some View {
    Form {
      Text(self.store.count.description)
      Button("Decrement") { self.store.send(.decrementButtonTapped) }
      Button("Increment") { self.store.send(.incrementButtonTapped) }
    }
  }
}
```

There is no need to wrap everything in a `WithViewStore` or to explicitly describe what state is 
being observed as was the case before. The view sees that the `count` field is accessed and 
automatically subscribes to its changes so that it can re-render. 

Even better, this automatic observation is dynamic. If something happens in the view later so that
`count` is no longer displayed, then the view will no longer re-render when that state changes. To
see this concretely, let's add some state to the feature that determines if the `count` is being
displayed:

```swift
@ObservableState 
struct State {
  …
  var isDisplayingCount = true
}
```

…and an action to toggle this boolean:

```swift
enum Action {
  …
  case toggleCountDisplay
}
```

…and handle the action in the reducer:

```swift
case .toggleCountDisplay:
  state.isDisplayingCount.toggle()
  return .none
```

Then in the view we can conditionally display the count and add a button that toggles the display:

```swift
var body: some View {
  Form {
    if self.store.isDisplayingCount {
      Text(self.store.count.description)
    }
    Button("Decrement") { self.store.send(.decrementButtonTapped) }
    Button("Increment") { self.store.send(.incrementButtonTapped) }
    Button("Toggle count display") { self.store.send(.toggleCountDisplay) }
  }
}
```

With this the body of the `CounterView` will not re-compute its body if the `count` changes and if
the count isn't being displayed. The view is capable of seeing that it doesn't need the `count`
to render, and therefore does not need to re-render when it changes.

This small, but foundational change, to the library unlocks all new patterns that were previously
impossible to imagine. There are large swaths of custom tools and APIs that are no longer needed,
and instead simpler, more vanilla Swift and SwiftUI tools can be used.

But before discussing that, a word on a very important topic…

## Backport to pre-iOS 17

Perhaps the most surprising and exciting part of this beta is that we have completely backported
the observation tools to platforms prior to iOS 17, macOS 14, tvOS 17 and watchOS 10, which is what
`@Observation` is restricted to. This means you can start using these smarter, more dynamic 
observation tools while still supporting older OSes.

However, you do have to make a slight change to your code to make this possible. If your application
is running on iOS 16 or earlier, then you can't simply access state directly in the store as we are 
doing above because the view has no way to track changes to state accessed in the `body`.

In fact, if you try to implement your view as above on iOS 16 and earlier, the library will emit
a runtime warning letting you know that this will not work: 

!> [runtime-warning]: Perceptible state was accessed but is not being tracked. Track changes to 
> state by wrapping your view in a 'WithPerceptionTracking' view.

This warning is giving you a peek under the hood to see how this backporting works.

There is one small change you have to make to the view, and that is wrap it in 
`WithPerceptionTracking`:

```diff
 var body: some View {
+  WithPerceptionTracking {
     Form {
       if self.store.isDisplayingCount {
         Text(self.store.count.description)
       }
       Button("Decrement") { self.store.send(.decrementButtonTapped) }
       Button("Increment") { self.store.send(.incrementButtonTapped) }
       Button("Toggle count display") { self.store.send(.toggleCountDisplay) }
     }
+  }
 }
```

However, this wrapper is not like the `WithViewStore` that was required in the pre-Observation
version of the Composable Architecture. First of all, `WithPerceptionTracking` is only required when
targeting iOS 16 or earlier. It is deprecated when targeting iOS 17 and later, and in that situation
can be deleted.

Second of all, `WithPerceptionTracking` does not take an `observe` argument for explicit observation
and its trailing closure does not take a `ViewStore`. You can access the store's state directly 
inside the trailing closure, and all state changes will be automatically observed.

So, while it's a bummer that you still need to wrap your views in a helper for pre-iOS 17, it's not 
all so bad. It allows you to use the new observation tools _today_, it's just a small bit of 
additional code in your view, and the library will helpfully tell you when you have forgotten it. 

## Composable Architecture, simplified

The best part of integration Swift's observation tools into the Composable Architecture is that it
allows us to re-think every assumption we made when first building the library. There are many APIs
that we now get to say goodbye to in favor of simpler constructs:

### 👋 IfLetStore

[`IfLetStore`][ifletstore-docs] is a helper view for transforming stores of optional state into
stores of honest state. It's great for when you model your features so that a child feature can be
shown and dismissed via some optional state.

Its typical use looks something like this:

```swift
IfLetStore(
  store: self.store.scope(state: \.child, action: \.child)
) { childStore in 
  ChildView(store: childStore)
} else: {
  Text("Nothing to show")
}
```

You hand the view a store that is scoped down to an optional child domain, as well as a trailing
closure for when that state is non-`nil`, and optionally a trailing closure for when the state is 
`nil`.

This code can now be simplified to the following when using `@ObservableState`:

```swift
if let childStore = self.store.scope(state: \.child, action: \.child) {
  ChildView(store: childStore)
} else {
  Text("Nothing to show")
}
```

There's no need to learn a whole new type to accomplish something so simple. You can just use 
regular `if let` Swift syntax. 

### 👋 ForEachStore

[`ForEachStore`][foreachstore-docs] is another helper view, but this one helps transform a store of
a collection into stores for each element in the collection. It's great for when you need to a list
of complex features.

Its typical use looks something like this:

```swift
ForEachStore(self.store.scope(state: \.rows, action: \.rows)) { rowStore in
  RowView(store: rowStore) 
}
```

You hand `ForEachStore` a store scoped down to the domain of a collection of features, and it
provides a store that is focused on just one element of that feature.

This code can now be simplified to the following when using `@ObservableState`:

```swift
ForEach(self.store.scope(state: \.rows, action: \.rows)) { rowStore in
  RowView(store: rowStore) 
}
```

There's no need to learn a whole new type to accomplish something so simple. You can just use a
vanilla SwiftUI `ForEach`, and it all _just works_.

### 👋 SwitchStore and CaseLet

There's even more view helpers that completely go away with the new observation tools. The 
[`SwitchStore`][switchstore-docs] and [`CaseLet`][caselet-docs] views help transform a store of an 
enum of features into a store focused in on just one particular case of the enum.

It's typical use looks something like this:

```swift
SwitchStore(self.store) {
  CaseLet(
    /Feature.State.loggedIn,
    action: Feature.Action.loggedIn
  ) { loggedInStore in
    LoggedInView(store: loggedInStore) 
  }
  CaseLet(
    /Feature.State.loggedOut,
    action: Feature.Action.loggedOut
  ) { loggedOutStore in
    LoggedOutView(store: loggedOutStore) 
  }
}
```

While it's a powerful tool, there's a lot not to like about this. First, it's quite verbose. And we
lose compile-time verification that we handled all cases of the enum, and instead have to resort to
runtime checks. And we cannot leverage type inference to shorten some of the types used.

This code can now be simplified to the following when using `@ObservableState`:

```swift
switch self.store.state {
case .loggedIn:
  if let loggedInStore = self.store.scope(state: \.loggedIn, action: \.loggedIn) {
    LoggedInView(store: loggedInStore)
  }

case .loggedOut:
  if let loggedOutStore = self.store.scope(state: \.loggedOut, action: \.loggedOut) {
    LoggedOutView(store: loggedOutStore)
  }
}
```

This recovers compile-time exhaustivity and type inference, and there's no need to learn two new 
types to accomplish something so simple. You can just use a vanilla Swift `switch` and `case`, 
and everything _just works_. 

### 👋 NavigationStackStore 

The most recent view helper we added to the library is the `NavigationStackStore`, and even it is
now obsolete in the world of observation tools. It's a dedicated view that helps derive stores
to each element of a collection of features to be used in stack navigation.

It's typical use looks something like this:

```swift
NavigationStackStore(self.store.scope(state: \.path, action: \.path)) {
  RootView()
} destination: {
  switch $0 {
  case .activity:
    CaseLet(/Feature.State.activity, action: Feature.Action.activity) { store in
      ActivityView(store: store)
    }
  case .settings:
    CaseLet(/Feature.State.settings, action: Feature.Action.settings) { store in
      SettingsView(store: store)
    }
  }
}
```

Again we lose exhaustivity in the destinations that can be navigated too, and this code is quite
verbose.

This code can now be simplified to the following when using `@ObservableState`:

```swift
NavigationStack(path: self.$store.scope(state: \.path, action: \.path)) {
  RootView()
} destination: { $0 in
  switch $0.state {
  case .activity:
    if let store = store.scope(state: \.activity, action: \.activity) {
      ActivityView(store: store)
    }
  case .settings:
    if let store = store.scope(state: \.settings, action: \.settings) {
      SettingsView(store: store)
    }
  }
}
```

We regain compile-time exhaustivity, and we do not have to learn a whole new type to accomplish
something so simple. You can just use a vanilla SwiftUI `NavigationStack` and everything 
_just works_. 

### 👋 Navigation APIs

There's even _more_ APIs that can be removed from the library thanks to the new observation tools.
We currently maintain a whole zoo of navigation view modifiers that mimic vanilla SwiftUI ones, but
are tuned specifically for driving navigation from `Store`s.

For example, if you model the edit flow with some optional state, then you can present and dismiss
a sheet from that data like so:

```swift
.sheet(
  store: self.store.scope(state: \.$editItem, action: \.editItem)
) { store in
  EditItemForm(store: store)
}
```

This can now be simplified to the following:

```swift
.sheet(
  item: self.$store.scope(state: \.editItem, action: \.editItem)
) { store in
  EditItemForm(store: store)
}
```

In particular, we are now using the vanilla SwiftUI modifier `sheet(item:)`, and the binding that
is handed to that modifier is derived from the binding `$store`. It may not seem like a huge change, 
but there are now hundreds of lines of code that the library no longer has to maintain to mimic and
wrap the SwiftUI APIs.

This also works when navigation is driven from an enum of destinations by simply chaining into a
case:

```swift
.sheet(
  item: self.store.scope(state: \.destination?.editItem, action: \.editItem.editItem)
) { store in
  EditItemForm(store: store)
}
```

## Try it out today!

And unbelievably, all the improvements listed above still do not tell the whole store of how
Swift 5.9's Observation framework has revolutionized the Composable Architecture. Be sure to
follow along in our [new series of episodes][observable-arch-eps] to see how we accomplished all of
this (and more), and give the [beta][tca-obs-beta-discussion] a spin and let us know if you run into
any issues!

[tca-gh]: http://github.com/pointfreeco/swift-composable-architecture
[tca-obs-beta-discussion]: todo
[ifletstore-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/ifletstore
[foreachstore-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/foreachstore
[observable-arch-eps]: /collections/composable-architecture/observable-architecture
[nav-stack-store-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/navigationstackstore
[switchstore-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/switchstore
[caselet-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/caselet
