> Important: The original release of this library was named SharingGRDB, but has since been 
> renamed to SQLiteData, and now supports full CloudKit synchronization. See our
> [announcement](blog/posts/184-sqlitedata-a-fast-lightweight-alternative-to-swiftdata-with-cloudkit-sync-and-sharing)
> for more info.

We are excited to announce the release of a brand new open source library: 
[SQLiteData][sqlite-data-gh]. It provides a suite of tools that can replace most usages
of SwiftData while giving you direct access to the underlying SQLite, including joins, aggregates,
common table expressions (CVE's) and more!

Join us for an overview the library, and be sure to check out the 
[many case studies and demos][examples-gh] in the repo.

[examples-gh]: https://github.com/pointfreeco/sqlite-data/tree/main/Examples

## Overview

SQLiteData is lightweight replacement for SwiftData and the `@Query` macro.

<table>
<tr>
<th>SQLiteData</th>
<th>SwiftData</th>
</tr>
<tr valign=top>
<td width=50%>
      
```swift
@SharedReader(
  .fetchAll(
    sql: "SELECT * FROM items"
  )
)
var items: [Item]
```

</td>
<td width=50%>

```swift
@Query
var items: [Item]
```

</td>
</tr>
</table>

Both of the above examples fetch items from an external data store, and both are automatically
observed by SwiftUI so that views are recomputed when the external data changes, but SQLiteData is
powered directly by SQLite using [Sharing][sharing-gh] and [GRDB][grdb], and is
usable from UIKit, `@Observable` models, and more.

It is not required to write queries as a raw SQL string, though for simple queries it can be 
quite handy. For more complex queries you are able to use GRDB's query builder API:

```swift
@SharedReader(.fetchAll(Items())) var items

struct Items: FetchKeyRequest {
  func fetch(_ db: Database) throws -> [Item] {
    Item.all()
      .filter(!Column("isArchived"))
      .order(Column("title").desc)
      .limit(100)
      .fetch(db)
  }
}
```

For more information on SQLiteData's querying capabilities, see 
[Fetching model data][fetching-article].

Further, unlike the `@Query` macro from SwiftData, you are not limited to using it only in 
SwiftUI views. It can be used in `@Observable` classes, UIKit view controllers, and of course in
SwiftUI views:

```swift
// Observable models
@Observable class ItemsModel {
  @SharedReader(.fetchAll(Items())) var items
  // ...
}

// UIKit view controllers
class ItemsViewController: UIViewController {
  @SharedReader(.fetchAll(Items())) var items
  // ...
}

// SwiftUI views
struct ItemsView: View {
  @State.SharedReader(.fetchAll(Items())) var items
  // ...
}
```

## Quick start

Before SQLiteData's property wrappers can fetch data from SQLite, you need to provide–at
runtime–the default database it should use. This is typically done as early as possible in your
app's lifetime, like the app entry point in SwiftUI, and is analogous to configuring model storage
in SwiftData:

<table>
<tr>
<th>SQLiteData</th>
<th>SwiftData</th>
</tr>
<tr valign=top>
<td width=50%>

```swift
@main
struct MyApp: App {
  init() {
    prepareDependencies {
      let db =
        try! DatabaseQueue(
          // ...
        )
      $0.defaultDatabase = db
    }
  }
  // ...
}
```

</td>
<td width=50%>

```swift
@main
struct MyApp: App {
  let container = { 
    try! ModelContainer(
      // ...
    )
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(
          container
        )
    }
  }
}
```

</td>
</tr>
</table>

> Note: For more information on preparing a SQLite database, see 
[Preparing a SQLite database][preparing-db-article].

This `defaultDatabase` connection is used implicitly by SQLiteData's strategies, like 
 [`fetchAll`][fetchall-docs]:

```swift
@SharedReader(.fetchAll(sql: "SELECT * FROM items"))
var items: [Item]
```

And you can access this database throughout your application in a way similar to how one accesses
a model context, via a property wrapper:

<table>
<tr>
<th>SQLiteData</th>
<th>SwiftData</th>
</tr>
<tr valign=top>
<td width=50%>

```swift
@Dependency(\.defaultDatabase) 
var database
    
var newItem = Item(/* ... */)
try database.write { db in
  try newItem.insert(db)
}
```

</td>
<td width=50%>

```swift
@Environment(\.modelContext) 
var modelContext
    
let newItem = Item(/* ... */)
modelContext.insert(newItem)
try modelContext.save()
```

</td>
</tr>
</table>

> Note: For more information on how SQLiteData compares to SwiftData, see
> [Comparison with SwiftData][comparison-swiftdata-article].

This is all you need to know to get started with SQLiteData, but there's much more to learn. Read
the [articles][articles] below to learn how to best utilize this library:

* [Fetching model data][fetching-article]
* [Observing changes to model data][observing-article]
* [Preparing a SQLite database][preparing-db-article]
* [Dynamic queries][dynamic-queries-article]
* [Comparison with SwiftData][comparison-swiftdata-article]

[observing-article]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/observing 
[dynamic-queries-article]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/dynamicqueries 
[articles]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata#Essentials 
[comparison-swiftdata-article]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/comparisonwithswiftdata 
[fetching-article]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/fetching 
[preparing-db-article]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/preparingdatabase  
 [fetchall-docs]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/FetchAll

## SQLite knowledge required

SQLite is one of the 
 [most established and widely distributed](https://www.sqlite.org/mostdeployed.html) pieces of 
software in the history of software. Knowledge of SQLite is a great skill for any app developer to
have, and this library does not want to conceal it from you. So, we feel that to best wield this
library you should be familiar with the basics of SQLite, including schema design and normalization,
SQL queries, including joins and aggregates, and performance, including indices.

With some basic knowledge you can apply this library to your database schema in order to query
for data and keep your views up-to-date when data in the database changes. You can use GRDB's
[query builder][query-interface] APIs to query your database, or you can use raw SQL queries, 
along with all of the power that SQL has to offer.

## Demos

This repo comes with _lots_ of examples to demonstrate how to solve common and complex problems with
Sharing. Check out [this][examples-gh] directory to see them all, including:

  * [Case Studies][case-studies-gh]:
    A number of case studies demonstrating the built-in features of the library.

  * [SyncUps][sync-ups-gh]: We also rebuilt Apple's [Scrumdinger][scrumdinger] demo
    application using modern, best practices for SwiftUI development, including using this library
    to query and persist state using SQLite.
    
  * [Reminders][reminders-gh]: A rebuild of Apple's [Reminders][reminders-app-store] app
    that uses a SQLite database to model the reminders, lists and tags. It features many advanced
    queries, such as searching, and stats aggregation.

## Try it out today!

The first release of SQLiteData is out _today_! Give it a spin and let us know what you think
or if you have any questions by opening up a 
[discussion](https://github.com/pointfreeco/sqlite-data/discussions).

[examples-gh]: https://github.com/pointfreeco/sqlite-data/tree/main/Examples
[case-studies-gh]: https://github.com/pointfreeco/sqlite-data/tree/main/Examples/CaseStudies
[reminders-gh]: https://github.com/pointfreeco/sqlite-data/tree/main/Examples/Reminders
[sync-ups-gh]: https://github.com/pointfreeco/sqlite-data/tree/main/Examples/SyncUps
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
[reminders-app-store]: https://apps.apple.com/us/app/reminders/id1108187841
[sqlite-data-gh]: http://github.com/pointfreeco/sqlite-data
[sharing-gh]: http://github.com/pointfreeco/swift-sharing
[grdb]: http://github.com/groue/grdb.swift
[query-interface]: https://swiftpackageindex.com/groue/grdb.swift/master/documentation/grdb/queryinterface
