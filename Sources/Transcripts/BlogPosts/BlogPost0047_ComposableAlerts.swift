import Foundation

public let post0047_ComposableAlerts = BlogPost(
  author: .pointfree,
  blurb: """
    Today we are releasing a new version of the Composable Architecture with helpers that make working with SwiftUI alerts and action sheets a breeze.
    """,
  contentBlocks: [
    .init(
      content: #"""
        Today we are releasing a new version of [the Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) with helpers that make working with SwiftUI alerts and action sheets a breeze.

        Because the Composable Architecture demands that all data flow through the application in a single direction, we cannot leverage SwiftUI's two-way bindings directly because they can make changes to state without going through a reducer. This means we can't use the standard API to display alerts and sheets without manually deriving these bindings.

        However, the library now comes with two new types, `AlertState` and `ActionSheetState`, which can be used in your application to control the presentation, dismissal, and logic of alerts and action sheets.

        For example, suppose you have a delete button that when tapped it will show an alert asking the user to confirm their deletion.
        You can model the actions of tapping the delete button, confirming the deletion, as well as canceling the deletion, in your domain's action enum:

        ```swift
        enum AppAction: Equatable {
          case alertCancelTapped
          case alertConfirmTapped
          case deleteButtonTapped

          // Your other actions
        }
        ```

        And you can model the state for showing the alert in your domain's state, which can start at `nil` to represent "dismissed":

        ```swift
        struct AppState: Equatable {
          var alert: AlertState<AppAction>?

          // Your other state
        }
        ```

        Then, in your reducer you can construct an `AlertState` value to represent the alert you want to show the user:

        ```swift
        let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
          switch action
            case .deleteButtonTapped:
              state.alert = AlertState(
                title: "Delete",
                message: "Are you sure you want to delete this? It cannot be undone.",
                primaryButton: .default("Confirm", send: .alertConfirmTapped),
                secondaryButton: .cancel()
              )
              return .none

            case .alertCancelTapped:
              state.alert = nil
              return .none

            case .alertConfirmTapped:
              state.alert = nil
              … // deletion logic...
          }
        }
        ```

        And then, in your view you can use the `.alert(_:dismiss:)` method on `View` in order to present the alert in a way that works best with the Composable Architecture:

        ```swift
        Button("Delete") { viewStore.send(.deleteTapped) }
          .alert(
            self.store.scope(state: \.alert),
            dismiss: .alertCancelTapped
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
            $0.alert = AlertState(
              title: "Delete",
              message: "Are you sure you want to delete this? It cannot be undone.",
              primaryButton: .default("Confirm", send: .alertConfirmTapped),
              secondaryButton: .cancel()
            )
          },
          .send(.deleteTapped) {
            $0.alert = nil
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
  publishedAt: Date(timeIntervalSince1970: 1_593_489_600),
  title: "The Composable Architecture and SwiftUI Alerts"
)
