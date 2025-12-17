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

  * **TODOk** unique visitors to the site.
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
  * [What's new in SQLiteData](#whats-new-in-sqlitedata)

* [What's coming in 2026](#whats-coming-in-2026)
  * [The Composable Architecture 2](#the-composable-architecture-2)
  * [Major releases for modern Swift](#major-releases-for-modern-swift)
  * [Modern concurrency](#modern-concurrency)
  * [Modern dependencies](#modern-dependencies)
  * [Back to basics: Generics](#back-to-basics-generics)
  * [Cross-platform: Android](#cross-platform-android)
  
* [See you next year][#see-you-next-year]

## Episodes

2015 was all about persistence, a fundamental requirement of most apps. In particular, we set out to
demonstrate what we call "[modern persistence]." This turned into an epic, year-long arc or episodes
that started with what we thought would be a quick look at [SQLite]---one of the most well-crafted,
battle-tested, widely-deployed pieces of software in history, and our recommended choice for
complex persistence in applications---and ended with [SQLiteData], our more-than-complete
alternative to SwiftData, built entirely in the open.

[modern persistence]: /collections/modern-persistence
[SQLite]: https://sqlite.org
[SQLiteData]: https://github.com/pointfreeco/sqlite-data

### Sharing with SQLite

Our year began with [a humble start]: we enhanced our [Sharing] persistence library with a SQLite
strategy that made it easy to observe values in a database from not only SwiftUI views, but
observable models, UIKit view controllers, and more.

[a humble start]: /collections/sqlite/sharing-with-sqlite
[Sharing]: https://github.com/pointfreeco/swift-sharing

### SQL Building

We kicked things up a notch with a belated addition to our collection of episodes on
[domain-specific languages]: we hosted [a SQL builder] in the Swift type system. We leveraged many
advanced features of Swift to power these tools, including parameter packs, result builders, and
protocols with primary associated types.

[domain-specific languages]: /collections/domain-specific-languages
[host a type-safe SQL builder]: /collections/sqlite/sql-building

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
library that had evolved into a more-than complete replacement for SwiftData, and warranted a
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
[modern persistence] this year, had a [major update] this year, including support for `throws`,
`async`, and more.

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
contentious topic in the Swift community, and many folks prefer first party Apple solutions, and
ad hoc ones. With many libraries under our belt, we are biased, but we take the opportunity to
celebrate some of the benefits of open source, including a more flexible release cycle than the
yearly WWDC drop, as well as a clear and open communication channel that anyone can read and
participate in. To drive things home we share a few examples of how our SQLiteData library improved,
thanks to the community.

[open source case study]: /blog/posts/189-open-source-case-study-listening-to-our-users

### Mitigating SwiftSyntax build times 

Swift made a big deal about macros, and we agree: macros are a big deal. Macros also, for a long
time, took a big toll on applications that used them, skyrocketing build times. [This blog post]
shared a solution to the problem, thanks to Xcode's new SwiftSyntax pre-builts, but is also mostly a
time capsule. If you're on Xcode 26, you get this functionality automatically 😁.

[This blog post]: /blog/posts/171-mitigating-swiftsyntax-build-times

### Test scoping traits

Swift Testing introduced [scoping traits] this year, further closing the gap between it and XCTest
in functionality. We gave a tour of the feature and how it helped us improve many of our
test-forward libraries.

[scoping traits]: /blog/posts/169-new-in-swift-6-1-test-scoping-traits

### What's new in SQLiteData

Building SQLiteData in the open allowed us to announce many, many updates as they came. This led to
an entire series of "what's new in SQLiteData," including:

  * [Type-safe, schema-safe triggers]
  * [Full-text search]
  * [User-defined SQL functions]
  * [Type-safe, schema-safe database views]
  * [Column groups and inheritance]
  * [CloudKit migration tools]
  * [Custom aggregate functions]

[Type-safe, schema-safe triggers]: /blog/posts/176-type-safe-schema-safe-sql-triggers-in-swift
[Full-text search]: /blog/posts/182-sharinggrdb-0-6-0-full-text-search-and-more
[User-defined SQL functions]: /blog/posts/183-sharinggrdb-0-7-0-user-defined-sql-functions
[Type-safe, schema-safe database views]: /blog/posts/185-what-s-new-in-sqlitedata-views
[Column groups and inheritance]: /blog/posts/186-new-in-sqlitedata-column-groups-and-inheritance
[CloudKit migration tools]: /blog/posts/187-new-in-sqlitedata-migration-tool-for-cloudkit-sync
[Custom aggregate functions]: /blog/posts/188-new-in-sqlitedata-custom-aggregate-functions

## What's coming in 2026

### The Composable Architecture 2

<!-- TODO -->

### Concurrency

A lot has happened in the Swift language since we first covered [concurrency] on Point-Free. We are
working on an updated series that goes back-to-basics _and_ modern by exploring a topic that is
paramount to Swift's concurrency paradigm: isolation. We will go _deep_ into the topic with some
controversial takes, including:

  * Actors should avoid `async` as much as possible
  * Sendability isn't always an asset

[concurrency]: https://www.pointfree.co/collections/concurrency

### Major releases for modern Swift

Swift and Xcode's new concurrency defaults---"approachable" concurrency and main actor
isolation---force us to completely rethink how our libraries approach concurrency/

As a result, we have many major releases in the works, including Case Paths, Dependencies,
Swift Navigation, and more. We always strive to be as backwards-compatible as possible, but these
releases will introduce breaking changes that allow you to better embrace modern Swift.

### Dependencies

Dependency management is an evergreen topic. We've given our opinionated approach in the past, but
how does it stack up against today's Swift? We will explore how improvements to the language
fundamentally change our previous recommendation of protocol-witness structs.

### Generics

### Cross-platform: Android

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





@Comment {

> Important: For the first time ever we have extended our Cyber Week sale to gifts. You can now
[give the gift of Point-Free](/gifts) for 25% off!

Point-Free offers the most advanced and original Swift content out there, and we maintain open 
source libraries used by tens of thousands of developers. We even maintain a SwiftData 
[alternative][sqlite-data-blog] powered by SQLite that supports seamless iCloud synchronization 
and data sharing. 

[sqlite-data-blog]: /blog/posts/184-sqlitedata-1-0-an-alternative-to-swiftdata-with-cloudkit-sync-and-sharing

We have an incredible amount of topics to cover next year, and to get a jump start on perfecting 
your expertise in Swift we are offering a [Cyber Week **25% discount**][cyber-week-sale] for the 
first year of your subscription.

[cyber-week-sale]: /discounts/eoy-2025

@Button(/discounts/eoy-2025) {
  Subscribe today for 25% off!
}

Once subscribed you'll get instant access to all [348 episodes][pf] of original Point-Free content.
This includes our popular ["Modern Persistence"][modern-persistence] series started just this year,
where we show what it takes to build an app on a modern foundation using SQLite for persistence,
including iCloud synchronization and data sharing. 

[modern-persistence]: /collections/modern-persistence

And we have an incredible amount of advanced content lined up for 2026, including:

[pf]: /
[cyber-week-sale]: /discounts/eoy-2025
[collections]: /collections

## The Composable Architecture, 2.0

That's right. We have been hard at work on [Composable Architecture][tca] 2.0 for many, _many_
months now, and we are just ready to start sharing some details. We have assessed every bit of
feedback from our users over the past 5+ years and improved nearly every facet of the library.
Building features in the Composable Architecture should feel more and more like building SwiftUI
views.

[tca]: http://github.com/pointfreeco/swift-composable-architecture

### SwiftUI bindings with less fuss

2.0 of the library completely removes the need to specify `BindingReducer()` and `BindingAction`.
Instead, it makes bindings to stores immediately available without any additional work:

```swift
TextField("Name", text: $store.name)
```

To observe changes to the `name` field in your feature you simply use the `onChange(of:)` method:

```swift
.onChange(of: \.name) { oldName, state in
  …
}
```

No more accidentally forgetting to invoke `BindingReducer()` from the reducer and having to debug
why your feature isn't working.
 
### More powerful effects

Effects in the library have been given new super powers. It is now possible to read the current 
state from an effect without sending an action. Effects are now handed full-fledged stores that can
both send actions _and_ read state:

```swift:3
.run { store in
  for await _ in clock.timer(interval: .seconds(1)) {
    guard try store.alert == nil
    else { continue }
    
    try store.send(.timerTick)
  }
}
```

This effect pauses the timer in the feature if an alert is currently being presented to the user.

Reading a feature's current state directly in an effect allows you to localize more logic to where
it belongs, rather than spreading it across many different actions.

Also note that one can both access the store's state and send effects _without_ any suspension
points. The isolation of the effect now matches the isolation of the store running the feature, and
so one can interact with the store in a synchronous fashion. See
[Advanced concurrency](#advanced-concurrency) for more info.

Another superpower of effects is that they can now make mutations to the feature's state directly,
without sending an action:

```swift
.run { store in
  for await _ in clock.timer(interval: .seconds(1)) {
    guard try store.isTimerRunning
    else { break }
    
    try store.modify { $0.secondsElapsed += 1 }
  }
}
```

This may seem counterintuitive if you are familiar with the library's core tenets, but we feel this
is still in line with the philosophy of the library.

All mutations to a feature's state still happen within the body of the feature, where you can
observe changes the same way you observe changes to bindings using the `onChange(of:)` method:

```swift
.onChange(of: \.secondsElapsed) { … }
```

And everything is still 100% testable using the `TestStore`, but we feel it will greatly reduce the
amount of action "ping-ponging" one has to do to implement their feature's logic. 

### Feature lifecycle hooks

Features built in the library now have a natural notion of "mounting", which corresponds to its 
state being initialized. Previously one would have to send an explicit `.onAppear` actions from the 
view to emulate this concept, but now you can simply use the `.onMount` method:

```swift:2
Update { … }
  .onMount { store in
    guard try store.isTimerRunning
    else { return }

    for await _ in clock.timer(interval: .seconds(1)) {
      try store.send(.timerTick)
    } 
  }
```

The `onMount` method is similar to SwiftUI's `onAppear` view modifier, but tuned to your feature's
logic. The trailing closure is executed as soon as a feature's state is initialized, and allows you
to perform any initial or long-living work associated with a feature. The closure is handed a
full-fledged store that you can send actions to _and_ read state from. This work is automatically
canceled when the feature is deinitialized. And unlike SwiftUI's `onAppear`, this closure is truly
invoked just a single time for the lifetime of the feature.

There is also an `onMount(id:)` method that is invoked when a feature is first initialized, as well
as when a piece of state changes in your feature. This can be a great tool for debouncing search
requests that depend on a piece of state:

```swift:2
Update { … }
  .onMount(id: \.searchText) { store in
    try await clock.sleep(for: .seconds(0.3))
    try store.send(.searchResults(apiClient.search(store.searchText)))
  }
```

There is even an `onDismount` method that is invoked the moment the feature is deinitialized:

```swift:2
Update { … }
  .onDismount { state in
    await analyticsClient.track("Feature dismounted")
  }
```

The trailing closure is handed the final state of the feature _just_ before deinitialization, and it
is provided an async context for you to perform any additional work. This addresses a long-standing
problem in the library in which a feature cannot be sent `onDisappear` actions from the view because
by that point the feature's state has already been deinitialized.

> Note: A different, but closely related, tool has also been massively improved: `onChange(of:)`.
> this method now detects _all_ changes to state, not just changes made by the reducer it is
> attached to.

### Advanced concurrency

The internals of the library have been rewritten to fully embrace all of Swift's most advanced
concurrency tools. Stores that power features now come in two flavors: `Store` is main actor
bound and appropriate to use in UI applications, and `StoreActor` is just like `Store` except it
will execute on the cooperative thread pool:

```swift
@MainActor
func main() async {
  // No need for 'await' since 'Store' is main actor bound.
  let store = Store(initialState: Feature.State()) {
    Feature()
  }
  store.send(.buttonTapped)
  print(store.state)
  
  // Need to 'await' to interact with a 'StoreActor'.
  let store = await StoreActor(initialState: Feature.State()) {
    Feature()
  }
  await store.send(.buttonTapped)
  print(await store.state)
}
```

This satisfies an old request of the library for "background stores" in order to use the library to 
model features that have no UI component. And this deep integration of `Store` with Swift's
concurrency tools is also what allows effects to synchronously access the store's state and
send actions without any suspension points.

And perhaps the biggest benefit of us completely embracing Swift concurrency and removing all 
traces of Combine from the library is that it will effortlessly compile across all platforms
supported by Swift, including Android and Wasm.

### Better debugging tools

While you no longer have to invoke `BindingReducer()` from the feature's body to derive bindings to
its state, you _do_ still have to remember to `Scope` and `ifLet` each child feature, but now if
you forget to do so you will immediately get an actionable runtime warning when your view scopes to
an inert, unimplemented feature:

```swift:1:runtime
.sheet(item: $store.scope(state: \.child, action: \.child)) {
  …
}
```

> Runtime Warning: Scoped store has no child domain defined. Did you forget to install an
> `'ifLet(\.child)'` in the feature's `'body'`?

This, and other brand new debugging tools, will be coming to the library.

### More announcements to come

These are just a few of the many new features of the Composable Architecture 2.0 that we are excited
about. Stay tuned for more announcements in the coming weeks.

## Back to basics: Concurrency

We've had two very popular series of episodes under the ["Back to basics"][b2b] umbrella, and next
year we are starting some new ones. Through our work on the 
[Composable Architecture 2.0](#the-composable-architecture-2-0) we have gained valuable experience
and insight into almost every facet of Swift's latest concurrency tools. We are ready to start 
exploring these tools in episodes that truly get at the heart of what problem Swift concurrency is
trying to solve, and how it does a pretty amazing job at solving it.

The most important concept to be explored is that of "isolation". When approached naively you are
led to an unfortunate situation of everything becoming async since you need to `await` in order
to guarantee isolation. Well, by employing some advanced techniques we can write code that embraces
synchronicity _and_ isolation at the same time. It's how we were able to allow effects in the
Composable Architecture 2.0 to synchronously interact with the store, and it's how we were able to fix
many notorious non-determinism problems in the library's testing tools.

Along the way in this series we are going to explore some of the newer concepts that Swift has
introduced to make Swift more "beginner" friendly ("approachable" concurrency, default main actor
isolation, _etc._), and we will slowly work our way up to very advanced topics, such as actors with
custom executors, embracing the power of *non*-sendable types (you read that right), and a lot
more.

[b2b]: /collections/back-to-basics
[eq-hash]: /collections/back-to-basics/equatable-and-hashable
[sqlite]: /collections/back-to-basics/introduction-to-sqlite

## Modern dependencies

It's been a long time since we dedicated episodes to [dependencies][dep-col] on Point-Free, and a
lot has changed in Swift since then. We feel that robust modern features of Swift allow us to take a
fresh look at dependencies, allowing us to achieve the goals and ergonomics we laid out in the
original series with a lot less code and all new powers that were difficult to imagine previously.

[dep-col]: /collections/dependencies

## Back to basics: Generics

Another ["Back to basics"][b2b] series we plan on starting next year is an ambitious exploration
into Swift's generics system. We pushed parameter packs to their limits when building our 
[Structured Queries][sq] library, and we think there are many developers out there that could
better leverage their powers if they understood them better. Along the way we will show how 
parameter packs essentially give us anonymous enum types with great ergonomics! 

[sq]: https://github.com/pointfreeco/swift-structured-queries/ 
[b2b]: /collections/back-to-basics

## Cross-platform: Android

And last, but not least, cross-platform Swift recently got a huge boost thanks to the official
[Android SDK][android-sdk]. And over one year ago we dedicated a 7-part series of episodes to
[cross-platform][cross-platform] techniques for sharing code across vastly different platforms,
_e.g._ Apple and Wasm. 

In 2026 we would like to pick back up on cross-platform techniques by showing how to build apps
for Android in a way that shares the maximum amount of code. Doing so even strengthens your code
base for other platforms as it helps you more clearly define the essential features to implement
for your app. 

[android-sdk]: https://www.swift.org/blog/nightly-swift-sdk-for-android/ 
[cross-platform]: /collections/cross-platform-swift

## Subscribe today!

This only scratches the surface of what we plan on covering in 2026. Be sure to
[subscribe today][cyber-week-sale] to get access to all of this and more. The offer is valid for
only a few days, so you'd better hurry!

[cyber-week-sale]: /discounts/eoy-2025

@Button(/discounts/eoy-2025) {
  Subscribe today for 25% off!
}
