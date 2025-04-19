Today we are releasing a significant update to our [SharingGRDB][] library that offers a fast,
ergonomic, and lightweight replacement for SwiftData, powered by SQL. It provides APIs similar to
`@Model`, `@Query`, and `#Predicate`, but is tuned for direct access to the underlying database
(something that SwiftData abstracts away), giving you more power, flexibility, and performance in 
how you persist and fetch data in your application.

[SharingGRDB]: https://github.com/pointfreeco/sharing-grdb

## The `@Table` macro

The library leverages a new `@Table` macro, which unlocks a rich, type-safe query building language,
as well as a high-performance decoder for turning database primitives into first-class Swift data
types. It serves a similar purpose to and syntax of SwiftData's `@Model` macro:

<table>
<tr>
<th>SharingGRDB</th>
<th>SwiftData</th>
</tr>
<tr valign=top>
<td width=50%>
      
```swift
@Table
struct Reminder {
  let id: Int
  var title = ""
  var isCompleted = false
}
```

</td>
<td width=50%>

```swift
@Model
class Reminder {
  var title: String
  var isCompleted: Bool
  init(
    title: String = "",
    isCompleted: Bool = false
  ) {
    self.title = title
    self.isCompleted = isCompleted
  }
}
```

</td>
</tr>
</table>

Some key differences:

  * The `@Table` macro works with struct data types, whereas `@Model` only works with classes.
  * Because the `@Model` version of `Reminder` is a class it is necessary to provide an initializer.
  * The `@Model` version of `Reminder` does not need an `id` field because SwiftData provides a
    `persistentIdentifier` to each model.
    
With `@Table` applied, `Reminder` gets instant access to a rich set of query building APIs that allow
you to construct various queries using expressive Swift, similar to how SwiftData leverages
`#Predicate` and key paths in the `@Query` macro:
 
<table>
<tr>
<th>SharingGRDB</th>
<th>SwiftData</th>
</tr>
<tr valign=top>
<td width=50%>

```swift
@SharedReader(
  .fetchAll(
    Reminder.where {
      $0.title.contains("get")
        && !$0.isCompleted
    }
    .order(by: \.title)
  )
)
var reminders
```

</td>
<td width=50%>

```swift
@Query(
  filter: #Predicate<Reminder> {
    $0.name.contains("get")
      && $0.isCompleted
  },
  sort: \Reminder.name
)
var reminders: [Reminder]
```

</td>
</tr>
</table>

Both of the above examples fetch items from an external data store using Swift data types, and both
are automatically observed by SwiftUI so that views are recomputed when the external data changes,
but SharingGRDB is [usable outside of the view][observing-changes-article]: in `@Observable` 
models, UIKit view controllers, and more.

[observing-changes-article]: https://swiftpackageindex.com/pointfreeco/sharing-grdb/main/documentation/sharinggrdb/observing

Note that our query builder maps to syntactically valid SQL, so you can have confidence it will work
at compile time. Meanwhile, `#Predicate` can be wielded in ways that at best produce cryptic compile
time errors, and at worst crash at runtime.

For example, using a computed property rather than a stored property in a query is a compiler 
error in SharingGRDB, but a runtime crash in SwiftData:

<table>
<tr>
<th>SharingGRDB</th>
<th>SwiftData</th>
</tr>
<tr valign=top>
<td width=50%>

```swift:4-5
@SharedReader(
  .fetchAll(
    Reminder.where {
      // 🛑 'Reminder.Columns' has no
      //     member 'isNotCompleted'
      $0.isNotCompleted
    }
    .order(by: \.title)
  )
)
var reminders
```

</td>
<td width=50%>

```swift:3-4
@Query(
  filter: #Predicate<Reminder> {
    // 💥 Fatal error: Couldn't find 
    //    'isNotCompleted' on Reminder
    $0.isNotCompleted
  },
  sort: \Reminder.name
)
var reminders: [Reminder]
```

</td>
</tr>
</table>

Our query builder also exposes the full range of SQL directly to you, while SwiftData hides these
details from you, instead providing its own query building language that can only perform a subset
of the tasks that SQL can do.

<!-- TODO: Insert/Update/Delete examples/comparisons -->

## Safe SQL strings

It is also possible to write SQL directly as a string using the new `#sql` macro, but still in a
safe manner. This can be useful for writing complex queries that may not be possible or easy to
write with the query builder of this library.

> Important: Although `#sql` gives you the ability to write hand-crafted SQL strings, it still
> protects you from SQL injection, and you can still make use of the table definition data available
> from your data type.

As a simple example, one can select the titles from all reminders like so:

```swift
@SharedReader(
  #sql("SELECT title FROM reminders", as: String.self)
)
var reminderTitles
```

It is also possible to retain some schema-safety while writing SQL as a string. You can use string
interpolation along with the static column properties that are defined on your table as well as the
type of the table itself:

