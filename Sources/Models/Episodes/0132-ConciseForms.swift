import Foundation

extension Episode {
  public static let ep132_conciseForms = Episode(
    blurb: """
Building forms in the Composable Architecture seem to have the opposite strengths and weaknesses as vanilla SwiftUI. Simple forms are cumbersome due to boilerplate, but complex forms come naturally thanks to the strong opinion on dependencies and side effects.
""",
    codeSampleDirectory: "0132-concise-forms-pt2",
    exercises: _exercises,
    id: 132,
    image: "https://i.vimeocdn.com/video/1043547082-c78a11f59d37c2f18ad516106f78fa0a9ce2105a6a1324e04a71670a3dae7511-d",
    length: 61*60 + 29,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1611554400),
    references: [
      reference(
        forCollection: .dependencies,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/dependencies"
      ),
    ],
    sequence: 132,
    subtitle: "Composable Architecture",
    title: "Concise Forms",
    trailerVideo: .init(
      bytesLength: 65_488_407,
      vimeoId: 504277240,
      vimeoSecret: "11860484cfc5d26fc71d491f8f96b23737ce7b42"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Write a test for the unhappy path of denying push permission.
"""#,
    solution: #"""
It looks a lot like the happy path test, but we can make a few changes:

- Instead of introducing state for `didRegisterForRemoteNotifications`, we can leave that dependency as a `fatalError` instead.
- When we receive an authorization response where granted is false, we need to assert that state flips the toggle back, as well.

```swift
func testNotifications_UnhappyPath_Deny() {
  let store = TestStore(
    initialState: SettingsState(),
    reducer: settingsReducer,
    environment: SettingsEnvironment(
      mainQueue: DispatchQueue.immediateScheduler.eraseToAnyScheduler(),
      userNotifications: UserNotificationsClient(
        getNotificationSettings: {
          .init(value: .init(authorizationStatus: .notDetermined))
        },
        registerForRemoteNotifications: { fatalError() },
        requestAuthorization: { _ in
          .init(value: false)
        }
      )
    )
  )

  store.assert(
    .send(.sendNotificationsChanged(true)),
    .receive(.notificationSettingsResponse(.init(authorizationStatus: .notDetermined))) {
      $0.sendNotifications = true
    },
    .receive(.authorizationResponse(.success(false))) {
      $0.sendNotifications = false
    }
  )
}
```
"""#
  ),
  Episode.Exercise(
    problem: #"""
Write a test for tapping send notifications when authorization stats starts in a `denied` state. Try to get as much coverage for this flow as possible.
"""#,
    solution: #"""
Much like the previous test, but:

- We can now fatal error in `requestAuthorization`, as well.
- We must update state with the alert.
- We should additionally send a `.dismissAlert` action to test `nil`ing out this state.

```swift
func testNotifications_UnhappyPath_PreviouslyDenied() {
  let store = TestStore(
    initialState: SettingsState(),
    reducer: settingsReducer,
    environment: SettingsEnvironment(
      mainQueue: DispatchQueue.immediateScheduler.eraseToAnyScheduler(),
      userNotifications: UserNotificationsClient(
        getNotificationSettings: {
          .init(value: .init(authorizationStatus: .denied))
        },
        registerForRemoteNotifications: { fatalError() },
        requestAuthorization: { _ in fatalError() }
      )
    )
  )

  store.assert(
    .send(.sendNotificationsChanged(true)),
    .receive(.notificationSettingsResponse(.init(authorizationStatus: .denied))) {
      $0.alert = .init(title: "You need to enable permissions from iOS settings")
    },
    .send(.dismissAlert) {
      $0.alert = nil
    }
  )
}
```
"""#
  ),
]
