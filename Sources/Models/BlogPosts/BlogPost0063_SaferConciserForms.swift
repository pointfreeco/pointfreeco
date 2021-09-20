import Foundation

public let post0063_SaferConciserForms = BlogPost(
  author: .pointfree,
  blurb: """
Today we are improving the Composable Architecture's first-party support for SwiftUI bindings with a safer, even conciser syntax.
""",
  contentBlocks: [
    .init(
      content: #"""
Due to a problem involving nested bindable state, we have since had to make things slightly less concise by trading dynamic member lookup for a more explicit method: _e.g._ `viewStore.$field` is now `viewStore.binding(\.$field)`. For more information on the change see [this release](https://github.com/pointfreeco/swift-composable-architecture/releases/0.28.0) and [this pull request](https://github.com/pointfreeco/swift-composable-architecture/pull/810).
"""#,
      type: .correction
    ),
    .init(
      content: #"""
Early this year, we did a [series of episodes](/collections/case-studies/concise-forms) on "concise forms." We showed how SwiftUI comes with some amazing tools for handling state through the use of two-way bindings that can be derived from property wrappers like `@State` and `@ObservedObject`. For simple forms it almost feels like magic.

We then compared this to [the Composable Architecture](/collections/composable-architecture), which adopts a "unidirectional" data flow, wherein the only way to mutate state is by sending actions to a runtime store, which holds all of the app's business logic and is responsible for mutating the state inside. From its very first release the Composable Architecture shipped with tools that integrate deeply with SwiftUI applications, including ways of deriving two-way bindings for various SwiftUI controls, by describing a field in state and an action that can mutate it.

This unfortunately means adding an action per mutable field, and logic for handling that action in the reducer, which is boilerplate that really begins to add up.

For example, a settings screen may model its state with the following struct:

```swift
struct SettingsState {
  var digest = Digest.daily
  var displayName = ""
  var enableNotifications = false
  var protectMyPosts = false
  var sendEmailNotifications = false
  var sendMobileNotifications = false
}
```

Each of these fields should be editable, and in the Composable Architecture this means that each
field requires a corresponding action that can be sent to the store. Typically this comes in the
form of an enum with a case per field:

```swift
enum SettingsAction {
  case digestChanged(Digest)
  case displayNameChanged(String)
  case enableNotificationsChanged(Bool)
  case protectMyPostsChanged(Bool)
  case sendEmailNotificationsChanged(Bool)
  case sendMobileNotificationsChanged(Bool)
}
```

And we're not even done yet. In the reducer we must now handle each action, which simply
replaces the state at each field with a new value:

```swift
let settingsReducer = Reducer<
  SettingsState, SettingsAction, SettingsEnvironment
> { state, action, environment in
  switch action {
  case let digestChanged(digest):
    state.digest = digest
    return .none

  case let displayNameChanged(displayName):
    state.displayName = displayName
    return .none

  case let enableNotificationsChanged(isOn):
    state.enableNotifications = isOn
    return .none

  case let protectMyPostsChanged(isOn):
    state.protectMyPosts = isOn
    return .none

  case let sendEmailNotificationsChanged(isOn):
    state.sendEmailNotifications = isOn
    return .none

  case let sendMobileNotificationsChanged(isOn):
    state.sendMobileNotifications = isOn
    return .none
  }
}
```

And then, in the view, we can derive two-way bindings from the view store to pass them along, which is pretty verbose to do:

```swift
Form {
  TextField(
    "Display name",
    text: viewStore.binding(
      get: \.displayName,
      send: SettingsAction.displayNameChanged
    )
  )
  Toggle(
    "Protect my posts",
    isOn: viewStore.binding(
      get: \.protectMyPosts,
      send: SettingsAction.protectMyPostsChanged
    )
  )
  Toggle(
    "Send notifications",
    isOn: viewStore.binding(
      get: \.sendNotifications,
      send: SettingsAction.sendNotificationsChanged
    )
  )

  if viewStore.sendNotifications {
    Toggle(
      "Mobile",
      isOn: viewStore.binding(
        get: \.sendMobileNotifications,
        send: SettingsAction.sendMobileNotificationsChanged
      )
    )
    Toggle(
      "Email",
      isOn: viewStore.binding(
        get: \.sendEmailNotifications,
        send: SettingsAction.sendEmailNotificationsChanged
      )
    )
    Picker(
      "Top posts digest",
      selection: viewStore.binding(
        get: \.digest,
        send: SettingsAction.digestChanged
      )
    ) {
      ForEach(Digest.allCases, id: \.self) { digest in
        Text(digest.rawValue)
      }
    }
  }
}
.alert(
  item: viewStore.binding(
    get: \.alert,
    send: SettingsAction.dismissAlert
  )
) { alert in
  Alert(title: Text(alert.title))
}
```

This is a _ton_ of boilerplate for something that should be simple. Luckily, we were able to employ some advanced Swift techniques, like type erasure and key paths, to dramatically eliminate this boilerplate by introducing `BindingAction`. It allowed us to collapse all of these field-mutating actions into a single case that holds a `FormAction` generic over the reducer's root `SettingsState`:

```swift
enum SettingsAction {
  case binding(BindingAction<SettingsState>)
}
```

Then we can collapse all of the field mutations in the reducer by instead tacking on the `binding` method, which performs all these field mutations for us:

```swift
let settingsReducer = Reducer<
  SettingsState, SettingsAction, SettingsEnvironment
> { state, action, environment in
  switch action {
  case .binding:
    return .none
  }
}
.binding(action: /SettingsAction.binding)
```

And finally, we used a view store helper that simplified the work of deriving a binding by specifying the a path and binding action:

```swift
TextField(
  "Display name",
  text: viewStore.binding(keyPath: \.displayName, send: SettingsAction.binding)
)
...
```

This was overall a _huge_ improvement! We were able to eliminate a ton of boilerplate in action enums and reducers.

However, this was not without a cost. Adding a `BindingAction` case to your action enum immediately gives your view unfettered access to mutate its state, which goes completely against the grain of the Composable Architecture.

For instance, if we introduce some state that should _not_ be mutated outside the reducer:

```swift
struct SettingsState {
  ...
  var isLoading = false
}
```

Nothing protects it in the view:

```swift
.onAppear {
  viewStore.send(.binding(.set(\.isLoading, true)))
}
```

And so, in our most recent two episodes, we faced this problem head-on, and along the way made things even _more_ concise, by utilizing even _more_ advanced Swift features, including property wrappers and dynamic member lookup. If you're interested in how, we hope you'll check them out today:

* [Safer, Conciser Forms: Part 1](/episodes/ep158-safer-conciser-forms-part-1)
* [Safer, Conciser Forms: Part 2](/episodes/ep159-safer-conciser-forms-part-2)

By introducing the `@BindableState` property wrapper, it is now possible to safely annotate which fields in state should be bindable:

```swift
struct SettingsState: Equatable {
  @BindableState var alert: AlertState? = nil
  @BindableState var digest = Digest.daily
  @BindableState var displayName = ""
  var isLoading = false
  @BindableState var protectMyPosts = false
  @BindableState var sendNotifications = false
  @BindableState var sendMobileNotifications = false
  @BindableState var sendEmailNotifications = false
}
```

Notably, `isLoading` is _not_ annotated, and so it can _not_ be mutated directly in the view.

Our action enum can stay mostly the same, except we have also introduced a `BindableAction` protocol, which can allow us to eliminate _even more boilerplate_.

```swift
enum SettingsAction: BindableAction {
  case binding(BindingAction<SettingsState>)
}
```

The protocol has a single requirement, which is a static `binding` method that can bundle up a `BindingAction` into itself, and because enum cases can conform to such requirements, `SettingsAction` already conforms!

With this protocol defined, we can simplify the reducer because we no longer have to specify the `binding` case explicitly:

```swift
let settingsReducer = Reducer<
  SettingsState, SettingsAction, SettingsEnvironment
> { state, action, environment in
  switch action {
  case .binding:
    return .none
  }
}
.binding()
```

But the real gains are seen in the view. Because the action can be inferred, we can adopt a syntax that matches the conciseness of vanilla SwiftUI!

```swift
Form {
  TextField("Display name", text: viewStore.$displayName)
  Toggle("Protect my posts", isOn: viewStore.$protectMyPosts)
  Toggle("Send notifications", isOn: viewStore.$sendNotifications)

  if viewStore.sendNotifications {
    Toggle("Mobile", isOn: viewStore.$sendMobileNotifications)
    Toggle("Email", isOn: viewStore.$sendEmailNotifications)
    Picker("Top posts digest", selection: viewStore.$digest) {
      ForEach(Digest.allCases, id: \.self) { digest in
        Text(digest.rawValue)
      }
    }
  }
}
.alert(item: viewStore.$alert) { alert in
  Alert(title: Text(alert.title))
}
```

That's over 3x shorter than what we had before!

## Say "hi" to safety, and "bye" to even more boilerplate today!

We've just released [version 0.26.0](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.26.0) of the Composable Architecture, and so you can start simplifying your existing code today. Let us know what you think [on Twitter](https://twitter.com/pointfreeco), or [start a discussion on GitHub](https://github.com/pointfreeco/swift-composable-architecture/discussions/new).
"""#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 63,
  publishedAt: Date(timeIntervalSince1970: 1630904400),
  title: "The Composable Architecture ❤️ SwiftUI Bindings"
)
