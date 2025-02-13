We are excited to announce the release of a brand new open source library: 
[SharingGRDB][sharing-grdb-gh]. It's an amalgamation of our [Sharing][sharing-gh] library and
Gwendal Roué's [GRDB.swift][grdb-gh], providing a suite of tools that can replace many usages
of SwiftData while giving you direct access to the underlying SQLite.

Join us for an overview the library, and be sure to check out the 
[many case studies and demos][examples-gh] in the repo.

[examples-gh]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples

## Overview

## Quick start

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

[examples-gh]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples
[case-studies-gh]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples/CaseStudies
[reminders-gh]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples/Reminders
[sync-ups-gh]: https://github.com/pointfreeco/sharing-grdb/tree/main/Examples/SyncUps
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
[reminders-app-store]: https://apps.apple.com/us/app/reminders/id1108187841
[sharing-grdb-gh]: http://github.com/pointfreeco/sharing-grdb
[sharing-gh]: http://github.com/pointfreeco/swift-sharing
[grdb-gh]: http://github.com/groue/grdb.swift
[query-interface]: https://swiftpackageindex.com/groue/grdb.swift/master/documentation/grdb/queryinterface
