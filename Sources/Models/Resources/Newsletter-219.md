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
struct RemindersView: View {
  @FetchAll(Reminder.order(by: \.title), sectionBy: \.category)
  var reminders
  
  var body: some View {
    …
  }
}
```

In the body of the view, the projected value `$reminders` has a `sections` property that can be 
iterated over to display each section:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
var body: some View {
  List {
    ForEach($reminders.sections) { section in
      Section(section.name ?? "Uncategorized") {
        ForEach(section) { reminder in
          Text(reminder.title)
        }
      }
    }
  }
}
```

</div>

<picture style="flex: 0 1 16rem; min-width: 0; max-width: 100%; margin: 0 auto;">
  <source media="(prefers-color-scheme: dark)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/e9ea27b2-e667-4e32-0a1e-cd1211b80600/public">
  <source media="(prefers-color-scheme: light)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/797a3303-4058-4273-2eea-df82fb882a00/public">
  <img alt="A reminders list grouped into sections by category." src="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/797a3303-4058-4273-2eea-df82fb882a00/public" width="100%">
</picture>

</div>

Each `section` itself can be iterated over, and has a `name` describing the section.

That is all it takes, and it looks quite similar to the `sectionBy:` argument that SwiftData's
`@Query` macro gained in appleOS 27+. But this is where the similarities end. SwiftData's
sectioning is restricted to modern Apple OS's and to key paths of string properties on your model, 
whereas SQLiteData's `sectionBy:` works going back to the iOS 13 generation of Apple platforms,
and accepts _any_ SQL expression, which unlocks a whole lot more.

## Sectioning by anything

The `sectionBy:` argument is not just a key path. It's a closure handed the schema of the table
being queried, and so you can section by any string expression you can dream up. For example, if
you want to section reminders alphabetically by the first letter of their title, the prototypical
example of grouping used by the Contacts app, you can invoke SQLite's [`substr`][substr] function 
directly:

[substr]: https://sqlite.org/lang_corefunc.html#substr

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
@FetchAll(
  Reminder.order(by: \.title),
  sectionBy: { $0.title.substr(1, 1) }
)
var reminders
```

</div>

<picture style="flex: 0 1 16rem; min-width: 0; max-width: 100%; margin: 0 auto;">
  <source media="(prefers-color-scheme: dark)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/69e17954-682c-4c75-2934-8e5667da5a00/public">
  <source media="(prefers-color-scheme: light)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/d27609be-324a-4d58-dd15-73a57ea7a600/public">
  <img alt="A reminders list grouped into sections by the first letter of each title." src="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/d27609be-324a-4d58-dd15-73a57ea7a600/public" width="100%">
</picture>

</div>

Or you can section by data that isn't stored in any column at all, such as whether or not a reminder
has been scheduled:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

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

</div>

<picture style="flex: 0 1 16rem; min-width: 0; max-width: 100%; margin: 0 auto;">
  <source media="(prefers-color-scheme: dark)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/d63777bb-744f-45fa-13d9-9101acf95f00/public">
  <source media="(prefers-color-scheme: light)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/f7703808-11e3-42ef-0955-b3fe87e82700/public">
  <img alt="A reminders list grouped into a Scheduled section and an Unscheduled section." src="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/f7703808-11e3-42ef-0955-b3fe87e82700/public" width="100%">
</picture>

</div>

You can even specify how sections are ordered by providing an ascending or descending clause. So,
if you want to section by the first character of reminder titles in a descending fashion, simply
do this:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
@FetchAll(
  Reminder.order(by: \.title),
  sectionBy: { $0.title.substr(1, 1).desc() }
)
var reminders
```

</div>

