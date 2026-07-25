Today we are releasing [1.8.0] of [SQLiteData], our SwiftData alternative built directly on top of
SQLite. It comes with a brand new tool for grouping the results of a query into sections in a single
line of code.

[1.8.0]: https://github.com/pointfreeco/sqlite-data/releases/1.8.0
[SQLiteData]: https://github.com/pointfreeco/sqlite-data

## Sectioning in one line

Suppose you have a table of reminders with an optional category:

```swift
@Table struct Reminder {
  let id: UUID
  var title = ""
  var category: String?
  var dueDate: Date?
  var remindersListID: RemindersList.ID
}
```

If you want to display all reminders in a list, grouped into a section for each category, you can
provide a `sectionBy:` argument to `@FetchAll`:

```swift
@FetchAll(Reminder.order(by: \.title), sectionBy: \.category)
var reminders
```

In the view, the projected value of the property has a `sections` property that can be iterated over
to display each section:

```swift
List {
  ForEach($reminders.sections) { section in
    Section(section.name ?? "Uncategorized") {
      ForEach(section) { reminder in
        Text(reminder.title)
      }
    }
  }
}
```

Each `section` itself can be iterated over, and has a `name` describing the section.

That is all it takes, and it looks quite similar to the `sectionBy:` argument that SwiftData's
`@Query` macro recently gained for WWDC26. But this is where the similarities end. SwiftData's
sectioning is restricted to key paths of string properties on your model, whereas SQLiteData's
`sectionBy:` accepts _any_ SQL expression, which unlocks a whole lot more.

## Sectioning by anything

The `sectionBy:` argument is not just a key path. It's a closure handed the schema of the table
being queried, and so you can section by any string expression you can dream up. For example, if
you want to section reminders alphabetically by the first letter of their title, the prototypical
example of grouping used by the Contacts app, you can invoke SQLite's `substr` function directly:

```swift
@FetchAll(
  Reminder.order(by: \.title),
  sectionBy: { $0.title.substr(1, 1) }
)
var reminders
```

Or you can section by data that isn't stored in any column at all, such as whether or not a reminder
has been scheduled:

```swift
@FetchAll(
  Reminder.order(by: \.title),
  sectionBy: {
    Case()
      .when($0.dueDate.isNot(nil), then: "Scheduled")
      .else("Unscheduled")
  }
)
var reminders
```

Sections are ordered by the expression you provide, and that expression can be given an explicit
ordering. So if you want your sections to appear in reverse, or want to control where `NULL` values
land:

```swift
@FetchAll(
  Reminder.order(by: \.title),
  sectionBy: { $0.category.desc(nulls: .last) }
)
var reminders
```

None of this is possible with SwiftData: sections are always ordered alphabetically, in an ascending
fashion, by a stored string property.

## Sectioning by relationships

Sectioning is not restricted to data in the table being queried. Because you have the full power of
SQL at your disposal, including joins, you can section rows by data held in _other_ tables.

For example, if you want to display all reminders, grouped by the title of the list they belong to,
you can join the `RemindersList` table to the query:

```swift
@FetchAll(
  Reminder
    .order(by: \.title)
    .join(RemindersList.all) { $0.remindersListID.eq($1.id) }
    .select { reminder, _ in reminder },
  sectionBy: { _, remindersList in remindersList.title }
)
var reminders
```

The `sectionBy:` closure is handed the schema of every table in the join, and so sectioning by the
list's title is as simple as reaching for it.

## Dynamic sectioning

Sectioning is often something you give your users control over, and so it must be dynamic. The
`sectionBy:` argument is also available on the `load` method of `@FetchAll`'s projected value, which
means you can reload a query with brand new sectioning at any time.

Suppose your feature holds onto some state describing how the user wants their reminders grouped:

```swift
enum GroupOption { case none, category, titleFirstLetter }

@State var group = GroupOption.none
```

Then you can load a new query whenever that state changes:

```swift
.task(id: group) {
  await withErrorReporting {
    try await $reminders.load(
      Reminder.order(by: \.title),
      sectionBy: {
        switch group {
        case .none: nil
        case .category: $0.category
        case .titleFirstLetter: $0.title.substr(1, 1)
        }
      },
      animation: .default
    )
  }
}
```

The `sectionBy:` closure is a builder context, and so you are free to use `if` and `switch`
statements to decide how results should be grouped, and even return `nil` to turn sectioning off
entirely.

When sectioning is turned off, the `sections` collection is populated with a single, unnamed section
holding every row. That means the view above never needs to branch on whether or not sectioning is
currently active, which is in stark contrast to SwiftData, which requires you to check if sections
are empty and maintain two nearly identical view hierarchies:

```swift
// SwiftData
List {
  if _reminders.sections.isEmpty {
    ForEach(reminders) { reminder in
      ReminderRow(reminder: reminder)
    }
  } else {
    ForEach(_reminders.sections) { section in
      Section(section.id) {
        ForEach(section) { reminder in
          ReminderRow(reminder: reminder)
        }
      }
    }
  }
}
```

## The database does the work

It's worth pointing out what is _not_ happening here: at no point are results loaded into memory and
then grouped by your app. The expression you hand to `sectionBy:` is prepended to the query's
`ORDER BY` clause and evaluated by SQLite, and results are grouped as they are decoded:

```sql
SELECT
  "reminders"."id", "reminders"."title", …, substr("reminders"."title", 1, 1)
FROM "reminders"
ORDER BY substr("reminders"."title", 1, 1) DESC, "reminders"."title"
```

Note the sectioning expression prepended to the `ORDER BY` clause. This means you do not have to
remember to sort your query by whatever you are sectioning by. SQLiteData takes care of it for you,
and the order you specify for the query itself is used _within_ each section.

## And if you need more

The `sectionBy:` argument is tuned for the most common sectioning task: grouping rows into sections
named by a string. But it is not the only tool at your disposal, and it never was. From its very
first release it was possible to group query results in SQLiteData using [`FetchKeyRequest`], which
allows you to run any number of queries in a single database transaction and transform the results
into _any_ data structure you want.

[`FetchKeyRequest`]: https://swiftpackageindex.com/pointfreeco/sqlite-data/~/documentation/sqlitedata/fetchkeyrequest

That tool is still there when you need it, and is what you will reach for when sections must be
keyed by something other than a string, or when the shape of your data isn't a flat list of sections
at all. We recently used it to build an org chart that loads an entire employee hierarchy, along
with the total number of direct and transitive reports for each employee, in a single recursive SQL
query and decodes it directly into a tree of values that drives a hierarchical SwiftUI `List`.

We explore all of this, and more, in our [latest episode][episode], where we rebuild Apple's WWDC
sample Trips app with SQLiteData.

[episode]: /episodes/ep374-wwdc26-sqlitedata-sectioning

## Try it out today!

[SQLiteData 1.8.0][1.8.0] is available today. Update your dependencies to get immediate access to
`@FetchAll(sectionBy:)`, and let us know what you think!
