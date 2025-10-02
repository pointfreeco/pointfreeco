[SQLiteData] has powerful new tools for composing your schema's Swift data types, which allows
for better data modeling, schema reuse, single-table inheritance, and more. Join us for a quick 
overview of what has been added to SQLiteData.

[SQLiteData]: https://github.com/pointfreeco/sqlite-data

## Column groups

It is possible to group many related columns into a single data type, which helps with organization
and reusing little bits of schema amongst many tables. For example, suppose many tables in your
database schema have `createdAt: Date` and `updatedAt: Date?` timestamps. You can choose to group
those columns into a dedicate data type, annotated with the `@Selection` macro:

```swift
@Selection
struct Timestamps {
  let createdAt: Date
  let updatedAt: Date?
}
```

And then you can use `Timestamps` in tables as if it was just a single column:

```swift
@Table
struct RemindersList {
  let id: Int
  var name = ""
  let timestamps: Timestamps
}

@Table
struct Reminder {
  let id: Int
  var name = ""
  var isCompleted = false
  let timestamps: Timestamps
}
```

> Important: Since SQLite has no concept of grouped columns you must remember to flatten all
> groupings into a single list when defining your table's schema. For example, the "CREATE TABLE"
> statement for the `RemindersList` above would look like this:
> 
> ```sql
> CREATE TABLE "remindersLists" (
>   "id" INTEGER PRIMARY KEY,
>   "name" TEXT NOT NULL,
>   "isCompleted" INTEGER NOT NULL,
>   "createdAt" TEXT NOT NULL,
>   "updatedAt" TEXT
> ) STRICT
> ```

You can construct queries that access fields inside column groups using regular dot-syntax:

<table>
<tr valign=top>
<td width=50%>

```swift
RemindersList
  .where { 
    $0.timestamps.createdAt <= date 
  }
  
  
  
```

</td>
<td width=50%>

```sql
SELECT 
  "id", 
  "title", 
  "createdAt", 
  "updatedAt"
FROM "remindersLists"
WHERE "createdAt" <= ?
```

</td>
</tr>
</table>

You can even compare the `timestamps` field directly and its columns will be flattened into a 
tuple in SQL:

<table>
<tr valign=top>
<td width=50%>

```swift
RemindersList
  .where { 
    $0.timestamps 
      <= Timestamps(
        createdAt: date1, 
        updatedAt: date2
      ) 
  }
```

</td>
<td width=50%>

```sql
SELECT 
  "id", 
  "title", 
  "createdAt", 
  "updatedAt"
FROM "remindersLists"
WHERE ("createdAt", "updatedAt") <= (?, ?)

```

</td>
</tr>
</table>

That allows you to query against all columns of a grouping at once.

These improvements to the library make it also possible to nest `@Selection` data types when 
selecting certain columns from your queries, which was previously impossible. For example,
if you want to select the title of each reminder with the title of its associated list, as well
as the reminder's timestamps, you can design the following data type:

```swift
@Selection struct Row {
  let reminderTitle: String
  let remindersListTitle: String
  let reminderTimestamps: Timestamps
}
```

And then construct a query that selects this data into the `Row` data type:

<table>
<tr valign=top>
<td width=50%>

```swift
Reminder
  .join(RemindersList) {
    $0.remindersListID.eq($1.id)
  }
  .select {
    Row.Columns(
      reminderTitle: $0.title,
      remindersListTitle: $1.title,
      remindersTimestamps: $0.timestamps
    )
  }
```

</td>
<td width=50%>

```sql
SELECT 
  "reminders"."title",
  "remindersLists"."title", 
  "reminders"."createdAt", 
  "reminders"."updatedAt"
FROM "reminders"
JOIN "remindersLists"
  ON "remindersListID" = "id"



```

</td>
</tr>
</table>

## Enum tables, a.k.a single-table inheritance

With this release we have allowed the `@Table` and `@Selection` macros to be used on enums, which 
can be used to emulate "inheritance" for your tables without having the burden of using 
reference types. 

As an example, suppose you have a table that represents attachments that can be associated with 
other tables, and an attachment can either be a link, a note or an image. One way to model this
is a struct to represent the attachment that holds onto an enum for the different kinds of 
attachments supported, annotated with the `@Selection` macro:

```swift
@Table struct Attachment {
  let id: Int
  let kind: Kind

  @CasePathable @Selection
  enum Kind {
    case link(URL)
    case note(String)
    case image(URL)
  }
}
```

> Important: It is required to apply the `@CasePathable` macro in order to define columns from an
> enum. This macro comes from our [Case Paths] library and is automatically included with the
> library when the `StructuredQueriesCasePaths` trait is enabled.

[Case Paths]: http://github.com/pointfreeco/swift-case-paths

To create a SQL table that represents this data type you simply flatten all of the fields into
a single list of columns where each column is nullable:

```sql
CREATE TABLE "attachments" (
  "id" INTEGER PRIMARY KEY,
  "link" TEXT,
  "note" TEXT,
  "image" TEXT
) STRICT
```

With that defined you can query the table much like a regular table. For example, a simple
`Attachment.all` selects all columns, and when decoding the data from the database it will
be decided which case of the `Kind` enum is chosen:

<table>
<tr valign=top>
<td width=50%>

```swift
Attachment.all





```

</td>
<td width=50%>

