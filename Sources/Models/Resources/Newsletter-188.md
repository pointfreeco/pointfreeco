It is now possible to use simple Swift functions to aggregate data in your SQLite database queries.
This can unlock all new super powers in querying by writing complex logic directly in Swift rather
than contorting SQL to do strange things.

As an example, consider computing the [mode](https://en.wikipedia.org/wiki/Mode_(statistics)) of a 
column in a table. Say we have a reminders table with a priority, and each reminder belongs to
a reminders list:

```swift
@Table struct RemindersList {
  let id: UUID
  var title = ""
}

@Table struct Reminder {
  let id: UUID
  var title = ""
  var priority: Priority?
  var remindersListID: RemindersList.ID
  
  enum Priority: Int, QueryBindable { case low, medium, high }
}
```

We would like to compute the mode of the priority across all reminders for each list, _i.e._ compute 
the most common priority that is assigned to all reminders belonging to a particular list. And 
further we would like to ignore any `NULL` values from this computation.

Unfortunately SQLite does not have a `mode` function that can easily compute this for us. We
need to perform the computation ourselves using subqueries, and the raw SQL is quite complex: 

```sql
SELECT 
  remindersLists.title,
  (
    SELECT reminders.priority
    FROM reminders
    WHERE reminders.remindersListID = remindersLists.id
      AND reminders.priority IS NOT NULL
    GROUP BY reminders.priority
    ORDER BY count(*) DESC
    LIMIT 1
  )
FROM remindersLists;
```

Things get even more complex if you want to perform additional logic with the mode, such as 
filter out lists whose priority mode is less than `.medium` priority.

Luckily for us there is a better way. SQLite supports defining custom aggregate functions so that
you can be in control with how many rows of data are aggregated into a single value. And our 
library, [StructuredQueries], provides a way to define custom aggregate functions as if they
were simple Swift functions.

[StructuredQueries]: http://github.com/pointfreeco/swift-structured-queries

 If we were to define a function that can can compute the mode of priorities in Swift, we may
 naively attempt it like this: 

```swift
func mode(priority priorities: some Sequence<Priority?>) -> Priority? {
  var occurrences: [Priority: Int] = [:]
  for priority in priorities {
    guard let priority
    else { continue }
    occurrences[priority, default: 0] += 1
  }
  return occurrences.max { $0.value < $1.value }?.key
}
```

It's a function that takes some sequence of optional priorities and it returns the mode of all
of those priorities. It does so by constructing a dictionary mapping a priority to the number
of its occurrences in the sequence before finally returning the maximum value in that dictionary.

And this naive function can be invoked directly from a SQLite query, as long as you first annotate
the function with the `@DatabaseFunction` macro:

```diff
+@DatabaseFunction
 func mode(priority priorities: some Sequence<Priority?>) -> Priority? {
   …
 }
```

And as long as you further add this function to your database connection, which typically happens
when first creating your database connection:

```swift
var configuration = Configuration()
configuration.prepareDatabase { db in
  db.add(function: $mode)
}
```

Once that is done you can write the messy SQL query above in a much simpler, type-safe and
schema-safe fashion:

```swift
RemindersList
  .group(by: \.id)
  .leftJoin(Reminder.all) { $0.id.eq($1.remindersListID) }
  .select { ($0.title, $mode(priority: $1.priority)) }
```

The `$mode` function is created by the `@DatabaseFunction` macro and it allows you to invoke
Swift code directly from a SQL query.


## Try it out today!

Update [SQLiteData] and [StructuredQueries] today to get access to these new tools.

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
