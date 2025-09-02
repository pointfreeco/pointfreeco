We are excited to release version [0.7.0] of our powerful persistence library, [SharingGRDB]. It
introduces all new tools for bringing user-defined functions to SQLite.

[0.7.0]: https://github.com/pointfreeco/sharing-grdb/releases/0.7.0
[SharingGRDB]: https://github.com/pointfreeco/sharing-grdb

## `@DatabaseFunction`

SharingGRDB now allows you to define Swift functions that can be called from SQLite _via_ its
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

This function must be added to a SQLite connection before a query can successfully invoke it at
runtime. This is typically done when you first configure your database. For example:

```swift
var configuration = Configuration()
configuration.prepareDatabase { db in
  db.add(function: $exclaim)
}
```

> Tip: Use the `isDeterministic` parameter for functions that always return the same value from the
> same arguments. SQLite's query planner can optimize these functions.
>
> ```swift
> @DatabaseFunction(isDeterministic: true)
> func exclaim(_ string: String) -> String {
>   string.localizedUppercase + "!"
> }
> ```

## Try it out today!

[SharingGRDB] 0.7.0 is available today! We hope you'll take these new features for a spin. And we
have more improvements and refinements coming soon, including support for
[CloudKit synchronization and sharing]

[SharingGRDB]: https://github.com/pointfreeco/sharing-grdb
[CloudKit synchronization and sharing]: /blog/posts/181-a-swiftdata-alternative-with-sqlite-cloudkit-public-beta
