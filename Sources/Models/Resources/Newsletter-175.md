WWDC25 has come and gone, and unfortunately there were very few new features brought to SwiftData, 
which is Apple’s answer for a modern persistence framework on its platforms. Luckily SwiftData is 
already quite powerful, and so perhaps it doesn’t need many updates right now, and most likely Apple 
has big plans for SwiftData in the future.

But we feel that the future can be sooner rather than later. We are working on a major update to 
our popular [SQLite persistence library](http://github.com/pointfreeco/sharing-grdb) that brings 
seamless CloudKit synchronization and more. To give a sneak peek to these tools, and to demonstrate 
our vision for [modern persistence](/collections/modern-persistence) on Apple's platforms, we are 
hosting a live stream on June 25th at 9am PDT (5pm GTM). Be sure to tune in!

@Button(/live) {
  Watch June 25 @ 9am PDT (4pm GMT)
}

## SQLite and CloudKit synchronization

During the live stream we will be giving a sneak peek of some powerful upcoming tools that bring
seamless CloudKit sharing to applications using SQLite for its data persistence. For 
most<sup>*</sup> applications, setting up synchronization will be as simple as configuring a 
sync engine in the entry point of the app:

```swift
try! prepareDependencies {
  $0.defaultDatabase = try appDatabase()
  $0.defaultSyncEngine = try SyncEngine(
    container: CKContainer(
      identifier: "iCloud.co.pointfree.Reminders"
    ),
    database: $0.defaultDatabase,
    tables: [
      RemindersList.self,
      Reminder.self,
    ]
  )
}
```

Once that is done, all rows in the `RemindersList` and `Reminder` tables will be synchronized to
CloudKit so that the data is available on the user's devices.

> Note: Distributed schemas bring many complications to an app, and so there will be a few
> reasonable restrictions placed on what kinds of schemas can be synchronized to CloudKit.
> In most situations one can easily migrate their schemas to make them compatible with 
> synchronization.

Further, sharing data with other iCloud users is also supported. To share a record with another user 
one must first create a `CKShare`. Our library provides a method on `SyncEngine` for generating a 
`CKShare` for a record, and that value can be stored in a view to drive a sheet to display a 
`UICloudSharingController`:

```swift
struct RemindersListView: View {
  let remindersList: RemindersList 
  @State var sharedRecord: SharedRecord?

  var body: some View {
    Form {
      …
    }
    .toolbar {
      Button("Share") {
        Task {
          await withErrorReporting {
            sharedRecord = try await syncEngine.share(record: remindersList) { share in
              share[CKShare.SystemFieldKey.title] = "Join '\(remindersList.title)!'"
            }
          }
        }
      }
    }
    .sheet(item: $sharedRecord) { sharedRecord in
      CloudSharingView(sharedRecord: sharedRecord)
    }
  }
}
```

This will share a reminders list with another user, as well as all reminders belonging to that list.
When either user creates, edits, or deletes a reminder, all other users will automatically 
synchronize those changes.

> Note: Just as distributed schemas introduce many complications to an app, sharing data introduces
> even more. There are a few more restrictions placed on the kinds of records that can be
> shared with other users.

## Live stream June 25th, 2025

We think everyone is going to be blown away with what we have to share. We also think everyone
is going to have _a lot_ of questions, and in order to best prioritize Q&A during the live stream
we highly recommend submitting your questions early. Q&A is already open on our live stream page:

@Button(/live) {
  Watch June 25 @ 9am PDT (4pm GMT)
}

Be sure to tune in!
