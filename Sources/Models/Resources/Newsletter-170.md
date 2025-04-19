Today we are releasing a significant update to our [SharingGRDB][] library that offers a fast,
ergonomic, and lightweight replacement for SwiftData, powered by SQL. It provides APIs similar to
`@Model`, `@Query`, and `#Predicate`, but is tuned for direct access to the underlying database,
something that SwiftData abstracts away, giving you more power, flexibility, and performance in how
you persist and fetch data in your application.

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
struct Item {
  let id: Int
  var name = ""
  var isInStock = true
  var notes = ""
}
```

</td>
<td width=50%>

```swift
@Model
class Item {
  var name: String
  var isInStock: Bool
  var notes: String
  init(
    name: String = "",
    isInStock: Bool = true,
    notes: String = ""
  ) {
    self.name = name
    self.isInStock = isInStock
    self.notes = notes
  }
}
```

</td>
</tr>
</table>

Some key differences:

  * The `@Table` macro works with struct data types, whereas `@Model` only works with classes.
  * Because the `@Model` version of `Item` is a class it is necessary to provide an initializer.
  * The `@Model` version of `Item` does not need an `id` field because SwiftData provides a
    `persistentIdentifier` to each model.
    
With `@Table` applied, `Item` gets instant access to a rich set of query building APIs that allow
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
    Item.where {
      $0.name.contains("iPad")
        && $0.isInStock
    }
    .order(by: \.name)
  )
)
var items
```

</td>
<td width=50%>

```swift
@Query(
  filter: #Predicate {
    $0.name.contains("iPad")
      && $0.isInStock
  },
  sort: \Item.name
)
var items: [Item]
```

</td>
</tr>
</table>

Both of the above examples fetch items from an external data store using Swift data types, and both
are automatically observed by SwiftUI so that views are recomputed when the external data changes,
but SharingGRDB is usable outside of the view: in `@Observable` models, UIKit view controllers, and
more.

Note that our query builder maps to syntactically valid SQL, so you can have confidence it will work
at compile time. Meanwhile, `#Predicate` can be wielded in ways that at best produce cryptic compile
time errors, and at worst fail at runtime.

Our query builder also exposes the full range of SQL directly to you, while SwiftData hides these
details from you, instead providing its own query building language that can only perform a small
subset of the tasks that SQL can do.

<!-- TODO: Insert/Update/Delete examples/comparisons -->

## Safe SQL strings

<!-- TODO: -->

## Performance

<!-- TODO: -->

## Made possible by StructuredQueries

<!-- TODO: -->

## Try it today!

The 0.2.0 release of SharingGRDB is out _today_! Give it a spin and let us know what you think. Or,
if you have any questions, start a 
[discussion](https://github.com/pointfreeco/sharing-grdb/discussions).
