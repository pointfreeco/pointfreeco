The Apple community is one that largely values 1st party libraries and frameworks, and typically
shuns 3rd party. While Apple does build incredible tools, the yearly or semi-yearly release cycle
and opaque feedback channels can start to weigh on a developer's experience.

One of the benefits to maintaing open source software is the abililty for us to easily gather
feedback from people and act on that feedback quickly. This happens on a weekly basis in the dozens
of open source libraries we maintain, but we wanted to highlight two recent occurences that stem
from our [SQLiteData] libray.

[SQLiteData]: http://github.com/pointfreeco/sqlite-data 

## New feature: Customizable iCloud logout behavior

With the first release of SQLiteData we baked in some behavior that we felt was safe as a default,
but ultimately turned out to be a bit restrictive. For example, when the [`SyncEngine`] detects
that the iCloud account on the device logs out or switches accounts, we take the precaution to 
delete all local data. After all, most likely the data belongs to the user that just
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

## Bug fixes: Sharing iCloud records

Our popular [SQLiteData] library not only makes it easy to synchronize your user's data across
all of their devices, but it also makes it easy for them to share a record (and all associated
records) with other iCloud users for collaboration. This took a great amount of effort to support,
and was one of the most complex features we worked on for the library.

However, shortly after releasing the library a member of our community brought up an issue in our
[Slack] community. It seems that sharing a record worked fine the first time, but then sharing
the record again would sometimes fail to generate a share link and produce an error.

Thanks to our extensive [test suite] for the iCloud synchronization tools we were able to write
a [failing test] quite quickly. It turns out the problem was due to us saving the record being 
shared to CloudKit (a requirement to create `CKShare`s), which in turn updates the record's 
'internal [`recordChangeTag`] used to determine whether the server and client records differ. 
However, we did not update our locally cached server record with this newly updated record, which
means if you try sharing again it, CloudKit will see the mismatched `recordChangeTag`s and reject
the operation.

Luckily [the fix] was quite simple. We just needed to make sure to 
[cache the freshest server record] we receive after creating the `CKShare` in CloudKit. With that
small change everything works exactly as expected, and our test passes. Less than 5 hours after
the report of this bug we had opened a pull request and merged it into `main`.  

![](https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/259bd04f-870b-407d-0051-a2a845fbf100/public)

[cache the freshest server record]: https://github.com/pointfreeco/sqlite-data/pull/259/files#diff-e4abd0f68cc100e2f568a99f42e683074f3df6e0515fc914be9997497d069da2R209
[`recordChangeTag`]: https://developer.apple.com/documentation/cloudkit/ckrecord/recordchangetag
[Slack]: http://pointfree.co/slack-invite
[the fix]: https://github.com/pointfreeco/sqlite-data/pull/259
[test suite]: https://github.com/pointfreeco/sqlite-data/tree/main/Tests/SQLiteDataTests/CloudKitTests
[failing test]: https://github.com/pointfreeco/sqlite-data/blob/f6c72114e6ba9df1f5cefcd8b0590d86982a92f6/Tests/SQLiteDataTests/CloudKitTests/SharingTests.swift#L648

## Can you trust 3rd party libraries?

While we understand that many in the Apple community have an ingrained distaste for 3rd party 
libraries and full trust of Apple's frameworks, we hope that everyone can see there is a clear 
benefit to using libraries with active and engaged maintainers. We were able to implement and
release a user requested feature in less than a week, and fix a bug in just a few hours. No need
to wait for WWDC or hope for a new Xcode release and pray that the new feature or bug fix
doesn't require a bump in your minimum deployment target.

And if you are interested in a SwiftData alternative that gives you direct access to SQLite,
seamlessly integrates with iCloud synchronization, and allows your users to share their data
with other iCloud users, then be sure to check out [SQLiteData]. 
