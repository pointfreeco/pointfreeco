import Foundation

public let post0052 = BlogPost(
  author: .pointfree,
  blurb: """
Today we are releasing first-party support for concisely handling form data in the Composable Architecture.
""",
  contentBlocks: [
    .init(
      content: #"""
      Based on the code we wrote in our [latest episode on Concise Forms](/episodes/ep133-concise-forms-bye-bye-boilerplate), today we are releasing first-party support for concisely handling form data in the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). This allows you to minimize the boilerplate caused by needing to have a unique action for every UI control. Instead, all UI bindings can be consolidated into a single `form` action.

      ## Composable Forms

      The [latest version of the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.12.0) comes with some tools that allow you to dramatically eliminate the boilerplate that is typically incurred when working with multiple mutable fields on state.

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

      This is a _lot_ of boilerplate for something that should be simple. Luckily, we can dramatically eliminate this boilerplate using `FormAction`. First, we can collapse all of these field-mutating actions into a single case that holds a `FormAction` generic over the reducer's root `SettingsState`:

      ```swift
      enum SettingsAction {
        case form(FormAction<SettingsState>)
      }
      ```

      And then, we can simplify the settings reducer by tackling on the `form` method, which handle these field mutations for us:

      ```swift
      let settingsReducer = Reducer<
        SettingsState, SettingsAction, SettingsEnvironment
      > {
        switch action {
        case .form:
          return .none
        }
      }
      .form(action: /SettingsAction.form)
      ```

      That's it 🤯.

      Form actions are constructed and sent to the store by providing a writable key path from root state to the field being mutated. There is even a view store helper that simplifies this work. You can derive a binding by specifying the key path and form action case:

      ```swift
      TextField(
        "Display name",
        text: viewStore.binding(keyPath: \.displayName, send: SettingsAction.form)
      )
      ```

      Should you need to layer additional functionality over your form, your reducer can pattern match the form action for a given key path:

      ```swift
      case .form(\.displayName):
        // Validate display name

      case .form(\.enableNotifications):
        // Return an authorization request effect
      ```

      Form actions can event be tested in much the same way regular actions are tested. Rather than send a specific action describing how a binding changed, such as `displayNameChanged("Blob")`, you will send a `.form` action that describes which key path is being set to what value, such as `.form(.set(\.displayName, "Blob"))`:

      ```swift
      let store = TestStore(
        initialState: SettingsState(),
        reducer: settingsReducer,
        environment: SettingsEnvironment(...)
      )

      store.assert(
        .send(.form(.set(\.displayName, "Blob"))) {
          $0.displayName = "Blob"
        },
        .send(.form(.set(\.protectMyPosts, true))) {
          $0.protectMyPosts = true
        )
      )
      ```

      ## Say "bye" to boilerplate today!

      We've just released [version 0.12.0](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.12.0) of the Composable Architecture, and so you can start using this new feature immediately. [Let us know](https://twitter.com/pointfreeco) what you think!
      """#,
      type: .paragraph
    )
  ],
  coverImage: "",
  id: 52,
  publishedAt: .init(timeIntervalSince1970: 1612159200),
  title: #"Composable Forms: Say "Bye" to Boilerplate!"#
)
