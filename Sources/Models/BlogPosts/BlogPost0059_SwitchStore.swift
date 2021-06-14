import Foundation

public let post0059_SwitchStore = BlogPost(
  author: .pointfree,
  blurb: """
We are adding new tools for handling enum state in the Composable Architecture, with a focus on safety and performance.
""",
  contentBlocks: [
    .init(
      content: """
This week's [episode](/episodes/ep149-derived-behavior-optionals-and-enums) took a deep dive into how we can embrace some of Swift's most important data modeling tools (optionals and enums) in the Composable Architecture without sacrificing composition of our application's behavior. We showed that one our very own case study applications, the [Tic-Tac-Toe app](https://github.com/pointfreeco/swift-composable-architecture/blob/7b42aaced0153c67e6f97659fd7bcfd605428243/Examples/TicTacToe/Sources/Core/AppCore.swift#L7-L12) demo, modeled its root state in a less than ideal fashion: using two optional values instead of an enum. This allows invalid states to be representable in our application, which leaks into application logic making it more complex, and so we'd love to make those states [unrepresentable](/episodes/ep4-algebraic-data-types) by the compiler.

Unfortunately, the [Composable Architecture](/collections/composable-architecture) does not come with the tools necessary to properly use enums for state… well, until today that is! We are [releasing](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.19.0) a new version of the library that adds a `pullback` method on `Reducer` and a `SwitchStore` view that are specifically tuned for breaking down behaviors modeled on enum state into behavior for each case of the enum.

## `Reducer.pullback`

We often want to model the state of a part of our applications using an enum to represent mutually exclusive states. For example, at the root of our application we may separate the logged-in and logged-out states into cases of an enum:

```swift
enum AppState {
  case loggedIn(LoggedInState)
  case loggedOut(LoggedOutState)
}
```

In the Composable Architecture we like to define reducers on sub-state and then use the `pullback` and `combine` operators to piece multiple reducers together into one big reducer that operates on bigger pieces of state. The `pullback` operator accomplishes this by using a `WritableKeyPath` to extract out sub-state, operate on it, and then plug it back into the whole state. So we would hope we could define a reducer for each of the logged-in domain and logged-out domain that could then be pieced together to operate on the entire app domain.

However, when state is modeled as an enum we do not have access to key paths. We instead need a way to try to extract a particular case from the state enum, operate on it, and then embed it back into the state enum. This is precisely what [case paths](/collections/enums-and-structs/case-paths) excel at, which is the analogous concept for key paths, but tuned specifically for enums instead.

So, rather than pulling back a reducer along a key path to some sub-state we can instead pull back along a _case path_ to a sub-case:

```swift
let loggedInReducer: Reducer<LoggedInState, LoggedInAction, LoggedInEnvironment> = ...

let loggedOutReducer: Reducer<LoggedOutState, LoggedOutAction, LoggedOutEnvironment> = ...

let appReducer = Reducer.combine(
  loggedInReducer.pullback(
    state: /AppState.loggedIn,
    action: /AppAction.loggedIn,
    environment: { LoggedInEnvironment(...) }
  ),

  loggedOutReducer.pullback(
    state: /AppState.loggedOut,
    action: /AppAction.loggedOut,
    environment: { LoggedOutEnvironment(...) }
  )
)
```

## `SwitchStore`

While the `pullback` operator helps us compose the logic of our application, the `SwitchStore` view helps us compose the behavior of our application. It serves the same purpose that the `IfLetStore` serves for optionals and the `ForEachStore` serves for collections, but is tuned specifically for enums. It allows you to destructure a store into multiple stores, one for each case of your state's enum.

For example, if we had a `LoggedInView` and `LoggedOutView` to represent the root view for each of the logged in and out states, then we could "switch" on the root store in order to figure out which view to display:

```swift
SwitchStore(self.store) {
  CaseLet(state: /AppState.loggedIn, action: AppAction.loggedIn) { loggedInStore in
    LoggedInView(store: loggedInStore)
  }

  CaseLet(state: /AppState.loggedOut, action: AppAction.loggedOut) { loggedOutStore in
    LoggedOutView(store: loggedOutStore)
  }
}
```

Under the hood the `SwitchStore` view figures out whenever your state enum's case changes from the `.loggedIn` case to the `.loggedOut` case (or vice-versa), and will make sure the correct view is displayed. You can also leverage SwiftUI's transition APIs to automatically animate when the views appear or disappear:

```swift
SwitchStore(self.store) {
  CaseLet(state: /AppState.loggedIn, action: AppAction.loggedIn) { loggedInStore in
    LoggedInView(store: loggedInStore)
      .transition(.opacity.combined(with: .offset(x: 0, y: 20))
  }

  CaseLet(state: /AppState.loggedOut, action: AppAction.loggedOut) { loggedOutStore in
    LoggedOutView(store: loggedOutStore)
      .transition(.opacity)
  }
}
```

This will make it so that the `LoggedInView` appears with a crossfade and a small vertical translation, whereas the `LoggedOutView` will just appear with a crossfade.

## Performance

The `SwitchStore` view has a few tricks up its sleeve in order to do its job with the best performance possible. If implemented naively, the `SwitchStore` would re-compute its body when any piece of state changes inside the enum. However, we only care when the state enum changes from one case to another case so that we can show the respective view. We don't need to know about all the changes within a particular case.

By taking advantage of Swift's powerful metadata embedded in every Swift program we can write a [function](https://github.com/pointfreeco/swift-composable-architecture/blob/3d8db944c7c14496f49c608ad66551cef6086cb1/Sources/ComposableArchitecture/SwiftUI/SwitchStore.swift#L585-L601) that determines the case of any enum, and so so blazingly fast. This metadata is the same info that SwiftUI uses to its seemingly magic behavior. It's an advanced feature of Swift that doesn't get enough attention, but it allows the `SwitchStore` to minimize the number of times it needs to re-compute its body.

## Try it today

Upgrade to the latest version of [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.19.0) to immediately gain access to these tools today, and enhance your applications with the expressiveness of enum state.
""",
      type: .paragraph
    )
  ],
  coverImage: "https://d1iqsrac68iyd8.cloudfront.net/posts/0059-switchstore/poster.png",
  id: 59,
  publishedAt: Date(timeIntervalSince1970: 1623646800),
  title: "Announcing SwitchStore for the Composable Architecture"
)
