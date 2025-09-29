[SQLiteData] has powerful new tools for composing your schema's Swift data types, including column
groupings, enum tables, and more.

[SQLiteData]: https://github.com/pointfreeco/sqlite-data

## `@Table` and `@Selection`

SQLiteData has always employed powerful macros for querying and decoding data from SQLite using
Swift's type system.

For example, the `@Table` macro can be applied to a struct representing a database table, with a
property for each column of the table:

```swift
@Table
struct Reminder {
  let id: UUID
  var title = ""
  var isCompleted = false
  let createdAt: Date
  var updatedAt: Date
}

Reminder
  .where(\.isCompleted)
  .order(by: \.title)
// SELECT "reminders"."id", "reminders"."title", …
// FROM "reminders"
// WHERE "reminders"."isCompleted"
// ORDER BY "reminders"."title"
```

It instantly unlocks rich, type-safe and schema-safe ways of building SQL queries and decoding
their results into first-class Swift data types.

Meanwhile, the `@Selection` macro allows you to hone the results of a query. You apply it to a
struct representing a particular query's columns:

```swift
@Selection
struct Row {
  let title: String
  let isCompleted: Bool
}

Reminder.select {
  Row.Columns(title: $0.title, isCompleted: $0.isCompleted)
}
// SELECT "reminders"."title", "reminders"."isCompleted"
// FROM "reminders"
```

These macros have been significantly beefed up to better interact with one another and compose.

## Column groupings

First, the `@Selection` macro can now be used to group a table's columns together into nested data
types:

```swift
@Selection
struct Timestamps {
  let createdAt: Date
  var updatedAt: Date
}

@Table
struct Reminder {
  let id: UUID
  var title = ""
  var isCompleted = false
  var timestamps: Timestamps
}
```

These column groupings can be nested arbitrarily, and you have complete control over the how "flat"
column data from SQLite is bundled into your Swift data types.

You can also use `@Selection` to define _composite_ primary keys:

```
@Table
struct Enrollment: Identifiable {
  @Selection
  struct ID: Hashable {
    let courseID: Course.ID
    let studentID: Student.ID
  }

  let id: ID
  var date: Date
}
```

## Enum tables and selections

It is also now possible to define your tables in terms of enums and their associated values. By
enabling a package trait you can combine the [Case Paths] macro with `@Table` or `@Selection` to
generate types that can decode table rows into enum values:

```swift
@Table
struct Post {
  let id: UUID
  let item: Item

  @CasePathable
  @Selection
  enum Item {
    case link(URL)
    case note(Note)
    case photo(Photo)
    case video(Video)
  }
}
```

@Comment {
## More powerful database functions

TODO
}

## Try it out today!

These features come to [SQLiteData] _via_ its dependency on [StructuredQueries] [0.21.0]. We hope
you'll take these new features for a spin!

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries
[0.21.0]: https://github.com/pointfreeco/swift-structured-queries/release/0.21.0
