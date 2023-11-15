Today we are announcing a [beta preview][tca-obs-beta-discussion] for the biggest change we have 
made to the [Composable Architecture][tca-gh] in its history. We are integrating Swift's Observation 
framework into th libray, and we are doing so that is 100% backwards compatible with the current 
version of the library, _and_ back deployed to previous versions of iOS, going all the way back to 
iOS 13.

That's right. Even though `@Observable` is restricted to iOS 17+, we have been able to backport 
those tools specifically for the Composable Architecture. So no matter what version of iOS your
app is currently targeting, you will be able to take advantage of observation and all of the new
tools we have added to the library.

Join us for a quick overview of what these tools look like, and be sure to give the 
[beta][tca-obs-beta-discussion] a spin and let us know if you run into any issues!

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
a view to display this feature can be done simply like so:

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

This small, but foundatinal change, to the library unlocks all new patterns that were previously
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

However, this `WithViewStore` is not like the `WithViewStore` that was required in the 
pre-Observation version of the Composable Architecture. First of all, this `WithViewStore` is only
required when targeting iOS 16 or earlier. It is deprecated when targeting iOS 17 and later, and in
that situation can be deleted.

Second of all, this `WithViewStore` does not take an `observe` argument for explicit observation
and its trailing closure does not take a `ViewStore`. You can access the store's state directly 
inside the trailing closure, and all state changes will be automatically observed.

So, while it's a bummer that `WithViewStore` is still necessary for pre-iOS 17, it's not all so bad.
It allows you to use the new observation tools _today_, it's just a small bit of additional code
in your view, and the library will helpfully tell you when you have forgotten it. 

## Composable Architecture, simplified


###  👋 IfLetStore

###  👋 ForEachStore

###  👋 SwitchStore and CaseLet

###  👋 Navigation APIs



## Try it out today!

[tca-gh]: todo
[tca-obs-beta-discussion]: todo
