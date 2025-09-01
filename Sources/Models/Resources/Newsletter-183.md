We are excited to release version [0.7.0] of our powerful persistence library, [SharingGRDB]. It
introduces all new tools for bringing user-defined functions to SQLite.

[0.7.0]: https://github.com/pointfreeco/sharing-grdb/releases/0.7.0
[SharingGRDB]: https://github.com/pointfreeco/sharing-grdb

## `@DatabaseFunction`

SharingGRDB now allows you to define Swift functions that can be called from SQLite _via_ its
powerful query builder. Simply annotate a function using the new `@DatabaseFunction` macro:

```swift
@DatabaseFunction
func uuid() -> UUID {
  UUID()  // TODO: Control with a dependency for tests
}
```

And you will immediately be able to invoke it from a query by prefixing it with `$`:

```swift
Reminder.insert {
  ($0.id, $0.title)
} values: {
  ($uuid(), "Take boxes to thrift shop")
}
// INSERT INTO "reminders" ("id", "title")
// VALUES ("uuid"(), 'Take boxes to thrift shop')
```

This function must be added to a SQLite connection before a query can successfully invoke it at
runtime. This is typically done when you first configure your database. For example:

```swift
var configuration = Configuration()
configuration.prepareDatabase { db in
  db.add(function: $uuid)
}
```

## Try it out today!

[SharingGRDB] 0.7.0 is available today! We hope you'll take these new features for a spin. And we
have more improvements and refinements coming soon, including support for
[CloudKit synchronization and sharing]

[SharingGRDB]: https://github.com/pointfreeco/sharing-grdb
[CloudKit synchronization and sharing]: /blog/posts/181-a-swiftdata-alternative-with-sqlite-cloudkit-public-beta
