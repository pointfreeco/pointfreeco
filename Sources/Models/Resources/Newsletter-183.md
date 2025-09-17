We are excited to release version [0.7.0] of our powerful persistence library, [SQLiteData]. It
introduces all new tools for bringing user-defined functions to SQLite.

[0.7.0]: https://github.com/pointfreeco/sqlite-data/releases/0.7.0
[SQLiteData]: https://github.com/pointfreeco/sqlite-data

## `@DatabaseFunction`

SQLiteData now allows you to define Swift functions that can be called from SQLite _via_ its
powerful query builder. Simply annotate a function using the new `@DatabaseFunction` macro:

```swift
@DatabaseFunction
func exclaim(_ string: String) -> String {
  string.localizedUppercase + "!"
}
```

And you will immediately be able to invoke it from a query by prefixing it with `$`:

```swift
Reminder.select { $exclaim($0.title) }
// SELECT "exclaim"("reminders"."title") FROM "reminders"
```

This gives you full access to everything Swift has to offer, such as the `localizedUppercase`
property, in your SQL queries.

It is also possible for your database functions to accept arguments that are encoded from the
database into first-class Swift data types. This is a pattern we use extensively in our 
upcoming [CloudKit synchronization][cloudkit-beta] tools. When a write is made to the database
we invoke a Swift function so that we can synchronize that change to CloudKit, and in order to
do that we need to pass a `CKRecord` from the database (stored as a binary BLOB) to our
Swift function:   

```swift
@DatabaseFunction(as: ((CKRecord.SystemFieldsRepresentation) -> Void).self)
func didUpdate(record: CKRecord) {
  // Synchronize 'CKRecord' to CloudKit
}
```

The conversion happens seamlessly behind the scenes without you having to perform additional work.

However, before you can make use of these Swift functions from SQLite, the function must be added 
to a SQLite connection at runtime. This is typically done when you first configure your database. 
For example:

```swift
var configuration = Configuration()
configuration.prepareDatabase { db in
  db.add(function: $exclaim)
}
```

You can configure a `@DatabaseFunction` with a custom name much like you can configure `@Table`
names and `@Column` names:

```swift
@DatabaseFunction("did_update")
func didUpdate(…) { … }
```

And you can tell SQLite when a function is "deterministic": that is, it always returns the same
value from the same arguments. SQLite's query planner can optimize such functions, and they are
allowed to be [used][non-deterministic-restrictions] in `CHECK` constraints, partial indices, and
generated columns.

```swift
@DatabaseFunction(isDeterministic: true)
func exclaim(_ string: String) -> String {
  string.localizedUppercase + "!"
}
```

[non-deterministic-restrictions]: https://sqlite.org/deterministic.html#restrictions_on_the_use_of_non_deterministic_functions

## Try it out today!

[SQLiteData] 0.7.0 is available today! We hope you'll take these new features for a spin. And we
have more improvements and refinements coming soon, including support for
[CloudKit synchronization and sharing]

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[CloudKit synchronization and sharing]: /blog/posts/181-a-swiftdata-alternative-with-sqlite-cloudkit-public-beta
[cloudkit-beta]: /blog/posts/181-a-swiftdata-alternative-with-sqlite-cloudkit-public-beta