```swift
@SharedReader(
  #sql("SELECT \(Reminder.title) FROM \(Reminder.self)", as: String.self)
)
var reminderTitles
```

This generates the same query as before, but now you have more static safety in referring to the 
column names and table names of your types.

You can even select all columns from the reminders table by using the ``Table/columns`` static
property:

```swift
@SharedReader(
  #sql("SELECT \(Reminder.columns) FROM \(Reminder.self)", as: Reminder.self)
)
var reminders
```

Notice that this allows you to now decode the result into the full `Reminder` type.

See ["Safe SQL Strings"][safe-sql-article] for more information about the `#sql` macro.

[safe-sql-article]: https://swiftpackageindex.com/pointfreeco/swift-structured-queries/~/documentation/structuredqueriescore/safesqlstrings

## Performance

SharingGRDB leverages high-performance decoding to turn fetched data into your Swift domain types,
and has a performance profile similar to invoking SQLite's C APIs directly.

See the following benchmarks against
[Lighter's performance test suite](https://github.com/Lighter-swift/PerformanceTestSuite) for a
taste of how it compares:

```
Orders.fetchAll                          setup    rampup   duration
  SQLite (Enlighter-generated)           0        0.144    7.183
  Lighter (1.4.10)                       0        0.164    8.059
  SharingGRDB (0.2.0)                    0        0.172    8.511
  GRDB (7.4.1, manual decoding)          0        0.376    18.819
  SQLite.swift (0.15.3, manual decoding) 0        0.564    27.994
  SQLite.swift (0.15.3, Codable)         0        0.863    43.261
  GRDB (7.4.1, Codable)                  0.002    1.07     53.326
```

## Made possible by StructuredQueries

The reason we have been able to make great strides in the ergonomics and performance of SharingGRDB
is because of another library we are releasing today: [StructuredQueries][]. It provides a suite of 
tools that empower you to write safe, expressive, composable SQL with Swift, including the `@Table`
macro and its query building APIs, as well as the the `#sql` macro, all mentioned above.

By simply attaching its macros to types that represent your database schema:

```swift
@Table
struct Reminder {
  let id: Int
  var title = ""
  var isCompleted = false
  var priority: Int?
  @Column(as: Date.ISO8601Representation?.self)
  var dueDate: Date?
}
```

You get instant access to its rich set of query building APIs, from simple:

<table>
<tr>
<th>Swift</th>
<th>SQL</th>
</tr>
<tr valign=top>
<td width=415>

```swift
Reminder.all
// => [Reminder]
```

</td>
<td width=415>

```sql
SELECT
  "reminders"."id",
  "reminders"."title",
  "reminders"."isCompleted",
  "reminders"."priority",
  "reminders"."dueDate"
FROM "reminders"
```

</td>
</tr>
</table>

To complex:

<table>
<tr>
<th>Swift</th>
<th>SQL</th>
</tr>
<tr valign=top>
<td width=415>

```swift
Reminder
  .select {
     ($0.priority,
      $0.title.groupConcat())
  }
  .where { !$0.isCompleted }
  .group(by: \.priority)
  .order { $0.priority.desc() }
// => [(Int?, String)]
```

</td>
<td width=415>

```sql
SELECT
  "reminders"."priority",
  group_concat("reminders"."title")
FROM "reminders"
WHERE (NOT "reminders"."isCompleted")
GROUP BY "reminders"."priority"
ORDER BY "reminders"."priority" DESC
```

</td>
</tr>
</table>

Its APIs help you avoid runtime issues caused by typos and type errors, but still embrace SQL for
what it is. StructuredQueries is not an ORM or a new query language you have to learn: its APIs are
designed to read closely to the SQL it generates, though they are often more succinct, and always
safer.

The library supports building everything from `SELECT`, `INSERT`, `UPDATE`, and `DELETE` statements,
to recursive common table expressions. To learn more about building SQL with StructuredQueries,
check out the [documentation](https://swiftpackageindex.com/pointfreeco/swift-structured-queries/~/documentation/structuredqueriescore/).

And while StructuredQueries' release is tuned to SQLite and specifically its SharingGRDB driver, the
library is _general purpose_, and its query builder and decoder could interface with other databases
(MySQL, Postgres, _etc._) and database libraries.

If you are interested in building an integration of StructuredQueries with another database library,
please [start a discussion][] and let us know of any challenges you encounter.

[StructuredQueries]: http://github.com/pointfreeco/swift-structured-queries
[start a discussion](https://github.com/pointfreeco/swift-structured-queries/discussions/new/choose)

## Try it today!

The 0.2.0 release of SharingGRDB is out _today_! Give it a spin and let us know what you think. Or,
if you have any questions, start a 
[discussion](https://github.com/pointfreeco/sharing-grdb/discussions).
