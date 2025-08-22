We are excited to release version [0.6.0] of our powerful persistence library, [SharingGRDB]. It
introduces all new tools for bringing full-text search capabilities to your applications.

[0.6.0]: https://github.com/pointfreeco/sharing-grdb/releases/0.6.0
[SharingGRDB]: https://github.com/pointfreeco/sharing-grdb

## FTS5

Full-text search is a powerful technology provided by SQLite that can search large collections
of text efficiently and with advanced features, such as stemming, lemmatization and fuzzy matching.
[SharingGRDB] has now introduced a number of helpers for accessing this functionality via the 
[FTS5] module.

[FTS5]: https://www.sqlite.org/fts5.html

Defining a full-text search table in your application looks very similar to defining a regular
table. You can use the same `@Table` macro you use to define the rest of your schema, but you will
also conform the type to [StructuredQueries]' `FTS5` protocol:

[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries

```swift:2
@Table
struct ReminderText: StructuredQueries.FTS5 {
  let reminderID: Reminder.ID
  var title: String
  var notes: String
  var tags: String
}
```

You can add this table to your database with the method of your choosing. We like to use a
combination of [GRDB migrations] and [safe SQL strings]. For example:

[GRDB migrations]: https://swiftpackageindex.com/groue/GRDB.swift/v7.6.1/documentation/grdb/migrations
[safe SQL strings]: https://swiftpackageindex.com/pointfreeco/swift-structured-queries/0.13.0/documentation/structuredqueriescore/safesqlstrings

```swift
migrator.registerMigration("Add reminders FTS table") { db in
  #sql(
    """
    CREATE VIRTUAL TABLE "reminderTexts" USING fts5(
      "reminderID" UNINDEXED,
      "title",
      "notes",
      "tags",
      tokenize = 'trigram'
    )
    """
  )
  .execute(db)
  // Insert any existing data into the FTS table here.
}
```

The data held in this virtual table will be automatically processed and indexed so that it can
be efficiently searched. It is your responsibility to keep this FTS table up-to-date with the data 
it references. SQLite suggests triggers as one way to do this, and you can use our [type-safe APIs] 
to create them:

[type-safe APIs]: https://swiftpackageindex.com/pointfreeco/swift-structured-queries/0.13.0/documentation/structuredqueriescore/triggers

```swift
try Reminder.createTemporaryTrigger(after: .insert { new in
  ReminderText.insert {
    ($0.reminderID, $0.title, $0.notes, $0.tags)
  } values: {
    (new.id, new.title, new.notes, "")
  }
})
.execute(db)

// More triggers for when reminders are updated/deleted,
// and reminder tags are inserted/deleted.
```

> Tip: If you further annotate your FTS5 table with the `@Selection` macro, the insert trigger can
> exhaustively insert a row into the database using the generated `Columns` type:
>
> ```swift:1
> @Table @Selection
> struct ReminderText {
>   // ...
> }
>
> try Reminder.createTemporaryTrigger(after: .insert { new in
>   ReminderText.Columns(
>     reminderID: new.id,
>     title: new.title,
>     notes: new.notes,
>     tags: ""
>   )
> })
> .execute(db)
> ```

With your FTS5 table defined and data being inserted into it, you are ready to perform a search.
This starts with the `match` operation, which your table gets instant access to _via_ its
conformance to the `FTS5` protocol:

```swift
ReminderText.where { $0.match(query) }
// SELECT … FROM "reminderTexts"
// WHERE "reminderTexts" MATCH 'appointment'
```

That's all it takes to add full-text search to your SharingGRDB applications. But it also only
scratches the surface: the library also comes with helpers for ranking, highlighting, and even
generating truncated excerpts for your searches:

```swift
ReminderText
  .where { $0.match(query) }
  .order(by: \.rank)
  .select {
    SearchResult.Columns(
      title: $0.title.highlight("**", "**"),
      notes: $0.notes.snippet("**", "**", 20),
      tags: $0.tags.highlight("**", "**")
    )
  }
// SELECT
//   highlight("reminderTexts", 1, '**', '**'),
//   snippet("reminderTexts", 2, '**', '**', '...', 20),
//   highlight("reminderTexts", 3, '**', '**')
// FROM "reminderTexts"
// ORDER BY "reminderTexts"."rank"
```

Be sure to check out SQLite's [fantastic FTS5 documentation] for more information on how your data
can be indexed and search.

[fantastic FTS5 documentation]: https://www.sqlite.org/fts5.html

## Try it out today!

[SharingGRDB] 0.6.0 is available today! We hope you'll take these new features for a spin. And we
have more improvements and refinements coming soon, including support for
[CloudKit synchronization and sharing]

[SharingGRDB]: https://github.com/pointfreeco/sharing-grdb
[CloudKit synchronization and sharing]: /blog/posts/181-a-swiftdata-alternative-with-sqlite-cloudkit-public-beta
