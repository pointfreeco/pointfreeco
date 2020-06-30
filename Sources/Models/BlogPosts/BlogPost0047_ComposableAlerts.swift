import Foundation

public let post0047_ComposableAlerts = BlogPost(
  author: .pointfree,
  blurb: """
Today we are releasing a new version of the Composable Architecture with built-in support for SwiftUI alerts and action sheets.
""",
  contentBlocks: [
    .init(
      content: #"""
Today we are releasing a new version of [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) with built-in support for SwiftUI alerts and action sheets.

Because the Composable Architecture demands that all data flow through the application in a single direction, we cannot leverage SwiftUI's two-way bindings because they can make changes to state without going through a reducer. This means we can't directly use the standard API to display alerts and sheets.

However, the library now comes with two types, `AlertState` and `ActionSheetState`, which can be used in your application's state in order to control the presentation or dismissal of alerts and action sheets.

You can model all of an alert's actions in your domain's action enum:

```swift
enum AppAction: Hashable {
  case cancelTapped
  case confirmTapped
  case deleteTapped

  // Your other actions
}
```

And you can model the state for showing the alert in your domain's state, and it can start off in the `.dismissed` state:

```swift
struct AppState {
  var alert = AlertState<AppAction>.dismissed

  // Your other state
}
```

Then, in the reducer you can construct an `AlertState` value to represent the alert you want to show the user:

```swift
let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action
    case .cancelTapped:
      state.alert = .dismissed
      return .none

    case .confirmTapped:
      state.alert = .dismissed
      // Do deletion logic...

    case .deleteTapped:
      state.alert = .show(
        title: "Delete",
        message: "Are you sure you want to delete this? It cannot be undone.",
        primaryButton: .default("Confirm", send: .confirmTapped),
        secondaryButton: .cancel()
      )
    return .none
  }
}
```

And then, in your view you can use the `.alert(_:send:dismiss:)` method on `View` in order to present the alert in a way that works best with the Composable Architecture:

```swift
Button("Delete") { viewStore.send(.deleteTapped) }
  .alert(
    viewStore.scope(state: \.alert),
    dismiss: .cancelTapped
  )
```

This makes your reducer in complete control of when the alert is shown or dismissed, and makes it so that any choice made in the alert is automatically fed back into the reducer so that you can handle its logic.

Even better, you can instantly write tests that your alert behavior works as expected:

```swift
let store = TestStore(
  initialState: AppState(),
  reducer: appReducer,
  environment: .mock
)

store.assert(
  .send(.deleteTapped) {
    $0.alert = .show(
      title: "Delete",
      message: "Are you sure you want to delete this? It cannot be undone.",
      primaryButton: .default("Confirm", send: .confirmTapped),
      secondaryButton: .cancel(send: .cancelTapped)
    )
  },
  .send(.deleteTapped) {
    $0.alert = .dismissed
    // Also verify that delete logic executed correctly
  }
)
```



## Clean up your alert and action sheet logic today

We've just released version [version 0.6.0](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.6.0) of the Composable Architecture, so you can start using these new helpers immediately. [Let us know](https://twitter.com/pointfreeco) what you think!
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 47,
  publishedAt: Date(timeIntervalSince1970: 1593489600),
  title: "The Composable Architecture and SwiftUI Alerts"
)
