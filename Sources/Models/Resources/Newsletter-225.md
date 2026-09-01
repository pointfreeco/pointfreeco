Thanks to the support from our [subscribers] we are able to spend _a lot_ of time maintaining our open source libraries. We often blog about some of our biggest releases, but there are a lot of smaller improvements that fly under the radar, and we don't want to inundate people with daily emails. So, we are going to start recapping our contributions in a monthly, digestible format.

[subscribers]: /pricing

Last month we shipped 40 releases across 16 of our libraries, including major new JSON and collation tools for our modern persistence libraries, the return of preview traits in Dependencies, a new protocol in CasePaths that paves the way for big performance improvements and 2.0, and had contributions from 17 community members, 13 of them first-timers. Here's a recap of everything that happened, and be sure to update your dependencies to take advantage of it all!

* [StructuredQueries: JSON, collations, and VALUES](#structuredqueries-json-collations-and-values)
* [SQLiteData: automatic observation and strictness](#sqlitedata-automatic-observation-and-strictness)
* [Dependencies: preview traits are back, and locales](#dependencies-preview-traits-are-back-and-locales)
* [CasePaths: paving the way for 2.0](#casepaths-paving-the-way-for-2-0)
* [Sharing: slimmer builds with package traits](#sharing-slimmer-builds-with-package-traits)
* [IssueReporting 2.0, everywhere](#issuereporting-2-0-everywhere)
* [And the rest](#and-the-rest)
* [Thank you, contributors](#thank-you-contributors)

## StructuredQueries: JSON, collations, and VALUES

[Structured Queries](https://github.com/pointfreeco/swift-structured-queries) saw seven releases this month (0.35.0 through 0.39.1), primarily focused on bringing full support for JSON and JSONB in SQLite databases:

* **SQLite JSONB support**: store your `Codable` values in SQLite's efficient binary JSON format with a one-line change to your schema, via the new `JSONBRepresentation`.
* **Type-safe JSON functions**: reach into JSON payloads with `jsonExtract`, `jsonSet`, `jsonAppend`, `jsonArrayInsert`, and more, all in a type-safe and schema-safe manner.
* **`jsonEach()`**: query a JSON array or dictionary as a bona fide SQL table, with `where` clauses, `select`s, and everything else the query builder offers.

We covered these tools in depth in a [dedicated blog post](/blog/posts/220-type-safe-json-and-jsonb-in-structuredqueries), but the past month saw a number of other improvements:

* **`@DatabaseCollation`**: define custom collating sequences using plain Swift functions, just as `@DatabaseFunction` lets you define custom SQL functions. Your function can compare two `String`s, or for efficient, zero-copy comparisons it can work directly on [spans](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0447-span-access-shared-contiguous-storage.md):

  ```swift
  @DatabaseCollation
  func canonical(_ lhs: UTF8Span, _ rhs: UTF8Span) -> CollationOrder {
    if lhs.isCanonicallyLessThan(rhs) { return .ascending }
    if rhs.isCanonicallyLessThan(lhs) { return .descending }
    return .same
  }

  db.add(collation: $canonical)

  Reminder.order { $0.title.collate($canonical) }
  // SELECT … FROM "reminders"
  // ORDER BY "reminders"."title" COLLATE "canonical"
  ```

* **Multi-row `VALUES` statements**: SQLite's true `VALUES` statement is now supported, usable in unions and common table expressions, along with improvements to the insert values builder, including inserting grouped column types:

  ```swift
  Values {
    (1, "Hello", true)
    (2, "Goodbye", false)
  }
  // VALUES (1, 'Hello', 1), (2, 'Goodbye', 0)
  ```

* **Type-safe date and time helpers**: SQLite's `date`, `time`, `datetime`, and friends, now available directly from the query builder with type safety, including `strftime` formatting:

  ```swift
  Reminder.where { $0.createdAt > .now(.days(-7)) }
  // SELECT … FROM "reminders"
  // WHERE (("reminders"."createdAt") > (datetime('now', '-7 days', 'subsec')))

  Reminder.select { $0.createdAt.strftime("%Y-%m") }
  // SELECT strftime('%Y-%m', "reminders"."createdAt")
  // FROM "reminders"
  ```
* **Throwing query decoding**: decoding can now throw on type mismatch rather than silently coercing, and it uses typed throws for better performance.
* **Performance**: query building improvements, leaner `TableColumns` definitions, and `@DatabaseFunction` macro output that minimizes allocations.
* **Better diagnostics**: new macro diagnostics for `RawRepresentation`, `@Table` enums, and default-`MainActor` modules.

## SQLiteData: automatic observation and strictness

[SQLiteData](https://github.com/pointfreeco/sqlite-data) shipped six releases (1.9.0 through 1.12.0), with two new features:

* **Automatic `@FetchOne` for primary keyed tables**: previously, `@FetchOne` fetched the first row of a table unless you remembered to hand it an explicit query:

  ```swift
  init(profile: Profile) {
    _profile = FetchOne(wrappedValue: profile, Profile.find(profile.id))
  }
  ```

  Now `@FetchOne` automatically observes primary-keyed records, so your views stay in sync with individual records with no extra work, and an entire class of bugs disappears.

* **`StrictDecoding`**: a new trait that throws an error when a decoded field's type doesn't match its SQL affinity, rather than silently coercing. This has already helped us catch a few bugs, and we highly recommend you enable this trait.

Beyond that, the month brought user-defined collating sequences powered by the new `@DatabaseCollation` macro, a `ColumnCoding` passthrough trait, and some serious performance work: `@FetchAll` and `@FetchOne` statements are now cached, and `String`, `Date`, and `UUID` encoding/decoding got faster. There were also fixes for CloudKit record sharing, in-memory metadatabase creation, and a subtle SwiftUI glitch where `@Fetch*` state could break animations.

## Dependencies: preview traits are back, and locales

[Dependencies](https://github.com/pointfreeco/swift-dependencies) shipped four releases (1.15.0 through 1.17.1), and this includes the return of preview traits.

Preview traits have had quite a journey in this library. We [introduced them](https://github.com/pointfreeco/swift-dependencies/pull/274) in late 2024 as a lightweight way to override dependencies in a preview, but we soon [deprecated them](https://github.com/pointfreeco/swift-dependencies/pull/323) upon discovering that Xcode executes preview traits for _every_ preview in a file, not just the one being displayed, allowing one preview's dependencies to trample another's. We then found a fix and [un-deprecated them](https://github.com/pointfreeco/swift-dependencies/pull/353), only to hit further intermittent tooling issues outside our control and [re-deprecate them](https://github.com/pointfreeco/swift-dependencies/pull/368) once more.

We are now [tempting the fates again](https://github.com/pointfreeco/swift-dependencies/pull/465): the dependencies cache is now reset every time a preview trait runs, which prevents one preview from bleeding into another, and dependencies are [eagerly prepared](https://github.com/pointfreeco/swift-dependencies/pull/471) for you. Now you can override traits for a preview simply by doing the following:

```swift
#Preview(
  traits: .dependencies {
    $0.date.now = Date(timeIntervalSince1970: 1234567890)
    $0.continuousClock = .immediate
  }
) {
  TimerView()
}
```

And overriding a single dependency is even more concise:

```swift
#Preview(traits: .dependency(\.continuousClock, .immediate)) {
  TimerView()
}
```

The month's other Dependencies improvements include:

* **`@Dependency(\.preferredLocales)`**: a new dependency for ordered content-language preferences, distinct from the formatting-oriented `locale` dependency.
* **Fire-and-forget improvements** for spinning off work from your features.
* **Improved `@DependencyEntry` diagnostics** and SwiftSyntax 603/604 support.

## CasePaths: paving the way for 2.0

[CasePaths](https://github.com/pointfreeco/swift-case-paths) 1.10.0 introduced a new `CasePath` protocol that paves the way for performance improvements coming in the library's next major release. Libraries that integrate with CasePaths can adopt it today and be ready for 2.0 by updating references of `AnyCasePath` to `some CasePath`:

```diff
 import CasePaths

-KeyPath<Root.AllCasePaths, AnyCasePath<Root, Value>>
+KeyPath<Root.AllCasePaths, some CasePath<Root, Value>>
```

We have already adopted the protocol across [Swift Navigation](https://github.com/pointfreeco/swift-navigation) 2.11.2, [Sharing](https://github.com/pointfreeco/swift-sharing) 2.10.1, [Structured Queries](https://github.com/pointfreeco/swift-structured-queries) 0.39.0, and [Parsing](https://github.com/pointfreeco/swift-parsing) 0.15.1.

## Sharing: slimmer builds with package traits

[Sharing](https://github.com/pointfreeco/swift-sharing) 2.10.0 quarantined its CustomDump and IdentifiedCollections integrations behind Swift package traits, so you can now opt out of the dependencies you don't use for a leaner build:

```swift:4
.package(
  url: "https://github.com/pointfreeco/swift-sharing",
  from: "2.10.0",
  traits: ["CustomDump", "IdentifiedCollections"]
)
```

## IssueReporting 2.0, everywhere

[IssueReporting](https://github.com/pointfreeco/swift-issue-reporting) began life as `xctest-dynamic-overlay`, and completing its rename has been years in the making. All the way back in July 2024 we [renamed the package](https://github.com/pointfreeco/swift-issue-reporting/pull/87) to `swift-issue-reporting`, but we immediately ran into limitations of how packages can be renamed in SPM: the new name [caused dependency conflicts](https://github.com/pointfreeco/swift-issue-reporting/pull/97) across the ecosystem, and we had to revert within a day. These problems seemed insurmountable, and we assumed we would need to wait until we were ready to cut a major release of IssueReporting and simultaneously update **every single** package that depends on it, which means major versions for over a dozen of our libraries all at once.

Luckily, we found a fix for this situation recently. We now maintain `xctest-dynamic-overlay` as a fork of `swift-issue-reporting`, and made it possible to depend on both at the same time. When building with Xcode <27, the legacy `xctest-dynamic-overlay` library is used, and when building with Xcode 27+, the new `swift-issue-reporting` library is used. And this works thanks to some fixes in swift-build made available to Xcode 27.

This allows people to migrate their libraries to `swift-issue-reporting` whenever they have time (there's no rush!), and we have already updated all of our libraries. Most importantly, we were able to do this update with nearly no one noticing, which is impressive considering `swift-issue-reporting` gets about a million clones a week!

## And the rest

* **[CustomDump](https://github.com/pointfreeco/swift-custom-dump) 1.7.0–1.7.3**: first-class dumps for `SwiftUI.Color` and `SIMD2`/`SIMD3`/`SIMD4` values, along with more consistent printing of object identity and number formatting in data byte dumps.
* **[MacroTesting](https://github.com/pointfreeco/swift-macro-testing) 0.7.0**: support for SwiftSyntax's `MacroSpec`, so you can now test things like extension conformances, plus diagnostics on empty nodes.
* **[URLRouting](https://github.com/pointfreeco/swift-url-routing) 0.7.0**: `URLRequestData` is now `Sendable`, a roundtrip bug in GET form query encoding was fixed, and the package got a modernization pass and a Swift Testing migration.
* **[Debug Snapshots](https://github.com/pointfreeco/swift-debug-snapshots) 0.4.1–0.5.0**: our newest library got macro inference improvements, sharper diagnostics for optional and collection references that aren't `DebugSnapshotConvertible`, SwiftSyntax 603/604 support, and no longer emits internal properties on public snapshot types.
* **[Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) 1.26.2**: documentation fixes, including missing `@ObservableState` annotations in the bindings examples.
* **[Swift Navigation](https://github.com/pointfreeco/swift-navigation) 2.11.1–2.11.2** and **[Parsing](https://github.com/pointfreeco/swift-parsing) 0.15.1**: IssueReporting 2.1 support and `CasePath` protocol adoption, plus a Swift Package Index documentation target for Parsing.
* **[Perception](https://github.com/pointfreeco/swift-perception) 2.0.12**, **[Clocks](https://github.com/pointfreeco/swift-clocks) 1.1.1**, and **[Combine Schedulers](https://github.com/pointfreeco/combine-schedulers) 1.2.1**: compatibility bumps and small fixes.

## Thank you, contributors

This month's releases included contributions from 17 community members, 13 of them contributing for the first time. Open source is a huge part of what we do at Point-Free, and we're grateful to everyone who filed issues, opened pull requests, and helped make these libraries better.