<picture style="flex: 0 1 16rem; min-width: 0; max-width: 100%; margin: 0 auto;">
  <source media="(prefers-color-scheme: dark)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/40106c2a-cc1e-444d-a95e-f0a3d62f5b00/public">
  <source media="(prefers-color-scheme: light)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/80f4224c-2263-4b32-5088-673b787d5600/public">
  <img alt="A reminders list grouped into sections by the first letter of each title, in descending order." src="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/80f4224c-2263-4b32-5088-673b787d5600/public" width="100%">
</picture>

</div>

When sectioning by something that is `NULL`-able, you can control where the `NULL` values are
placed. Either first, or last:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
@FetchAll(
  Reminder.order(by: \.title),
  sectionBy: { $0.category.asc(nulls: .last) }
)
var reminders
```

</div>

<picture style="flex: 0 1 16rem; min-width: 0; max-width: 100%; margin: 0 auto;">
  <source media="(prefers-color-scheme: dark)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/2c2b0875-f98b-436e-778d-edc7f6f18300/public">
  <source media="(prefers-color-scheme: light)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/0f76329f-095e-46bb-a921-7e000f494f00/public">
  <img alt="A reminders list grouped into sections by category, with the Uncategorized section placed last." src="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/0f76329f-095e-46bb-a921-7e000f494f00/public" width="100%">
</picture>

</div>

Note that the "Uncategorized" section is now at the bottom instead of the top.

None of this is possible with SwiftData: sections are always ordered alphabetically, in an ascending
fashion, by a stored string property.

## Sectioning through relationships

Sectioning is not restricted to data in the table being queried. Because you have the full power of
SQL at your disposal, including joins, you can section rows by data held in _other_ tables.

For example, if you want to display all reminders, grouped by the title of the list they belong to,
you can join the `RemindersList` table to the query:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

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

</div>

<picture style="flex: 0 1 16rem; min-width: 0; max-width: 100%; margin: 0 auto;">
  <source media="(prefers-color-scheme: dark)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/b854cb33-4d05-49b2-3858-04dab2a2b100/public">
  <source media="(prefers-color-scheme: light)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/8e5d3634-042c-4b0b-d693-b67bd0d73c00/public">
  <img alt="A reminders list grouped into sections by the name of the list each reminder belongs to." src="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/8e5d3634-042c-4b0b-d693-b67bd0d73c00/public" width="100%">
</picture>

</div>

The `sectionBy:` closure is handed the schema of every table in the join, and so sectioning by the
list's title is as simple as reaching for it.

## Dynamic sectioning

Sectioning is often something you give your users control over, and so it must be dynamic. The
`sectionBy:` argument is also available on the `load` method of `@FetchAll`'s projected value, which
means you can reload a query with brand new sectioning at any time.

Suppose your feature holds onto some state describing how the user wants their reminders grouped:

```swift
enum GroupOption { 
  case none 
  case category
  case titleFirstLetter 
}

