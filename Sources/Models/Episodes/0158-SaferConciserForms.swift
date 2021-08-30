import Foundation

extension Episode {
  public static let ep158_saferConciserForms = Episode(
    blurb: """
Previously we explored how SwiftUI makes building forms a snap, and we contrasted it with the boilerplate introduced by the Composable Architecture. We employed a number of advanced tools to close the gap, but we can do better! We’ll start by using a property wrapper to make things much safer than before.
""",
    codeSampleDirectory: "0158-safer-conciser-forms-pt1",
    exercises: _exercises,
    id: 158,
    image: "https://i.vimeocdn.com/video/1228086408",
    length: 29*60 + 28,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1630299600),
    references: [
      reference(
        forSection: .conciseForms,
        additionalBlurb: "",
        sectionUrl: "https://www.pointfree.co/collections/case-studies/concise-forms"
      ),
      reference(
        forCollection: .composableArchitecture,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/composable-architecture"
      ),
    ],
    sequence: 158,
    subtitle: "Part 1",
    title: "Safer, Conciser Forms",
    trailerVideo: .init(
      bytesLength: 67284270,
      vimeoId: 592110963,
      vimeoSecret: "c8bde3dc086ad2fe9139106b21977c9c34b1777c"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Update the effectful notification logic in the vanilla SwiftUI view model to use async/await. As of this episode, Apple does not provide async/await APIs for the UserNotifications framework, so you will need to write your own helpers using tools like `withUnsafeContinuation` and `withUnsafeThrowingContinuation`.
"""#,
    solution: #"""
First we need to introduce some helpers on `UNNotificationCenter`:

```swift
extension UNUserNotificationCenter {
  var notificationSettings: UNNotificationSettings {
    get async {
      await withUnsafeContinuation { continuation in
        self.getNotificationSettings { notificationSettings in
          continuation.resume(with: .success(notificationSettings))
        }
      }
    }
  }

  func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
    try await withUnsafeThrowingContinuation { continuation in
      self.requestAuthorization(options: options) { granted, error in
        if let error = error {
          continuation.resume(with: .failure(error))
        } else {
          continuation.resume(with: .success(granted))
        }
      }
    }
  }
}
```

With these in place, we can simplify `attemptToggleSendNotifications`:

```swift
@MainActor
func attemptToggleSendNotifications(isOn: Bool) async {
  guard isOn else {
    self.sendNotifications = false
    return
  }

  let settings = await UNUserNotificationCenter.current().notificationSettings
  guard settings.authorizationStatus != .denied
  else {
    self.alert = .init(title: "You need to enable permissions from iOS settings")
    return
  }

  withAnimation {
    self.sendNotifications = true
  }
  let granted =
    (try? await UNUserNotificationCenter.current().requestAuthorization(options: .alert))
    ?? false
  if !granted {
    withAnimation {
      self.sendNotifications = false
    }
  } else {
    UIApplication.shared.registerForRemoteNotifications()
  }
}
```

We:

* Upgrade the method to be `async`
* Use `@MainActor` to eliminate the `DispatchQueue.main.async` calls
* Make calls to the async helpers we just defined and eliminate a lot of nesting

Finally, in the view we can spin off a `Task`:

```swift
Toggle(
  "Send notifications",
  isOn: Binding(
    get: { self.viewModel.sendNotifications },
    set: { isOn in
      Task { await self.viewModel.attemptToggleSendNotifications(isOn: isOn) }
    }
  )
)
```
"""#
  ),
  .init(
    problem: #"""
Update the live `NotificationsClient`, a dependency used by the Composable Architecture version of the application, to use these new async helpers with `Effect.task`
"""#,
    solution: #"""
```swift
extension UserNotificationsClient {
  static let live = Self(
    getNotificationSettings: {
      .task {
        .init(rawValue: await UNUserNotificationCenter.current().notificationSettings)
      }
    },
    registerForRemoteNotifications: {
      .fireAndForget {
        UIApplication.shared.registerForRemoteNotifications()
      }
    },
    requestAuthorization: { options in
      .task {
        try await UNUserNotificationCenter.current().requestAuthorization(options: options)
      }
    }
  )
}
```
"""#
  )
]