```sql
SELECT 
  "attachments"."id", 
  "attachments"."link", 
  "attachments"."note", 
  "attachments"."image"
FROM "attachments"
```

</td>
</tr>
</table>
You can also use `where` clauses to filter attachments by their kind, such as selecting images
only:

<table>
<tr valign=top>
<td width=50%>

```swift
Attachment
  .where { 
    $0.kind.image.isNot(nil) 
  }
  
  
```

</td>
<td width=50%>

```sql
SELECT 
  "attachments"."id", 
  "attachments"."link", 
  "attachments"."note", 
  "attachments"."image"
FROM "attachments"
WHERE "attachments"."image" IS NOT NULL 
```

</td>
</tr>
</table>
You can insert attachments into the database in the usual way:

<table>
<tr valign=top>
<td width=50%>

```swift
Attachment.insert {
  Attachment.Draft(
    kind: .note("Hello world!")
  )
}
```

</td>
<td width=50%>

```sql
INSERT INTO "attachments"
("id", "link", "note", "image")
VALUES
(NULL, NULL, 'Hello world!', NULL)

```

</td>
</tr>
</table>
Notice that `NULL` is inserted for `link` and `image` since we are inserting an attachment
with the `note` case.

And further, you can update attachments in the database in the usual way:

<table>
<tr valign=top>
<td width=50%>

```swift
Attachment.update {
  $0.kind = .note("Goodbye world!")
}


```

</td>
<td width=50%>

```sql
UPDATE "attachments"
SET 
  "link" = NULL, 
  "note" = 'Goodbye world!', 
  "image" = NULL
```

</td>
</tr>
</table>
Note that `link` and `image` are explicitly set to `NULL` since we are setting the kind of
the attachment to `note`.

It is also possible to group many columns together for a case of an enum. For example, suppose
the image not only had a URL but also had a caption. Then a dedicated `@Selection` type
can be defined for that data and used in the `image` case:

```swift
@Table struct Attachment {
  let id: Int
  let kind: Kind

  @CasePathable @Selection
  enum Kind {
    case link(URL)
    case note(String)
    case image(Attachment.Image)
  }
  @Selection 
  struct Image {
    var caption = ""
    var url: URL
  }
}
```

> Note: Due to how macros expand it is necessary to fully qualify nested types, e.g.
> `case image(Attachment.Image)`.

To create a SQL table that represents this data type you again must flatten all columns into a 
single list of nullable columns:

```sql
CREATE TABLE "attachments" (
  "id" INTEGER PRIMARY KEY,
  "link" TEXT,
  "note" TEXT,
  "caption" TEXT,
  "url" TEXT
) STRICT
```

These tools allow you to emulate what is known as "single table inheritance", where you model
a class inheritance heirarchy of models as a single wide table that has columns for each
model. This allows you to share bits of data and logic amongst many models in a way that still
plays nicely with SQLite.

SwiftData supports this kind of data modeling, but they force you to use reference
types instead of value types, you lose exhaustivity for the types of models supported, and
it's a lot more verbose:

```swift
@available(iOS 26, *)
@Model class Attachment {
  var isActive: Bool
  init(isActive: Bool = false) { self.isActive = isActive }
}

@available(iOS 26, *)
@Model class Link: Attachment {
  var url: URL
  init(url: URL, isActive: Bool = false) {
    self.url = url
    super.init(isActive: isActive)
  }
}

@available(iOS 26, *)
@Model class Note: Attachment {
  var note: String
  init(note: String, isActive: Bool = false) {
    self.note = note
    super.init(isActive: isActive)
  }
}

@available(iOS 26, *)
@Model class Image: Attachment {
  var url: URL
  init(url: URL, isActive: Bool = false) {
    self.url = url
    super.init(isActive: isActive)
  }
}
```

> Note: The `@available(iOS 26, *)` attributes are required even if targeting iOS 26+, and 
> the explicit initializers are required and must accept all arguments from all parent 
> classes and pass that to `super.init`.

Enums provide an alternative to this approach that embraces value types, is more concise, and
more powerful.

## Passing entire table rows to database functions

Thanks to the power of the tools above, it is now possible to pass entire database rows
to [database functions]. You can define a database function using the `@DatabaseFunction` macro,
and it can take a full table value as an argument:

```swift
@DatabaseFunction
func isPastDue(reminder: Reminder) -> Bool {
  !reminder.isCompleted && reminder.dueDate < Date()
}
```

Then, in a query you can invoke this function and our library takes care of flattening the columns
of the table into arguments of the function, and reconstituting those columns back into a Swift
value:

<table>
<tr valign=top>
<td width=50%>

```swift
Reminder
  .where { 
    $isPastDue(reminder: $0)
  }
  
  
  
```

</td>
<td width=50%>

```sql
SELECT 
  "id", 
  "title",
  "dueDate"
FROM "remindersLists"
WHERE isPastDue("id", "title", "dueDate")
```

</td>
</tr>
</table>

This give you even more type-safety and schema-safety in your queries.

[database functions]: /blog/posts/183-sharinggrdb-0-7-0-user-defined-sql-functions

## Try it out today!

These features come to [SQLiteData] _via_ its dependency on [StructuredQueries] [0.21.0]. We hope
you'll take these new features for a spin!

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries
[0.21.0]: https://github.com/pointfreeco/swift-structured-queries/release/0.21.0
