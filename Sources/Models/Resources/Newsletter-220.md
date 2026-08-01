We are excited to release version 0.35.0 of our powerful query building library: 
[StructuredQueries](http://github.com/pointfreeco/swift-structured-queries). It brings all new 
tools for storing and querying JSON in your SQLite databases, including support for SQLite's 
efficient binary JSONB format, a full suite of type-safe JSON functions, and even the powerful 
`json_each` table-valued function. 

Join us for a quick overview of these tools, and be sure to [update your dependencies] to get 
access to them.

[update your dependencies]: todo

# Storing JSON and JSONB in your tables

It has always been possible to store complex `Codable` data types in a single column of a SQLite
table using the library's `JSONRepresentation` tool:

```swift:4,5
@Table struct Trip: Identifiable {
  let id: UUID
  var name = ""
  @Column(as: [Location].JSONRepresentation.self)
  var geofence: [Location] = []
}
```

This serializes the array of locations to JSON text and stores it in a single "TEXT" column of the
table. It's a handy trick, but plain text is a pretty inefficient way to hold onto this data. JSON
is a verbose format with lots of repeated labels, and every time SQLite needs to read a value out of
the payload it must re-parse the entire document.

For this reason SQLite offers an alternative, binary format for JSON called
[JSONB](https://sqlite.org/json1.html#jsonb). It is tuned specifically for efficiently reading and
updating data in a JSON payload without repeatedly parsing and re-rendering the document, and it's
even a bit smaller to store on disk.

And now StructuredQueries has full support for JSONB. Just one small change to your schema:

```diff
-@Column(as: [Location].JSONRepresentation.self)
+@Column(as: [Location].JSONBRepresentation.self)
 var geofence: [Location] = []
```

…and your data will be stored in the database as an efficient binary blob. The library automatically
handles all of the details of encoding and decoding this format for you. When selecting a JSONB
column the library wraps it in SQLite's `json` function, and when inserting or updating it wraps the
value in the `jsonb` function:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
Trip.insert {
  $0.geofence 
} values: { 
  locations 
}
```

</div>

<div style="flex: 1 1 20rem; min-width: 0;">

```sql
INSERT INTO "trips" 
("geofence")
VALUES 
(jsonb('[…]'))
```

</div>

</div>

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
Trip.all
```

</div>

<div style="flex: 1 1 20rem; min-width: 0;">

```sql
SELECT …, json("trips"."geofence") 
FROM "trips"
```

</div>

</div>

You get to completely forget that JSONB is even involved and simply write queries like normal.

# Type-safe JSON functions

Storing data as JSON does not mean giving up the ability to query it. SQLite ships a [large family
of JSON functions](https://sqlite.org/json1.html) for reaching into a JSON payload to extract,
update, insert, and remove values, and version 0.35.0 of StructuredQueries brings type-safe and
schema-safe tools for all of them.

For example, suppose a trip's location is stored as a JSON column:

```swift
@Table struct Trip: Identifiable {
  // …
  @Column(as: Location.JSONRepresentation.self)
  var location: Location
}

@Selection struct Location: Codable {
  var latitude = 0.0
  var longitude = 0.0
}
```

By applying the `@Selection` macro to `Location`, the structure of the type becomes visible to the
query builder, and you can now traverse into the JSON using the `jsonExtract` method and a familiar
Swift key path:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
Trip.where {
  $0.location.jsonExtract(\.longitude).lt(0)
}
```

</div>

<div style="flex: 1 1 20rem; min-width: 0;">

```sql
SELECT … FROM "trips"
WHERE json_extract(
  "trips"."location", 
  '$."longitude"') < 0
```

</div>

</div>

Note that the key path is translated to the equivalent [JSON
path](https://sqlite.org/json1.html#path_arguments) in SQLite. And the type of `longitude` is
understand by the query builder to help stiop you from doing something non-sensical, like comparing 
the longitude to a string:

```swift
Trip.where { $0.location.jsonExtract(\.longitude).lt("") }
// 🛑 Compiler error
```

That means you get schema-safety on your table's columns, schema-safety on the fields _inside_ your
JSON payloads, and type-safety on the values being extracted. And these expressions can be used
anywhere in a query: `where` clauses, `select`s, `order`s, and beyond.

You can also update JSON payloads directly in the database, without ever loading them into memory,
using `jsonSet`, `jsonInsert`, `jsonAppend`, `jsonRemove`, and `jsonReplace`:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
Profile.update {
  $0.author = $0.author
    .jsonSet(\.name, "Blob")
}
```

</div>

<div style="flex: 1 1 20rem; min-width: 0;">

```sql
UPDATE "profiles"
SET "author" = json_set(
  "profiles"."author", 
  '$."name"', 'Blob'
)
```

</div>

</div>

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
Profile.update {
  $0.tags = $0.tags
    .jsonAppend("new")
}
```

</div>

<div style="flex: 1 1 20rem; min-width: 0;">

```sql
UPDATE "profiles"
SET "tags" = json_insert(
  "profiles"."tags", 
  '$[#]', 'new'
)
```

</div>

</div>

There are even tools for JSON aggregates (`jsonGroupArray`), constructing JSON objects from a
table's columns (`jsonObject`), computing the length of a JSON array (`jsonArrayLength`), and more.
And each of these tools comes with a JSONB variant (`jsonbExtract`, `jsonbSet`, `jsonbGroupArray`,
…) for when the result should remain in the binary format, such as when assigning to a JSONB column.

# Querying JSON collections with `json_each`

SQLite provides a [table-valued function](https://sqlite.org/json1.html#jeach), `json_each`, that 
turns a JSON array or object into a SQLite virtual   table that can be queried just like any other 
table.

StructuredQueries now provides a `jsonEach()` method on JSON- and JSONB-backed columns that exposes
this functionality in a type-safe manner. Suppose we wanted to find all trips whose entire geofence
lies in the southern hemisphere. That requires iterating over every coordinate in the geofence array
and checking that no latitude is greater than zero, and it can be done directly in SQL:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
Trip.where {
  !$0.geofence.jsonEach()
    .where { 
      $0.value.jsonExtract(\.latitude) > 0 
    }
    .exists()
}
```

</div>

<div style="flex: 1 1 20rem; min-width: 0;">

```sql
SELECT … FROM "trips"
WHERE NOT EXISTS (
  SELECT … 
  FROM json_each("trips"."geofence")
  WHERE json_extract(
    "json_each"."value", 
    '$."latitude"') > 0
)
```

</div>

</div>

The `jsonEach()` method gives you back a select statement whose rows have a `key` (the index in a
JSON array, or member name in a JSON object) and a `value` (the element itself), and you are free to
chain on `where` clauses, `select`s, and more, just like any other query. There is no need to
load everything into memory just to process the results, you don't need to resort to stringly typed
SQL, and the query builder has your back the whole way.

This works for arrays of simple scalar values too:

<div style="display: flex; flex-wrap: wrap; align-items: flex-start; gap: 1.5rem;">

<div style="flex: 1 1 20rem; min-width: 0;">

```swift
Reminder.where {
  $0.tags.jsonEach()
    .where { 
      $0.value.eq("urgent") 
    }
    .exists()
}
```

</div>

<div style="flex: 1 1 20rem; min-width: 0;">

```sql
SELECT … FROM "reminders"
WHERE EXISTS (
  SELECT … 
  FROM json_each("reminders"."tags")
  WHERE "json_each"."value" = 'urgent'
)
```

</div>

</div>

# Get started today

This is just a taste of what is possible with the new JSON tools. For an even deeper dive, including
sorting trips by their live distance from the user's location computed entirely in SQL, be sure to
check out our newest series of episodes, [WWDC26], and update to version 0.35.0 of
[StructuredQueries](http://github.com/pointfreeco/swift-structured-queries) to start using these
tools today!

[WWDC26]: https://www.pointfree.co/collections/wwdc/wwdc-2026
