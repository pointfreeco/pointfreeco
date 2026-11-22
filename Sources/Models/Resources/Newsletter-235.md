Point-Free offers the most advanced and original Swift content out there, and we maintain open
source libraries used by tens of thousands of developers. To get a jump start on perfecting your
expertise in Swift for 2027, we are offering a [Black Friday **30% discount**][black-friday-sale]
off the first year of a new Point-Free membership:

[black-friday-sale]: /discounts/black-friday-2026

@Button(/discounts/black-friday-2026) {
  Save 30% on Point-Free
}

This discount also works for [Point-Free Max](/discounts/black-friday-2026?plan=max) and 
[1 year gifts](/gifts)!

Once you join you'll get instant access to all [389+ episodes](/) of original
Point-Free content. This includes the 41 episodes we have released so far in 2026, where we went
deeper into Swift concurrency than we ever have before, disected some of WWDC's biggest 
announcements, and built real-world tools from scratch along the way.

This year we also shipped many new features for our members and shepherded hundreds of open source
releases. Here's everything you get access to the moment you join:

- [This year in episodes](#this-year-in-episodes)
  - [Tour of SQLiteData](#tour-of-sqlitedata)
  - [Point-Free turns 8](#point-free-turns-8)
  - [Beyond Basics](#beyond-basics)
  - [Beyond Basics: Isolation](#beyond-basics-isolation)
  - [WWDC26](#wwdc26)
  - [Designing for Isolation](#designing-for-isolation)
- [More in the Point-Free ecosystem](#more-in-the-point-free-ecosystem)
  - [The Point-Free Way](#the-point-free-way)
  - [Point-Free Max](#point-free-max)
  - [Beta Previews](#beta-previews)
  - [Office Hours](#office-hours)
  - [Episode search](#episode-search)
  - [No GitHub account required](#no-github-account-required)
- [A whole lotta open source](#a-whole-lotta-open-source)
- [Coming in 2027](#coming-in-2027)
  - [Controllable time-based asynchrony done right](#controllable-time-based-asynchrony-done-right)
  - [Beyond Basics: Ownership](#beyond-basics-ownership)
  - [ComposableArchitecture 2.0](#composablearchitecture-2-0)
  - [A new SQLite driver](#a-new-sqlite-driver)
- [Become a member today](#become-a-member-today)

## This year in episodes

### Tour of SQLiteData

We started 2026 with a bang! Hot on the heels of the 1.0 release of [SQLiteData], our SwiftData
alternative built on battle-tested SQLite, we gave a [7-part tour][sqlite-data-tour] of the library
by building a moderately complex app from scratch. We showed how to:

* Model your domain with simple structs and enums instead of classes
* Precisely control how data is fetched and loaded in your views and observable models
* Store larger blobs of data, such as photos, alongside your tables
* Add iCloud synchronization _and_ collaborative sharing in mere minutes
* Take full advantage of Xcode previews even when CloudKit APIs are involved
* Get full test coverage on your data layer, including the seemingly impossible, a test against
  iCloud sharing!

[SQLiteData]: https://github.com/pointfreeco/sqlite-data
[sqlite-data-tour]: /collections/tours/tour-of-sqlitedata

### Point-Free turns 8

In February we celebrated 8 years of Point-Free with a [live stream][pfw-live]. We took our brand
new "[Point-Free Way](#the-point-free-way)" skill documents for a spin by building a flashcards app
powered by SQLiteData, gave a live sneak peek of ComposableArchitecture 2.0, and answered a _lot_
of viewer questions.

[pfw-live]: /episodes/ep354-the-point-free-way-live

### Beyond Basics

We kicked off a brand new series called "Beyond Basics" that aims to get to the heart of some
very advanced topics in Swift. To introduce the series, we released 2 episodes to give a broad
overview of these kinds of topics we will be covering: 

* [**Isolation, ~Copyable, ~Escapable**](/episodes/ep355-beyond-basics-isolation-copyable-escapable): 
A quick demo of how modern Swift concurrency and strict control over isolation has allowed us to 
unlock a great deal of power in the upcoming ComposableArchitecture 2.0.
* [**Superpowers**](/episodes/ep356-beyond-basics-superpowers): An overview of how isolation, 
`~Copyable` and `~Escapable` can unlock a great deal of power in library design, and force users to
interact with your APIs in the safest way possible.

### Beyond Basics: Isolation

Building off that two-part introduction we dive head first into Swift isolation. This 
[13-part series][isolation] is one of the most comprehensive overviews of an 
important, yet sadly misunderstood concept in Swift.

We started from first principles by analyzing a simple data race, and working our way through every
tool Swift gives us to fix it:

* **Locks**: We discuss wide spectrum of locking mechanisms, from legacy to modern, including
  `NSLock`,
  `OSAllocatedUnfairLock`, and `Mutex`. Each tool improves upon the last by plugging up potential
  problems while still allowing for more valid use cases.
* **Actors**: We demonstrate how actors work behind the scenes by digging into their enqueueing 
  mechanism, which allows us to understand re-entrancy at a deeper level, as well as how to squash
  unwanted suspension points.
* **Performance**: Let's just say, reports of locks being more performant than actors are over exagerated. 🙂
* **Approachable concurrency**: We show how `nonisolated(nonsending)` allows us to squash
  unwanted suspension points, and this will be a critical tool we use in many upcoming episodes.
* **Region-based isolation**: A deep analysis of how region-based isolation works with many 
  examples and dissections of how seemingly unsafe code is actually totally safe, as well as the
  reverse!

By the end of the series you will understand how actors work and how they can help you write
safe, synchronous, lock-free code, and why it's a good thing to embrace non-`Sendable` types
whereever possible.

[beyond-basics]: /collections/beyond-basics
[isolation]: /collections/beyond-basics/isolation

### WWDC26

Our take on WWDC26! We dedicated [10 episodes][wwdc26] to the most interesting announcements of
the year, and how they relate to the tools and techniques we cover on Point-Free, as well as a
few ways to further improve the new tools:

* **SwiftUI's new alert API**: A new API for alerts in SwiftUI improves domain modeling, and was 
  even inspired by our very own tools, but we show how to take it even further with a little help 
  from [SwiftNavigation].
* **UIKit improvements**: UIKit adopted more of the Observation framework, and we showed how to 
  bring SwiftUI-like state-driven navigation, animations, and transactions to it.
* **SwiftData**: The native data persistence framework for Apple platforms gained sectioning, 
  better `Codable` support, and observation outside of views. We show that these are all tools that 
  have existed in our popular SQLiteData library for a long time, and we even have pushed the tools 
  further with type-safe JSON in a SQLite schema, as well as advanced queries that are just not 
  possible in SwiftData. 
* **The `@State` macro**: This new macro replaced the property wrapper that has been in SwiftUI 
  since the beginning. We picked apart its cryptic expansion to see how it works, uncovered a use 
  case it _doesn't_ support, and built a `@LazyState` macro to close the gap.

We even packaged up `@LazyState` into an [open source library](#beta-previews), and the entire 
series is now [free for everyone to watch][wwdc26].

[wwdc26]: /collections/wwdc/wwdc-2026
[SwiftNavigation]: https://github.com/pointfreeco/swift-navigation





### Designing for Isolation

We can talk about the theory of Swift isolation for weeks on end, but at the end of the day it's 
nice to bring things back down to Earth. So, in 
"[Nonisolated core, isolated shell][designing-for-isolation]" we took everything we learned about
isolation and applied it to a real-world code base by building ComposableArchitecture 2.0's
reimagined `Store` from scratch.

We showed why the 1.0 store's approach to sendability is not ideal, how modern tools like
`nonisolated(nonsending)` and `Task.immediate` get us closer, and then introduced a pattern
inspired by Gary Bernhardt's "functional core, imperative shell" that allows us to write the core
of our feature logic in the wonderful world of non-`Sendable` types, and then host the feature
in an isolated shell. This allowed us to massively parallelize our tests, something that cannot
be easily done in vanilla SwiftUI.

And that isn't the only example of designing with isolation in the mind from the beginning.
Our [current series][designing-for-isolation-notifications] applies the
same ideas to another real-world problem: notifications. We explore the decades-old
`NotificationCenter`, the revamped notifications API from Swift 6.2, and then build a modern,
testable alternative from scratch that keeps the pros of each with none of the cons.

[designing-for-isolation]: /collections/beyond-basics/designing-for-isolation
[designing-for-isolation-notifications]: /collections/beyond-basics/designing-for-isolation-notifications





## More in the Point-Free ecosystem

We added a bunch of new features to Point-Free in 2026 for all of our members:

### The Point-Free Way

[The Point-Free Way][the-way] is a collection of skill documents that teach your AI agents how to
best use our open source libraries and employ the patterns we've discussed over the past 8 years:
simple, composable units, value types over reference types, controlled dependencies, and making
_everything_ testable.

Get started with 3 simple commands:

```sh
brew install pointfreeco/tap/pfw
pfw login
pfw install
```

This installs the skills into whichever AI tool you use (Claude, Codex, Gemini, _etc._). And we are
constantly updating them. Whenever we answer a question from the community or add a new feature to
one of our libraries, we encode it into the skills, and the update is just a `pfw install` away.

[the-way]: /the-way

### Point-Free Max

This year we introduced a new membership tier for our most die-hard fans, and for folks who want to
better support the continued development of our open source libraries.
[Point-Free Max][pricing] members get everything in a regular membership, plus access to our 
[Beta Previews](#beta-previews) and [Office Hours](#office-hours).

[pricing]: /pricing

### Beta Previews

[Beta Previews] give Max members early access to our libraries before they go public. You get an
invitation to the private repo, where you can pull the library into your own projects, give
feedback on its design, and influence its direction before it's locked in. We launched with two
betas in April and have released 2 more since then:

* **[ComposableArchitecture 2.0][tca2]**: Our biggest release ever, and the one many of you have
  been waiting for. A fundamental redesign with the `@Feature` macro, and improved model for
  for async work, lifecycle hooks (`onMount`, `onDismount`), new communication patterns for
  features, and a whole lot less boilerplate.

* **[DebugSnapshots]**: Exhaustive testing for reference types, such as `@Observable` classes. It
  was the first library to [graduate][debug-snapshots-public] from Beta Previews to the public:

  ```swift
  @Test func increment() async {
    let model = FeatureModel()

    expect(model) {
      model.incrementButtonTapped()
    } changes: {
      $0.count = 1
    }
  }
  ```

* **[LazyState]**: Born out of our [WWDC26][wwdc26] series, the `@LazyState` macro picks up where
  SwiftUI's new `@State` macro left off by allowing state to be initialized lazily _and_ dynamically
  from data passed in by the parent view. It [graduated to 1.0][lazy-state-1.0] in September:

  ```swift
  struct LocationSearchSheet: View {
    @LazyState private var completer: LocationSearchCompleter

    init(region: MKCoordinateRegion?) {
      _completer = LazyState { LocationSearchCompleter(region: region) }
    }

    …
  }
  ```

* **[CompilationTesting]**: Our newest beta. Write unit tests for Swift code that should _not_
  compile, and snapshot the compiler's errors, warnings, and fix-its directly in your test file:

  ```swift
  @Test func `diagnose non-Equatable fields`() async {
    await assertCompilation {
      """
      import Equatable
      struct Avatar {}
      @DeriveEquatable struct User {
        var avatar: Avatar
      }
      """
    } diagnostics: {
      """
      import Equatable
      struct Avatar {}
      @DeriveEquatable struct User {
        var avatar: Avatar
        ˄
        ╰─ error: 'Avatar' does not conform to 'Equatable' (from macro 'EquatableCheck')
      }
      """
    }
  }
  ```

[Beta Previews]: /beta-previews
[tca2]: /blog/posts/206-beta-preview-composablearchitecture-2-0
[DebugSnapshots]: https://github.com/pointfreeco/swift-debug-snapshots
[debug-snapshots-public]: /blog/posts/207-debugsnapshots-public-beta
[LazyState]: https://github.com/pointfreeco/swiftui-lazy-state
[lazy-state-1.0]: /blog/posts/228-lazystate-1-0-now-available-to-everyone
[CompilationTesting]: /blog/posts/234-beta-preview-compilationtesting

### Office Hours

[Office Hours][office-hours] are periodic livestreams, exclusively for Max members, where we hang
out and answer your questions in a smaller, more casual setting than our public livestreams.
Members can submit questions ahead of time and vote on what we should cover. Every session is
recorded, and every answered question is linked to the exact moment in the recording where we
discussed it.

[office-hours]: /office-hours

### Episode search

One of our most requested features [finally arrived][search-blog]: full-text
[search] across everything we have ever produced. Every word of every transcript is indexed, from
our dialogue to the code we write on screen, and results deep-link to the precise moment we said
or typed it. If you remember us covering an API, a concept, or a snippet of code, it's now just a
query away.

[search]: /search
[search-blog]: /blog/posts/222-announcing-episode-search

### No GitHub account required

For 8 years the only way into Point-Free was through GitHub. No longer! You can now
[sign up and log in][email-login] with nothing but your email address and a one-time code, and
optionally connect a GitHub account later.

[email-login]: /blog/posts/221-github-account-no-longer-required


## A whole lotta open source

Your membership directly supports the development and maintenance of our open source libraries,
and this year was a busy one:

* [Sectioned queries] in SQLiteData and [type-safe JSON and JSONB] in StructuredQueries
* An [`@DependencyEntry` macro] for registering dependencies with far less boilerplate
* [New macros for SwiftNavigation]: `@CaseBindable` and `@UITransactionEntry`
* [Task-local test traits] for Swift Testing, which we have also [proposed] for Swift Testing
  itself
* ["Trait-ifying" our libraries] so that you can opt out of the pieces you don't need
* [Xcode 27 support] across the ecosystem within days of the first betas
* A blog series on [advanced techniques in Swift macros]
* And a [sometimes-monthly newsletter] that puts the spotlight on the smaller, but important,
  work that doesn't always get much attention

[Sectioned queries]: /blog/posts/219-new-in-sqlitedata-sectioned-queries
[type-safe JSON and JSONB]: /blog/posts/220-type-safe-json-and-jsonb-in-structuredqueries
[`@DependencyEntry` macro]: /blog/posts/213-introducing-dependencyentry
[New macros for SwiftNavigation]: /blog/posts/215-new-macros-for-swiftnavigation
[Task-local test traits]: /blog/posts/209-tasklocal-test-traits
[proposed]: /blog/posts/217-proposing-task-local-test-traits-for-swift-testing
["Trait-ifying" our libraries]: /blog/posts/216-trait-ifying-our-libraries-to-reduce-transitive-dependencies
[Xcode 27 support]: /blog/posts/218-xcode-27-support-in-the-point-free-ecosystem
[advanced techniques in Swift macros]: /blog/posts/231-advanced-techniques-in-swift-macros
[sometimes-monthly newsletter]: /blog/posts/225-last-month-in-point-free-august


## Coming in 2027

And we have some incredible advanced content lined up for 2027, including:

### Controllable time-based asynchrony, done right!

Our [current series][designing-for-isolation-notifications] on notifications is not the last time
we will design a tool with isolation in mind from the very beginning. Next we are turning our
attention to an old friend: clocks.

We first [explored clocks][clocks-collection] years ago, where we showed that by controlling time,
rather than letting it control you, it is possible to write fast, focused tests for timers,
debouncing, timeouts, and more. We even codified all of these ideas into our open source package, 
[Clocks]. But test clocks in Swift have never truly been 100% deterministic due to a lack of 
certain concurrency tools in Swift.

It turns out that the very same technique that powers our notification center can finally provide
a 100% determinstic test clock in Swift. By capturing the surrounding isolation of the code 
interacting with the clock, we can finally build test clocks the right way, and it is yet another
demonstration of the power that comes from strictly controlling isolation in Swift.

[clocks-collection]: /collections/concurrency/clocks
[Clocks]: https://github.com/pointfreeco/swift-clocks

### Beyond Basics: Ownership

Isolation was just the first stop in our "[Beyond Basics][beyond-basics]" collection. Next we will
take a deep dive into Swift's ownership model, including `~Copyable` and `~Escapable` types, so
that these features can feel practical rather than mysterious. We gave a small
[preview][beyond-basics-superpowers] of the superpowers they unlock earlier this year, and there is
a lot more to explore.

[beyond-basics-superpowers]: /episodes/ep356-beyond-basics-superpowers

### ComposableArchitecture 2.0

The beta has been in the hands of our Max members since April, and we can't wait to get it into
the hands of everyone.

### A new SQLite driver

We are working on a new SQLite driver for Swift that brings an unparalleled suite of testing and
debugging tools to applications. It will take advantage of everything we learn about isolation,
`~Copyable` types and `~Escapable` types, and we think it is going to raise the bar for what Swift
developers should expect from persistence tooling.



## Become a member today

[Become a member today](/discounts/black-friday-2026) to take advantage of the **30% off** Black
Friday sale before it ends.

@Button(/discounts/black-friday-2026?billing=yearly&plan=max) {
  Save 30% on Point-Free Max
}

@Button(/discounts/black-friday-2026) {
  Save 30% on Point-Free Pro
}
