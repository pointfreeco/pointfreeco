It's the end of another year and we’re feeling nostalgic 😊. Join us for a quick review of 2025 and
a preview of 2026. In the spirit of the holidays, we are also offering [25% off][eoy-discount] the
first year of Point-Free for first-time subscribers and [gift givers]. If you've been on the fence,
now is the perfect time to subscribe!

[eoy-discount]: /discounts/eoy-2025
[gift givers]: /gifts

@Button(/discounts/eoy-2025) {
  Subscribe today!
}

## Highlights

2025 was a big year for us:

  * **41** episodes released with a total of **30** hours of video, and **25** blog posts published.
  * **2** new projects open sourced, **2** new major releases, and dozens of updates to our other
    libraries.

But these high-level stats don't even scratch the surface of what we did this year. Join us for an
overview of some of our favorite episodes, open source updates, and blog posts from 2025:

* [Episodes](#episodes)
  * [Sharing with SQLite](#sharing-with-sqlite)
  * [SQL Building](#sql-building)
  * [Modern Persistence](#modern-persistence)
  * [Tour of SQLiteData](#tour-of-sqlitedata)

* [Open source](#open-source)
  * [SQLiteData](#sqlitedata)
  * [StructuredQueries](#structuredqueries)
  * [Sharing 2](#sharing-2)
  * [Perception 2](#perception-2)

* [Blog posts](#blog-posts)
  * [Open source case study: Listening to our users](#open-source-case-study-listening-to-our-users)
  * [Mitigating SwiftSyntax build times](#mitigating-swiftsyntax-build-times)
  * [Test scoping traits](#test-scoping-traits)
  * [What's new in SQLiteData](#what-s-new-in-sqlitedata)

* [What's coming in 2026](#what-s-coming-in-2026)
  * [The Composable Architecture 2](#the-composable-architecture-2)
  * [Concurrency](#concurrency)
  * [Major releases for modern Swift](#major-releases-for-modern-swift)
  * [Dependencies](#dependencies)
  * [Generics](#generics)
  * [Cross-platform: Android](#cross-platform-android)
  
* [See you next year](#see-you-next-year)

## Episodes

2025 was all about persistence, a fundamental requirement of most apps. In particular, we set out to
demonstrate what we call "[modern persistence]." This turned into an epic, year-long arc of episodes
that started with what we thought would be a quick look at [SQLite]---one of the most well-crafted,
battle-tested, widely-deployed pieces of software in history, and our recommended choice for
complex persistence in applications---and ended with [SQLiteData], our more-than-complete
alternative to SwiftData, built entirely in the open.

[modern persistence]: /collections/modern-persistence
[SQLite]: https://sqlite.org
[SQLiteData]: https://github.com/pointfreeco/sqlite-data

### Sharing with SQLite

Our year began with [a humble start]: we enhanced our [Sharing] persistence library with a SQLite
strategy that made it easy to observe values in a SQLite database from not only SwiftUI views, but
from observable models, UIKit view controllers, and more.

[a humble start]: /collections/sqlite/sharing-with-sqlite
[Sharing]: https://github.com/pointfreeco/swift-sharing

### SQL Building

We kicked things up a notch with a belated addition to our collection of episodes on
[domain-specific languages]: we hosted [a SQL builder] in the Swift type system. We leveraged many
advanced features of Swift to power these tools, including parameter packs, result builders, and
protocols with primary associated types.

[domain-specific languages]: /collections/domain-specific-languages
[a SQL builder]: /collections/sqlite/sql-building

### Modern Persistence

We couldn't resist combining our simple SQLite persistence tool with our new type-safe query
builder, and things [kept escalating] from there. We shared our [from-first-principles] approach to
building an application powered by the superpowers of SQLite, in this case a rebuild of Apple's own
Reminders app. We covered everything from schema design and migrations, efficient and precise
querying, aggregations, [triggers], [full-text search], and even database views. Finally, to tie a
bow around everything, we introduced [iCloud synchronization _and_ sharing], ending up with a tool
that does everything SwiftData does _and more_.

[kept escalating]: /collections/modern-persistence
[from-first-principles]: /collections/modern-persistence/modern-persistence
[triggers]: /collections/modern-persistence/sqlite-triggers
[full-text search]: /collections/modern-persistence/full-text-search
[iCloud synchronization _and_ sharing]: /collections/modern-persistence/cloudkit-synchronization

### Tour of SQLiteData

The tool our year-long episode arc led to was [SQLiteData], and we ended things with a
[tour of the library]. This is the best way to get started today, though we highly recommend the
entire year's worth of episodes to go as deep as we did into the topic of persistence 😂.

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[tour of the library]: /collections/tours/tour-of-sqlitedata

## Open source

### SQLiteData

[SQLiteData] is undoubtedly our open source of the year. It started as a humble library called
SharingGRDB, which was [open sourced] early in the year on Valentine's Day (💘). It simply plugged
our [Sharing] library into the popular [GRDB] SQLite library. By the end of the year we had a
library that had evolved into a more-than-complete replacement for SwiftData, and warranted a
[1.0 rename].

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[open sourced]: /blog/posts/168-sharinggrdb-a-swiftdata-alternative
[Sharing]: https://github.com/pointfreeco/swift-sharing
[GRDB]:  https://github.com/groue/GRDB.swift
[1.0 rename]: /blog/posts/184-sqlitedata-1-0-an-alternative-to-swiftdata-with-cloudkit-sync-and-sharing

### StructuredQueries

A powerful feature of [SQLiteData] is its type-safe (and schema-safe) query builder. The simple act
of applying a macro to a Swift value type gives you instant access to a rich set of APIs that
produce a wide variety of SQL queries that are correct at compile-time.

This superpower is actually a library of its own: [StructuredQueries]! We built this library to be
useful beyond SQLiteData and SQLite. The tool can be used to build queries for MySQL, Postgres, and
more!

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries

### Sharing 2

Our popular persistence library, [Sharing], which was a foundational component of our deep dive into
[modern persistence] this year, had a [major update], including support for `throws`, `async`, and
more.

[Sharing]: https://github.com/pointfreeco/swift-sharing
[modern persistence]: /collections/modern-persistence
[major update]: /blog/posts/164-sharing-2

### Perception 2

Our [backport] of Swift's Observation tools also had a [major update]. This included all the new
features of the official Observation framework, as well as a complete rewrite of its debugging
tools (many thanks to [a contribution] from the community).

[backport]: https://github.com/pointfreeco/swift-perception
[major update]: /blog/posts/180-perception-2-0-an-updated-back-port-of-swift-s-observation-framework
[a contribution]: https://github.com/pointfreeco/swift-perception/pull/165

## Blog posts

### Open source case study: Listening to our users

A favorite post of ours this years is an [open source case study]. Third party libraries are a
contentious topic in the Swift community, and many folks prefer first party and ad hoc solutions
over third party ones. With many libraries under our belt, we are biased, but we take the
opportunity to celebrate some of the benefits of open source, including a more flexible release
cycle than the yearly WWDC drop, as well as a clear and open communication channel that anyone can
read and participate in. To drive things home we share a few examples of how our SQLiteData library
improved thanks to the community.

[open source case study]: /blog/posts/189-open-source-case-study-listening-to-our-users

### Mitigating SwiftSyntax build times 

Swift made a big deal about macros, and we agree: macros are a big deal. Macros also, for a long
time, took a big toll on applications that used them, skyrocketing build times. [This blog post]
shared a solution to the problem, thanks to Xcode's new SwiftSyntax pre-builts, but is also mostly a
time capsule. If you're on Xcode 26, you get this functionality automatically 😁.

[This blog post]: /blog/posts/171-mitigating-swiftsyntax-build-times

### Test scoping traits

Swift Testing introduced [scoping traits] this year, further closing its gap with XCTest in
functionality. We gave a tour of the feature and how it helped us improve many of our test-forward
libraries.

[scoping traits]: /blog/posts/169-new-in-swift-6-1-test-scoping-traits

### What's new in SQLiteData

Building SQLiteData in the open allowed us to announce many, many updates as they came. This led to
an entire series of "what's new in SQLiteData," including:

  * **[Type-safe, schema-safe triggers]**
  * **[Full-text search]**
  * **[User-defined SQL functions]**
  * **[Type-safe, schema-safe database views]**
  * **[Column groups and inheritance]**
  * **[CloudKit migration tools]**
  * **[Custom aggregate functions]**

[Type-safe, schema-safe triggers]: /blog/posts/176-type-safe-schema-safe-sql-triggers-in-swift
[Full-text search]: /blog/posts/182-sharinggrdb-0-6-0-full-text-search-and-more
[User-defined SQL functions]: /blog/posts/183-sharinggrdb-0-7-0-user-defined-sql-functions
[Type-safe, schema-safe database views]: /blog/posts/185-what-s-new-in-sqlitedata-views
[Column groups and inheritance]: /blog/posts/186-new-in-sqlitedata-column-groups-and-inheritance
[CloudKit migration tools]: /blog/posts/187-new-in-sqlitedata-migration-tool-for-cloudkit-sync
[Custom aggregate functions]: /blog/posts/188-new-in-sqlitedata-custom-aggregate-functions

## What's coming in 2026

### The Composable Architecture 2

Our flagship library, [the Composable Architecture] is getting some major updates next year that
will make it both easier to use and more powerful. We have assessed every bit of feedback from our
large user base and are bringing improvements to nearly every facet of the library. Building your
app's business logic layer will become more and more like building your app's SwiftUI view layer.

[the Composable Architecture]: https://github.com/pointfreeco/swift-composable-architecture

We gave [a sneak peek] at some of the upcoming features earlier this year, but they only scratched
the surface. Here are a few more things to get excited about:

#### Fewer concepts to learn

The Composable Architecture currently introduces a zoo of types and functions that let users
describe their application logic, including presentation, navigation, bindings, lists, and more.
In the Composable Architecture 2 you will be able to achieve all of this functionality, and more,
with fewer concepts and in fewer lines of code.

A short list of things that are going away or that will be completely hidden from you:

  - `BindableAction`
  - `BindingAction`
  - `BindingReducer`
  - `IdentifiedAction`
  - `IdentifiedArray`
  - `@ObservableState`
  - `PresentationState`
  - `PresentationAction`
  - `@Presents`
  - `StackAction`
  - `StackState`

Don't worry, though! None of the functionality they provide is going away.

#### Stronger, simpler encapsulation

A common question from Composable Architecture users is how to better encapsulate their
applications. Because Composable Architecture applications compose child state and child actions
directly into their parent domains, parents have unfettered access to read child state and intercept
child actions, and when you try to hide child state and child actions using traditional means, like
access control, it can be quite cumbersome and even hinder your ability to exhaustively test a
feature.

The Composable Architecture 2 will introduce tools to improve how you encapsulate your code. For
example, a feature can now declare local state _via_ the `@FeatureState` property wrapper:

```swift:5-6,9
@Feature
struct Counter {
  struct State { … }
  enum Action { … }
  // Feature-local state not accessible to parent features
  @FeatureState var modificationTime = Date()
  var body: some Feature<State, Action> {
    Update { state, action in
      // Freely access and mutate 'modificationTime' here
      …
    }
  }
}
```

You can think of `@FeatureState` as the Composable Architecture equivalent to SwiftUI's `@State`. It
allows a child feature to own the source of truth of some local domain state that can not be read or
updated from a parent.

#### Access to a store's dependencies

The Composable Architecture leverages a dependency injection system that looks and behaves a lot
like SwiftUI's environment, but up until now has been completely locked up in the feature, away from
the view.

This limitation will be addressed by exposing a particular store's dependencies right to the view.

### Concurrency

A lot has happened in the Swift language since we first covered [concurrency] on Point-Free. We are
working on an updated series that goes [back-to-basics] _and_ modern by exploring a topic that is
paramount to Swift's concurrency paradigm: isolation. We will go _deep_ into the topic with some
seemingly controversial takes, including:

  * Actors should avoid `async` as much as possible
  * You shouldn't always strive to make something sendable

Swift concurrency is an ambitious system with much to admire. It is also still very much a
work-in-progress. We will tackle these topics and discover what works great and why, what is great
in theory and why we're excited about it (but doesn't always work right now), and we will equip you
with the knowledge you need to build complex, asynchronous systems today.

Many of these opinions were forged while reimagining the Composable Architecture for its 2nd major
release. We will share these lessons that we learned along the way.

[concurrency]: https://www.pointfree.co/collections/concurrency
[back-to-basics]: /collections/back-to-basics

### Major releases for modern Swift

Swift and Xcode's new concurrency defaults---"approachable" concurrency and main actor
isolation---force us to completely rethink how our libraries approach concurrency. As a result, we
have many major releases in the works, including Case Paths, Dependencies, Swift Navigation, and
more.

While we always strive to be as backwards-compatible as possible, these releases will introduce
minor breaking changes to accommodate and better embrace modern Swift.

### Dependencies

Dependency management is an evergreen topic. We've given our opinionated approach [in the past], but
how does it stack up against today's Swift? We will explore how improvements to the language
fundamentally change our previous recommendations.

[in the past]: /collections/dependencies

### Generics

Another topic that deserves a [back-to-basics], modern look is Swift's generics system. Swift's
generics have seen many changes since our series on "protocol witnesses." We will dedicate time to
explore enhancements to protocols that make them work better with generics, as well as a powerful
new tool, parameter packs, which we leveraged heavily in our [StructuredQueries] library. We will
also explore more abstract topics, like "what is the enum equivalent of a parameter pack?" It is
totally possible to create such a type in Swift today, and we will do just that!

[back-to-basics]: /collections/back-to-basics
[StructuredQueries]: https://github.com/pointfreeco/swift-structured-queries

### Cross-platform: Android

Finally, we are excited to go cross-platform once again after our 7-part series of episodes
exploring [cross-platform] techniques for sharing code across vastly different platforms,
_e.g._ Apple and Wasm.

[cross-platform]: /collections/cross-platform-swift

Well with the release of Swift's official [Android SDK] we are excited to dive deeper into the topic
of reusing Swift on various platforms.

[Android SDK]: https://www.swift.org/blog/nightly-swift-sdk-for-android/

## See you next year

We're thankful to all of our subscribers for [supporting us](/pricing) and helping us create our 
episodes and support our open source libraries. We could not do it without you!

To celebrate the end of the year we are also offering [25% off][eoy-discount] the first year
for first-time subscribers. If you’ve been on the fence on whether or not to subscribe, now
is the time!

[eoy-discount]: /discounts/eoy-2025

@Button(/discounts/eoy-2025) {
  Subscribe today!
}
