One of the benefits to maintaing open source software is the abililty for us to easily gather
feedback from people and act on that feedback quickly. This happens on a weekly basis in the dozens
of open source libraries we maintain, but we wanted to highlight two recent occurences that stem
from our [SQLiteData] libray.

[SQLiteData]: http://github.com/pointfreeco/sqlite-data 

## New feature: Customizable iCloud logout behavior

With the first release of SQLiteData we baked in some behavior that we felt was safe as a default,
but ultimately turned out to be a bit restrictive. For example, when the [`SyncEngine`] detects
that the iCloud account on the device logs out or switches accounts, we take the precaution to 
automatically delete all local data. After all, most likely the data belongs to the user that just
logged out, and so it's probably not appropriate to keep that data around for the next iCloud user.

[`SyncEngine`]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/syncengine 

However, this is not alwasy the most appropriate behavior for an app. A member of our community 
raised a [discussion] to ask if this default behavior could be altered. Even some of Apple's 
first party apps ask the user whether or not they want to clear local data when they detect the
iCloud account has changed.

[discussion]: https://github.com/pointfreeco/sqlite-data/discussions/218

We were ultimately convinced that we were being overly restrictive with our default behavior,
and so a few weeks later decided to make it customizable in this [pull request]. It adds a new 
`SyncEngineDelegate` protocol that can be used to be notified of certain events in the `SyncEngine` 
and customize its behavior. In particular, you can listen for the `syncEngine(_:accountChanged:)` 
event to determine how you want to handle local data.

[pull request]: https://github.com/pointfreeco/sqlite-data/pull/261

We also [updated] our Reminders demo app in the repo to make use of this new functionality. At the
entry point of the app we define an `@Observable` model that also conforms to `SyncEngineDelegate`.
When this object detects that the current iCloud account either logged out or switched accounts,
it updates a boolean that can be used to drive an alert:

[updated]: https://github.com/pointfreeco/sqlite-data/blob/22cb3a5260d127b80cb263f580ad7b6fbfd04493/Examples/Reminders/RemindersApp.swift#L54-L71

```swift
MainActor
@Observable
class RemindersSyncEngineDelegate: SyncEngineDelegate {
  var isDeleteLocalDataAlertPresented = false
  func syncEngine(
    _ syncEngine: SQLiteData.SyncEngine,
    accountChanged changeType: CKSyncEngine.Event.AccountChange.ChangeType
  ) async {
    switch changeType {
    case .signIn:
      break
    case .signOut, .switchAccounts:
      isDeleteLocalDataAlertPresented = true
    @unknown default:
      break
    }
  }
}
```

And then the view can use this state to determine when it presents an alert to the user asking
them if they want to reset their local data or not:

```swift
.alert(
  "Reset local data?",
  isPresented: $syncEngineDelegate.isDeleteLocalDataAlertPresented
) {
  Button("Reset", role: .destructive) {
    Task {
      try await syncEngine.deleteLocalData()
    }
  }
} message: {
  Text(
    """
    You are no longer logged into iCloud. Would you like to reset your local data to the \
    defaults? This will not affect your data in iCloud.
    """
  )
}
```

This is a great feature for the library to have, and we are glad that someone from the community
advocated for it so that we can take the time to implement it. And this is exactly why we enjoy
building our libraries in the open.  

## Immedate bug fixes

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/259bd04f-870b-407d-0051-a2a845fbf100/public)


