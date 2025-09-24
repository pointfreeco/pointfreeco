[SQLiteData] now has type-safe, schema-safe support for creating, querying, and updating database
views.

[SQLiteData]: https://github.com/pointfreeco/sqlite-data

## Database views

[Views](https://www.sqlite.org/lang_createview.html) are pre-packaged select statements that can
be queried like a table. StructuredQueries comes with tools to create _temporary_ views in a
type-safe and schema-safe fashion.

### Creating temporary views

To define a view into your database you must first define a Swift data type that holds the data
you want to query for. As a simple example, suppose we want a view into the database that selects
the title of each reminder, along with the title of each list, we can model this as a simple
Swift struct:

```swift
@Table @Selection
private struct ReminderWithList {
  let reminderTitle: String
  let remindersListTitle: String
}
```

Note that we have applied both the `@Table` macro and `@Selection` macro. This is similar to what
one does with [common table expressions], and it allows one to represent a type that for intents and
purposes seems like a regular SQLite table, but it's not actually persisted in the database.

[common table expressions]: https://swiftpackageindex.com/pointfreeco/swift-structured-queries/main/documentation/structuredqueriescore/commontableexpressions

With that type defined we can use the `createTemporaryView` function to create a SQL query that
creates a temporary view. You provide a select statement that selects all the data needed for the
view:

<table>
<tr valign=top>
<td width=50%>

```swift
ReminderWithList.createTemporaryView(
  as: Reminder
    .join(RemindersList.all) { 
      $0.remindersListID.eq($1.id) 
    }
    .select {
      ReminderWithList.Columns(
        reminderTitle: $0.title,
        remindersListTitle: $1.title
      )
    }
)  
```

</td>
<td width=50%>

```sql
CREATE TEMPORARY VIEW "reminderWithLists"
("reminderTitle", "remindersListTitle")
AS
SELECT
  "reminders"."title",
  "remindersLists"."title"
FROM "reminders"
JOIN "remindersLists"
  ON "reminders"."remindersListID" 
    = "remindersLists"."id"
    
    
```

</td>
</tr>
</table>

Once that is executed in your database you are free to query from this table as if it is a regular
table:

<table>
<tr valign=top>
<td width=50%>

```swift
ReminderWithList
  .order {
    ($0.remindersListTitle,
     $0.reminderTitle)
  }
  .limit(3)
  
  
```

</td>
<td width=50%>

```sql
SELECT
  "reminderWithLists"."reminderTitle",
  "reminderWithLists"."remindersListTitle"
FROM "reminderWithLists"
ORDER BY
  "reminderWithLists"."remindersListTitle",
  "reminderWithLists"."reminderTitle"
LIMIT 3
```

</td>
</tr>
</table>

The best part of this is that the `JOIN` used in the view is completely hidden from us. For all
intents and purposes, `ReminderWithList` seems like a regular SQL table for which each row holds
just two strings. We can simply query from the table to get that data in whatever way we want.

### Inserting, updating, and delete rows from views

The other querying tools of SQL do not immediately work because they are not real tables. For
example if you try to insert into `ReminderWithList` you will be met with a SQL error:

```swift
ReminderWithList.insert {
  ReminderWithList(
    reminderTitle: "Morning sync",
    remindersListTitle: "Business"
  )
}
// 🛑 cannot modify reminderWithLists because it is a view
```

However, it is possible to restore inserts if you can describe how inserting a `(String, String)`
pair into the table ultimately re-routes to inserts into your actual, non-view tables. The logic
for rerouting inserts is highly specific to the situation at hand, and there can be multiple
reasonable ways to do it for a particular view. For example, upon inserting into `ReminderWithList`
we could try first creating a new list with the title, and then use that new list to insert a new
reminder with the title. Or, we could decide that we will not allow creating a new list, and
instead we will just find an existing list with the title, and if we cannot then we fail the query.

In order to demonstrate this technique, we will use the latter rerouting logic: when a
`(String, String)` is inserted into `ReminderWithList` we will only create a new reminder with
the title specified, and we will only find an existing reminders list (if one exists) for the title
specified. And to implement this rerouting logic, one uses a [temporary trigger] on the view with an
`INSTEAD OF` clause, which allows you to reroute any inserts on the view into some other table:

[temporary trigger]: /blog/posts/176-type-safe-schema-safe-sql-triggers-in-swift

```swift
ReminderWithList.createTemporaryTrigger(
  insteadOf: .insert { new in
    Reminder.insert {
      ($0.title, $0.remindersListID)
    } values: {
      (
        new.reminderTitle,
        RemindersList
          .select(\.id)
          .where { $0.title.eq(new.remindersListTitle) }
      )
    }
  }
)
```

After you have installed this trigger into your database you are allowed to insert rows into the
view:

```swift
ReminderWithList.insert {
  ReminderWithList(
    reminderTitle: "Morning sync",
    remindersListTitle: "Business"
  )
}
```

## Try it out today!

These features come to [SQLiteData] _via_ its dependency on [StructuredQueries] [0.20.0]. We hope
you'll take these new features for a spin!

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries
[0.20.0]: https://github.com/pointfreeco/swift-structured-queries/release/0.20.0
