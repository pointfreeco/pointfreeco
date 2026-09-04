Thanks to the support from our [members] we are able to spend _a lot_ of time maintaining our open source libraries. We often blog about some of our biggest releases, but there are a lot of smaller improvements that fly under the radar, and we don't want to inundate people with daily emails. So, we are going to start recapping our contributions in a monthly, digestible format.

[members]: /pricing

Last month we shipped 40 releases across 16 of our libraries, including major new JSON and collation tools for our modern persistence libraries, the return of preview traits in Dependencies, and a new protocol in CasePaths that paves the way for big performance improvements and 2.0. We also had contributions from 17 community members, 13 of them first-timers. Here's a recap of everything that happened, and be sure to update your dependencies to take advantage of it all!

* [StructuredQueries: JSON, collations, and `VALUES`](#structuredqueries-json-collations-and-values)
* [SQLiteData: automatic observation and strictness](#sqlitedata-automatic-observation-and-strictness)
* [Dependencies: preview traits are back, and locales](#dependencies-preview-traits-are-back-and-locales)
* [CasePaths: paving the way for 2.0](#casepaths-paving-the-way-for-2-0)
* [Sharing: slimmer builds with package traits](#sharing-slimmer-builds-with-package-traits)
* [IssueReporting 2.0, everywhere](#issuereporting-2-0-everywhere)
* [Beta Preview: LazyState](#beta-preview-lazystate)
* [And the rest](#and-the-rest)
* [Thank you, contributors](#thank-you-contributors)

## StructuredQueries: JSON, collations, and `VALUES`

[StructuredQueries](https://github.com/pointfreeco/swift-structured-queries) saw seven releases last month (0.35.0 through 0.39.1), primarily focused on bringing full support for JSON and JSONB in SQLite databases:

* **SQLite JSONB support**: store your `Codable` values in SQLite's efficient binary JSON format with a one-line change to your schema, via the new `JSONBRepresentation` ([#321](https://github.com/pointfreeco/swift-structured-queries/pull/321)).
* **Type-safe JSON functions**: reach into JSON payloads with `jsonExtract`, `jsonSet`, `jsonAppend`, `jsonArrayInsert`, and more, all in a type-safe and schema-safe manner ([#324](https://github.com/pointfreeco/swift-structured-queries/pull/324), [#343](https://github.com/pointfreeco/swift-structured-queries/pull/343)).
* **`jsonEach()`**: query a JSON array or dictionary as a bona fide SQL table, with `where` clauses, `select`s, and everything else the query builder offers ([#336](https://github.com/pointfreeco/swift-structured-queries/pull/336)).

We covered these tools in depth in a [dedicated blog post](/blog/posts/220-type-safe-json-and-jsonb-in-structuredqueries), but the past month saw a number of other improvements:

* **`@DatabaseCollation`**: define custom collating sequences using plain Swift functions, just as `@DatabaseFunction` lets you define custom SQL functions. Your function can compare two `String`s, or for efficient, zero-copy comparisons it can work directly on [spans](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0447-span-access-shared-contiguous-storage.md) ([#345](https://github.com/pointfreeco/swift-structured-queries/pull/345)):

  ```swift
  @DatabaseCollation
  func canonical(_ lhs: UTF8Span, _ rhs: UTF8Span) -> CollationOrder {
    if lhs.isCanonicallyLessThan(rhs) { 
      return .ascending 
    }
    if rhs.isCanonicallyLessThan(lhs) { 
      return .descending
    }
    return .same
  }

  db.add(collation: $canonical)
  ```
  
  Once your collation is defined and added to the database connection you can use in any query:

  <table>
  <tr>
  <th>Swift</th>
  <th>SQL</th>
  </tr>
  <tr valign=top>
  <td width=50%>

  ```swift
  Reminder.order { 
    $0.title.collate($canonical) 
  }
  
  ```

  </td>
  <td width=50%>

  ```sql
  SELECT …
  FROM "reminders"
  ORDER BY 
    "reminders"."title"  COLLATE "canonical"  
  ```

  </td>
  </tr>
  </table>

* **Multi-row `VALUES` statements**: SQLite's true `VALUES` statement is now supported, usable in unions and common table expressions, along with improvements to the insert values builder, including inserting grouped column types ([#359](https://github.com/pointfreeco/swift-structured-queries/pull/359)):

  <table>
  <tr>
  <th>Swift</th>
  <th>SQL</th>
  </tr>
  <tr valign=top>
  <td width=50%>

  ```swift
  Values {
    (1, "Hello", true)
    (2, "Goodbye", false)
  }
  ```

  </td>
  <td width=50%>

  ```sql
  VALUES 
    (1, 'Hello', 1), 
    (2, 'Goodbye', 0)
    
  ```

  </td>
  </tr>
  </table>

* **Type-safe date and time helpers**: SQLite's `date`, `time`, `datetime`, and friends, now available directly from the query builder with type safety, including `strftime` formatting ([#358](https://github.com/pointfreeco/swift-structured-queries/pull/358)):

  <table>
  <tr>
  <th>Swift</th>
  <th>SQL</th>
  </tr>
  <tr valign=top>
  <td width=50%>

  ```swift
  Reminder.where { 
    $0.createdAt > .now(.days(-7)) 
  }


  Reminder.select { 
    $0.createdAt.strftime("%Y-%m") 
  }
  ```

  </td>
  <td width=50%>

  ```sql
  SELECT … 
  FROM "reminders"
  WHERE 
    "reminders"."createdAt" > datetime('now', '-7 days', 'subsec')

  SELECT 
    strftime('%Y-%m', "reminders"."createdAt")
  FROM "reminders"
  ```

  </td>
  </tr>
  </table>

* **Throwing query decoding**: decoding can now throw on type mismatch rather than silently coercing ([#310](https://github.com/pointfreeco/swift-structured-queries/pull/310)), and it uses typed throws for better performance ([#339](https://github.com/pointfreeco/swift-structured-queries/pull/339)).
* **Performance**: query building improvements ([#351](https://github.com/pointfreeco/swift-structured-queries/pull/351)), leaner `TableColumns` definitions ([#352](https://github.com/pointfreeco/swift-structured-queries/pull/352)), and `@DatabaseFunction` macro output that minimizes allocations ([#360](https://github.com/pointfreeco/swift-structured-queries/pull/360)).
* **Better diagnostics**: new macro diagnostics for `RawRepresentation` ([#340](https://github.com/pointfreeco/swift-structured-queries/pull/340)), `@Table` enums ([#331](https://github.com/pointfreeco/swift-structured-queries/pull/331)), and default-`MainActor` modules ([#344](https://github.com/pointfreeco/swift-structured-queries/pull/344)).

## SQLiteData: automatic observation and strictness

[SQLiteData](https://github.com/pointfreeco/sqlite-data) shipped six releases (1.9.0 through 1.12.0), with two new features:

* **Automatic `@FetchOne` for primary keyed tables**: previously, `@FetchOne` fetched the first row of a table unless you remembered to hand it an explicit query:

  ```swift
  init(profile: Profile) {
    _profile = FetchOne(wrappedValue: profile, Profile.find(profile.id))
  }
  ```

  Now `@FetchOne` automatically observes primary-keyed records, which means SwiftUI views typically can omit the initializer entirely and rely on the synthesized initializer, and non-views can shorten their initializers to: 

  ```swift
  init(profile: Profile) {
    _profile = FetchOne(wrappedValue: profile)
  }
  ```
  
  This will still fetch the profile by its primary key and then observe changes to the profile in the database ([#519](https://github.com/pointfreeco/sqlite-data/pull/519)).
  
* **`StrictDecoding`**: a new trait that throws an error when a decoded field's type doesn't match its SQL affinity, rather than silently coercing ([#489](https://github.com/pointfreeco/sqlite-data/pull/489)). This has already helped us catch a few bugs, and we highly recommend you enable this trait.

Beyond that, the month brought user-defined collating sequences powered by the new `@DatabaseCollation` macro ([#532](https://github.com/pointfreeco/sqlite-data/pull/532)), a `ColumnCoding` passthrough trait ([#520](https://github.com/pointfreeco/sqlite-data/pull/520)), and some serious performance work: `@FetchAll` and `@FetchOne` statements are now cached ([#527](https://github.com/pointfreeco/sqlite-data/pull/527)), and `String`, `Date`, and `UUID` encoding/decoding got faster ([#528](https://github.com/pointfreeco/sqlite-data/pull/528)). There were also fixes for CloudKit record sharing ([#409](https://github.com/pointfreeco/sqlite-data/pull/409)), in-memory metadatabase creation ([#508](https://github.com/pointfreeco/sqlite-data/pull/508)), and a subtle SwiftUI glitch where `@Fetch*` state could break animations ([#504](https://github.com/pointfreeco/sqlite-data/pull/504)).

## Dependencies: preview traits are back, and locales

[Dependencies](https://github.com/pointfreeco/swift-dependencies) shipped four releases (1.15.0 through 1.17.1), and this includes the return of preview traits.

Preview traits have had quite a journey in this library. We [introduced them](https://github.com/pointfreeco/swift-dependencies/pull/274) in late 2024 as a lightweight way to override dependencies in a preview, but we soon [deprecated them](https://github.com/pointfreeco/swift-dependencies/pull/323) upon discovering that Xcode executes preview traits for _every_ preview in a file, not just the one being displayed, allowing one preview's dependencies to trample another's. We then found a fix and [un-deprecated them](https://github.com/pointfreeco/swift-dependencies/pull/353), only to hit further intermittent tooling issues outside our control and [re-deprecate them](https://github.com/pointfreeco/swift-dependencies/pull/368) once more.

We are now [tempting the fates again](https://github.com/pointfreeco/swift-dependencies/pull/465): the dependencies cache is now reset every time a preview trait runs, which prevents one preview from bleeding into another, and dependencies are [eagerly prepared](https://github.com/pointfreeco/swift-dependencies/pull/471) for you. Now you can override dependencies for a preview simply by doing the following:

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

* **`@Dependency(\.preferredLocales)`**: a new dependency for ordered content-language preferences, distinct from the formatting-oriented `locale` dependency ([#468](https://github.com/pointfreeco/swift-dependencies/pull/468)).
* **Fire-and-forget improvements** for spinning off work from your features ([#454](https://github.com/pointfreeco/swift-dependencies/pull/454)).
* **Improved `@DependencyEntry` diagnostics** ([#460](https://github.com/pointfreeco/swift-dependencies/pull/460)) and SwiftSyntax 603/604 support ([#461](https://github.com/pointfreeco/swift-dependencies/pull/461)).

## CasePaths: paving the way for 2.0

[CasePaths](https://github.com/pointfreeco/swift-case-paths) 1.10.0 introduced a new `CasePath` protocol ([#255](https://github.com/pointfreeco/swift-case-paths/pull/255)) that paves the way for performance improvements coming in the library's next major release. Libraries that integrate with CasePaths can adopt it today and be ready for 2.0 by updating references of `AnyCasePath` to `some CasePath`:

```diff
 import CasePaths

-KeyPath<Root.AllCasePaths, AnyCasePath<Root, Value>>
+KeyPath<Root.AllCasePaths, some CasePath<Root, Value>>
```

We have already adopted the protocol across [SwiftNavigation](https://github.com/pointfreeco/swift-navigation) 2.11.2, [Sharing](https://github.com/pointfreeco/swift-sharing) 2.10.1, [StructuredQueries](https://github.com/pointfreeco/swift-structured-queries) 0.39.0, and [Parsing](https://github.com/pointfreeco/swift-parsing) 0.15.1.

## Sharing: slimmer builds with package traits

[Sharing](https://github.com/pointfreeco/swift-sharing) 2.10.0 quarantined its CustomDump and IdentifiedCollections integrations behind Swift package traits ([#225](https://github.com/pointfreeco/swift-sharing/pull/225), [#226](https://github.com/pointfreeco/swift-sharing/pull/226)), so you can now opt out of the dependencies you don't use for a leaner build:

```swift:4
.package(
  url: "https://github.com/pointfreeco/swift-sharing",
  from: "2.10.0",
  traits: [
    // Choose which traits to keep:
    // "CasePaths",
    // "CustomDump", 
    // "IdentifiedCollections",
  ]
)
```

## IssueReporting 2.0, everywhere

[IssueReporting](https://github.com/pointfreeco/swift-issue-reporting) began life as `xctest-dynamic-overlay`, and completing its rename has been years in the making. All the way back in July 2024 we [renamed the package](https://github.com/pointfreeco/swift-issue-reporting/pull/87) to `swift-issue-reporting`, but we immediately ran into limitations of how packages can be renamed in SPM: the new name [caused dependency conflicts](https://github.com/pointfreeco/swift-issue-reporting/pull/97) across the ecosystem, and we had to revert within a day. These problems seemed insurmountable, and we assumed we would need to wait until we were ready to cut a major release of IssueReporting and simultaneously update **every single** package that depends on it, which means coordinating major versions for over a dozen of our libraries all at once.

Luckily, we found a fix for this situation recently. We now maintain `xctest-dynamic-overlay` as a fork of `swift-issue-reporting`, and made it possible to depend on both at the same time. When building with Xcode <27, the legacy `xctest-dynamic-overlay` library is used, and when building with Xcode 27+, the new `swift-issue-reporting` library is used. And this works thanks to some fixes in swift-build made available to Xcode 27.

This allows people to migrate their libraries to `swift-issue-reporting` whenever they have time (there's no rush!), and we have already updated all of our libraries. Most importantly, we were able to do this update with nearly no one noticing, which is impressive considering `swift-issue-reporting` gets about a million clones a week!

## Beta Preview: LazyState

We also announced the newest addition to [Beta Previews](/beta-previews): **LazyState**, a micro-library that brings the new laziness of SwiftUI's `@State` macro to state that must be initialized dynamically with data from a parent view. The `@LazyState` macro lets you create state once per view lifetime without forcing your model to become optional, stashing initialization inputs in extra properties, or moving setup into `onAppear`.

Here is an example of the clean up we can perform in Apple's [SampleTrips] demo app thanks to `@LazyState`:

[SampleTrips]: https://developer.apple.com/videos/play/wwdc2026/278

```diff
struct LocationSearchSheet: View {
-  @State private var completer: LocationSearchCompleter?
+  @LazyState private var completer: LocationSearchCompleter

-  var region: MKCoordinateRegion?
+  init(region: MKCoordinateRegion?) {
+    _completer = LazyState {
+      LocationSearchCompleter(region: region)
+    }
+  }

  var body: some View {
    VStack {
-      TextField("Search", text: query)
+      TextField("Search", text: $completer.query)

      List {
-        ForEach(completer?.results ?? []) {
+        ForEach(completer.results) {
          …
        }
      }
    }
-    .onAppear {
-      completer = LocationSearchCompleter(region: region)
-    }
  }
-
-  private var query: Binding<String> {
-    Binding(
-      get: { completer?.query ?? "" },
-      set: { completer?.query = $0 }
-    )
-  }
-
}
```

`@LazyState` works like `@State`, including normal binding derivation through `$completer`, but closes the gap Apple left for dynamically initialized state. It is available today as a [Beta Preview](/beta-previews) for [Point-Free Max](/pricing) members, and you can read the full announcement in [Beta Preview: LazyState](/blog/posts/223-beta-preview-lazystate).

## And the rest

* **[CustomDump](https://github.com/pointfreeco/swift-custom-dump) 1.7.0–1.7.3**: first-class dumps for `SwiftUI.Color` ([#171](https://github.com/pointfreeco/swift-custom-dump/pull/171)) and `SIMD2`/`SIMD3`/`SIMD4` values ([#165](https://github.com/pointfreeco/swift-custom-dump/pull/165)), along with more consistent printing of object identity ([#170](https://github.com/pointfreeco/swift-custom-dump/pull/170)) and number formatting in data byte dumps ([#163](https://github.com/pointfreeco/swift-custom-dump/pull/163)).
* **[MacroTesting](https://github.com/pointfreeco/swift-macro-testing) 0.7.0**: support for SwiftSyntax's `MacroSpec`, so you can now test things like extension conformances ([#55](https://github.com/pointfreeco/swift-macro-testing/pull/55)), plus diagnostics on empty nodes ([#54](https://github.com/pointfreeco/swift-macro-testing/pull/54)).
* **[URLRouting](https://github.com/pointfreeco/swift-url-routing) 0.7.0**: `URLRequestData` is now `Sendable` ([#112](https://github.com/pointfreeco/swift-url-routing/pull/112)), a roundtrip bug in GET form query encoding was fixed ([#121](https://github.com/pointfreeco/swift-url-routing/pull/121)), and the package got a modernization pass ([#119](https://github.com/pointfreeco/swift-url-routing/pull/119)) and a Swift Testing migration ([#122](https://github.com/pointfreeco/swift-url-routing/pull/122)).
* **[DebugSnapshots](https://github.com/pointfreeco/swift-debug-snapshots) 0.4.1–0.5.0**: our newest library got macro inference improvements ([#34](https://github.com/pointfreeco/swift-debug-snapshots/pull/34)), sharper diagnostics for optional and collection references that aren't `DebugSnapshotConvertible` ([#27](https://github.com/pointfreeco/swift-debug-snapshots/pull/27), [#28](https://github.com/pointfreeco/swift-debug-snapshots/pull/28)), SwiftSyntax 603/604 support ([#29](https://github.com/pointfreeco/swift-debug-snapshots/pull/29)), and no longer emits internal properties on public snapshot types ([#33](https://github.com/pointfreeco/swift-debug-snapshots/pull/33)).
* **[ComposableArchitecture](https://github.com/pointfreeco/swift-composable-architecture) 1.26.2**: documentation fixes, including missing `@ObservableState` annotations in the bindings examples ([#3956](https://github.com/pointfreeco/swift-composable-architecture/pull/3956)).
* **[SwiftNavigation](https://github.com/pointfreeco/swift-navigation) 2.11.1–2.11.2** and **[Parsing](https://github.com/pointfreeco/swift-parsing) 0.15.1**: IssueReporting 2.1 support ([#367](https://github.com/pointfreeco/swift-navigation/pull/367)) and `CasePath` protocol adoption ([#373](https://github.com/pointfreeco/swift-navigation/pull/373), [#396](https://github.com/pointfreeco/swift-parsing/pull/396)), plus a Swift Package Index documentation target for Parsing ([#391](https://github.com/pointfreeco/swift-parsing/pull/391)).
* **[Perception](https://github.com/pointfreeco/swift-perception) 2.0.12** ([#174](https://github.com/pointfreeco/swift-perception/pull/174), [#179](https://github.com/pointfreeco/swift-perception/pull/179)), **[Clocks](https://github.com/pointfreeco/swift-clocks) 1.1.1** ([#58](https://github.com/pointfreeco/swift-clocks/pull/58)), and **[CombineSchedulers](https://github.com/pointfreeco/combine-schedulers) 1.2.1** ([#117](https://github.com/pointfreeco/combine-schedulers/pull/117), [#118](https://github.com/pointfreeco/combine-schedulers/pull/118)): compatibility bumps and small fixes.

## Thank you, contributors

Last month's releases included contributions from 17 community members, 13 of them contributing for the first time. Open source is a huge part of what we do at Point-Free, and we're grateful to everyone who filed issues, opened pull requests, and helped make these libraries better.
