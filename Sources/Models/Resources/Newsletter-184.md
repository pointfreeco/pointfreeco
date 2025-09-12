Today we are releasing [SQLiteData 1.0][sqlite-data-gh], an alternative to SwiftData that provides 
the tools necessary to build apps with complex persistence and query needs, all based on [SQLite]:

[SQLite]: https://sqlite.org`

- Model your data types as concisely as possible using everything Swift has to offer, such as
  **structs** and **enums**.
- Perform **type-safe** and **schema-safe** queries to fetch your data in anyway you want.
- Decode data from the database using a **performant, custom SQLite decoder** that is only a tiny 
  bit slower than dealing directly with SQLite's C functions.
- Leverage **Property wrappers** similar to SwiftData's `@Query` that allow you to fetch data in
  SwiftUI views so that when the database changes the view automatically refreshes. These property 
  wrappers even work outside of SwiftUI views, such as in **`@Observable` models** and even 
  **UIKit view controllers**.
- Direct support for **CloudKit synchronization** so that your users' data is distributed across all
  of their devices.
- Support for **iCloud sharing**, which allows your users to share a record (and all of its 
  associations) with another iCloud user.
- Powered by **SQLite**, a battle tested technology that is over 25 years old and one of the most
  widely deployed pieces of software in history.

It accomplishes all of this (and more) in a lightweight and ergonomic API that is fully [documented]
and comes with a wide variety of [demo apps and case studies][Examples].

## Using SQLiteData

SQLiteData allows you to model your domain types as concisely as possible, using all of the 
amazing tools that Swift gives us. This means you can use structs instead of classes, raw
representable enums to model choices, and immutable `let`s for IDs that should not change
after instantiation:

```swift
import SQLiteData

@Table
struct Reminder: Identifiable {
  let id: UUID 
  var title = ""
  var isCompleted = false 
  var priority: Priority?
  
  enum Priority: Int {
    case low, medium, high
  }
}
```

After a little bit of work to [prepare your SQLite database][prepare-database], you can immediately
start fetching this data from the database using the `@FetchAll` property wrapper:

```swift:2
struct RemindersView: View {
  @FetchAll var reminders: [Reminder]
  var body: some View {
    ForEach(reminders) { reminder in
      Text(reminder.title)
    }
  }
}
```

Even better, you can describe the SQL query that powers this data directly inline with the 
property wrapper. For example, to sort incomplete reminders above completed ones you can do:

```swift
@FetchAll(Reminder.order(by: \.isCompleted)) 
var reminders
```

Or to fetch only high-priority reminders:

```swift
@FetchAll(Reminder.where { $0.priority.eq(Priority.high) }) 
var reminders
```

This barely scratches the surface of the kinds of queries you can build. Our library supports
SQL joins, aggregates, common table expressions, and more. See the full docs of our
[StructuredQueries][sq-docs] for more information on writing type-safe and schema-safe queries.

[sq-docs]: https://swiftpackageindex.com/pointfreeco/swift-structured-queries/main/documentation/structuredqueriescore/



## Example projects galore

SQLiteData comes with many, _many_ [example projects][examples] to show you the best practices of 
getting started, and how to solve the most common problems one comes across in apps with complex 
persistence and querying needs:

* [**Case Studies**](https://github.com/pointfreeco/sqlite-data/tree/main/Examples/CaseStudies)
  <br> Demonstrates how to solve some common application problems in a simplified environment, in
  both SwiftUI and UIKit. Things like animations, dynamic queries, database transactions, and more.

* [**CloudKit Demo**](https://github.com/pointfreeco/sqlite-data/tree/main/Examples/CloudKitDemo)
  <br> A simplified demo that shows how to synchronize a SQLite database to CloudKit and how to
  share records with other iCloud users. See our dedicated articles on [CloudKit Synchronization]
  and [CloudKit Sharing] for more information. 
  
  [CloudKit Synchronization]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/cloudkit
  [CloudKit Sharing]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/cloudkitsharing

* [**Reminders**](https://github.com/pointfreeco/sqlite-data/tree/main/Examples/Reminders)
  <br> A rebuild of Apple's [Reminders][reminders-app-store] app that uses a SQLite database to
  model the reminders, lists and tags. It features many advanced queries, such as searching, stats
  aggregation, and multi-table joins. It also features CloudKit synchronization and sharing.

* [**SyncUps**](https://github.com/pointfreeco/sqlite-data/tree/main/Examples/SyncUps)
  <br> This application is a faithful reconstruction of one of Apple's more interesting sample
  projects, called [Scrumdinger][scrumdinger], and uses SQLite to persist the data for meetings.
  We have also added CloudKit synchronization so that all changes are automatically made available
  on all of the user's devices.
  
If there are more examples or case studies you would like to see built, start a [discussion]!

[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
[reminders-app-store]: https://apps.apple.com/us/app/reminders/id1108187841
[examples]: https://github.com/pointfreeco/sqlite-data/tree/main/Examples

## Fully documented

The library comes fully [documented] with many articles exploring the more nuanced topics of data
persistence and querying in complex applications:

* [**Fetching model data**](https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/fetching)
  <br> Learn how to use the `@FetchAll`, `@FetchOne` and `@Fetch` property wrappers for performing
  SQL queries to load data from your database.
  
* [**Observing changes to model data**](https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/observing)
  <br> Learn how to observe changes to your database in SwiftUI views, UIKit view controllers, and 
  more. 
  
* [**Preparing a SQLite database**][prepare-database]
  <br> Learn how to create, configure and migrate the SQLite database that holds your application’s 
  data.
  
* [**Dynamic queries**](https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/dynamicqueries)
  <br> Learn how to load model data based on information that isn’t known at compile time.
  
* [**Comparison with SwiftData**](https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/comparisonwithswiftdata)
  <br> Learn how SQLiteData compares to SwiftData when solving a variety of problems.
  
* [**Getting started with CloudKit**](https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/cloudkit)
  <br> Learn how to seamlessly add CloudKit synchronization to your SQLiteData application.
  
* [**Sharing data with other iCloud users**](https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/cloudkitsharing)
  <br> Learn how to allow your users to share certain records with other iCloud users for collaboration.
  
If there is anything you feel is lacking from our documentation, please open a [discussion]
and we can figure out how to better document the library!

## Get started today

Give the library a spin today by cloning the [repo][sqlite-data-gh], opening Examples.xcodeproj
and running one of the many example apps. If you have any questions, feel free to 
[start a discussion][discussion].

[prepare-database]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata/preparingdatabase
[documented]: https://swiftpackageindex.com/pointfreeco/sqlite-data/main/documentation/sqlitedata
[discussion]: https://github.com/pointfreeco/sqlite-data/discussions
[sqlite-data-gh]: https://github.com/pointfreeco/sqlite-data