@State var group = GroupOption.none
```

Then you can load a new query whenever that state changes:

```swift
.task(id: group) {
  try? await $reminders.load(
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
```

The `sectionBy:` closure is a builder context, and so you are free to use `if` and `switch`
statements to decide how results should be grouped, and even return `nil` to turn sectioning off
entirely.

When sectioning is turned off, the `sections` collection is populated with a single, unnamed section
holding every row. That means you can structure your view like this:

```swift
var body: some View {
  List {
    ForEach($reminders.sections) { section in
      Section {
        ForEach(section) { reminder in
          Text(reminder.title)
        }
      } header: {
        if let name = section.name {
          Text(name)
        }
      }
    }
  }
}
```

…and it will work whether or not your results are sectioned. There is no need to branch your
view hierarchy to check if sections is empty or not and maintain two nearly identical view 
hierarchies.

## The database does the work

It's worth pointing out what is _not_ happening here: at no point are results loaded into memory and
then grouped by your app. The expression you hand to `sectionBy:` is prepended to the query's
`ORDER BY` clause and evaluated by SQLite, and results are grouped as they are decoded directly
from the connection:

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

`@FetchAll(sectionBy:)` names sections with strings, just as SwiftData does, and that covers the
most common dynamic task, but it is not the only tool at your disposal, and it never was. From its
very first release it was possible to group query results in SQLiteData using [`FetchKeyRequest`],
which allows you to run any number of queries in a single database transaction and transform the
results into _any_ data structure you want.

[`FetchKeyRequest`]: https://swiftpackageindex.com/pointfreeco/sqlite-data/~/documentation/sqlitedata/fetchkeyrequest

And this release brings sectioning to that tool, too. Every query now has a `fetchAll(_:sectionBy:)`
method that returns its results grouped into sections, which means you can section results anywhere
you have a database connection.

You can reach for this tool when you need more precise control over the type that sections results.
_Any_ hashable value can name a section, including your own enums. Suppose reminders also have a
priority:

```swift
@Table struct Reminder {
  …
  var priority: Priority?
}

enum Priority: Int, QueryBindable { case low, medium, high }
```

You could of course coerce that into a string to section by it, but then you have thrown away
everything the type gave you. Your view would have to switch over `"high"` and `"low"` string
literals with a `default` case that should never happen, and worse, your sections would come back in
the wrong order: sorting `"high"`, `"low"` and `"medium"` alphabetically.

Instead you can section by the priority column itself:

```swift
struct RemindersRequest: FetchKeyRequest {
  func fetch(_ db: Database) throws -> ResultsSectionCollection<Reminder, Priority?> {
    try Reminder.order(by: \.title).fetchAll(db, sectionBy: { $0.priority.desc() })
  }
}
```

Because SQLite sorts the underlying column, the sections come back in true priority order: high,
then medium, then low, and then the reminders with no priority at all.

And now the view can switch over section names exhaustively, with no stringly-typed parsing and no
impossible `default` case to handle:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
@Fetch(RemindersRequest())
var reminders = RemindersRequest.Value()

var body: some View {
  List {
    ForEach(reminders) { section in
      Section {
        ForEach(section) { reminder in
          Text(reminder.title)
        }
      } header: {
        switch section.name {
        case .high:
          Label("High", systemImage: "exclamationmark.3")
            .foregroundStyle(.red)
        case .medium:
          Label("Medium", systemImage: "exclamationmark.2")
            .foregroundStyle(.orange)
        case .low:
          Label("Low", systemImage: "exclamationmark")
            .foregroundStyle(.yellow)
        case nil:
          Text("No priority")
        }
      }
    }
  }
}
```

</div>

<picture style="flex: 0 1 16rem; min-width: 0; max-width: 100%; margin: 0 auto;">
  <source media="(prefers-color-scheme: dark)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/7e0813a9-bb0b-4f54-de57-a3b00db1f600/public">
  <source media="(prefers-color-scheme: light)" srcset="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/17e69dd5-278d-477e-62d7-70dfb405e100/public">
  <img alt="A reminders list grouped into sections by priority, with high priority first and reminders with no priority last." src="https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/17e69dd5-278d-477e-62d7-70dfb405e100/public" width="100%">
</picture>

</div>

And this just scratches the surface. A `FetchKeyRequest` can do far more than section a query. It
can bundle these sections together with any number of other queries in a single transaction, and it
is what you will reach for when the shape of your data isn't a flat list of elements or sectioned
data. We recently used it to build an org chart that loads an entire employee hierarchy, along with 
the total number of direct and transitive reports for each employee, in a single recursive common
table expression, and decodes it directly into a tree of values that drives a hierarchical SwiftUI
`List`.

We explore all of this, and more, in our [latest episode][episode], where we rebuild Apple's WWDC
sample Trips app with SQLiteData.

[episode]: /episodes/ep374-wwdc26-sqlitedata-sectioning

## Try it out today!

[SQLiteData 1.8.0][1.8.0] is available today. Update your dependencies to get immediate access to
`@FetchAll(sectionBy:)` and `fetchAll(sectionBy:)`, and let us know what you think!
