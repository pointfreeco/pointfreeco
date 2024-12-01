We are excited to announce a brand new open-source library: [Sharing][sharing-gh]. Instantly share 
state among your app's features and external persistence layers, including user defaults, the file 
system, and more.

These tools were originally incubated in our [Composable Architecture][tca-gh] library, and have
been used by thousands of developers for the past 6 months who provided invaluable feedback. We
are excited to extract the tools out into their own dedicated library so that they can be used in 
any iOS or macOS app, and even cross-platform! 

[tca-gh]: https://github.com/pointfreeco/swift-composable-architecture

## Introducing @Shared

The library comes with one primary tool, the `@Shared` property wrapper, which aids in sharing
state with multiple parts of your application and persisting data to external storage systems, such
as user defaults, the file system, and more. The tool works in a variety of contexts, such as 
SwiftUI views, `@Observable` models, and UIKit view controllers, non-Apple platforms,
and it is completely unit testable.

As a simple example, you can have two different obsevable models hold onto a collection of 
data that is also synchronized to the file system:

```swift
// MeetingsList.swift
@Observable
class MeetingsListModel {
  @ObservationIgnored
  @Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
}

// ArchivedMeetings.swift
@Observable
class ArchivedMeetingsModel {
  @ObservationIgnored
  @Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
}
```

> Note: Due to the fact that Swift macros do not play nicely with property wrappers, you must 
annotate each `@Shared` with `@ObservationIgnored`. Views will still update when shared state 
changes since `@Shared` handles its own observation.

If either model makes a change to `meetings`, the other model will instantly see those changes.
And further, if the file on disk changes from an external write, both instances of `@Shared` will
also update to hold the freshest data.

### Automatic persistence

The [`@Shared`][shared-article] property wrapper gives you a succinct and consistent way to persist 
any kind of data in your application. The library comes with 3 strategies:
[`appStorage`][app-storage-key-docs], 
[`fileStorage`][file-storage-key-docs], and
[`inMemory`][in-memory-key-docs]. 

[shared-article]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/shared
[app-storage-key-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/appstoragekey
[file-storage-key-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/filestoragekey
[in-memory-key-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/inmemorykey


The [`appStorage`][app-storage-key-docs] strategy is useful for store small
pieces of simple data in user defaults, such as settings:

```swift
@Shared(.appStorage("soundsOn")) var soundsOn = true
@Shared(.appStorage("hapticsOn")) var hapticsOn = true
@Shared(.appStorage("userOrder")) var userOrder = UserOrder.name
```

The [`fileStorage`][file-storage-key-docs] strategy is useful
for persisting more complex data types to the file system by serializing the data to bytes:

```swift
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
```

And the [`inMemory`][in-memory-key-docs] strategy is useful for sharing any kind
of data globably with the entire app, but it will be reset the next time the app is relaunched:

```swift
@Shared(.inMemory("events")) var events: [String] = []
```

See ["Persistence strategies"][persistence-docs] for more information on leveraging the persistence 
strategies that come with the library, as well as creating your own strategies.

[persistence-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/persistencestrategies

### Use anywhere

It is possible to use `@Shared` state essentially anywhere, including observable models, SwiftUI
views, UIKit view controllers, and more. For example, if you have a simple view that needs access
to some shared state but does not need the full power of an observable model, then you can use
`@Shared` directly in the view:

```swift
struct DebugMeetingsView: View {
  @Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
  var body: some View {
    ForEach(meetings) { meeting in
      Text(meeting.title)
    }
  }
}
```

Similarly, if you need to use UIKit for a particular feature or have a legacy feature that can't use
SwiftUI yet, then you can use `@Shared` directly in a view controller:

```swift
import UIKit

final class DebugMeetingsViewController: UIViewController {
  @Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
  // ...
}
```

And to observe changes to `meetings` so that you can update the UI you can either use the 
`publisher` property defined on `@Shared`, or the `observe` tool from our Swift Navigation library. 
See ["Observing changes"][observation-docs] for more information.

[observation-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/observingchanges

### Testing shared state

Features using the `@Shared` property wrapper remain testable even though they interact with outside
storage systems, such as user defaults and the file system. This is possible because each test
gets a fresh storage system that is quarantined to only that test, and so any changes made to it
will only be seen by that test.

See ["Testing"][testing-docs] for more information on how to test your features when using `@Shared`.

[testing-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing/testing

## Demos

The [Sharing][sharing-gh] repo comes with _lots_ of examples to demonstrate how to solve common and
complex problems with `@Shared`. Check out [this][examples-dir] directory to see them all,
 including:

  * [Case Studies][case-studies-dir]:
    A number of case studies demonstrating the built-in features of the library.

  * [FirebaseDemo][firebase-dir]:
    A demo showing how shared state can be powered by a remote [Firebase][firebase] config.
    
  * [GRDBDemo][grdb-dir]:
    A demo showing how shared state can be powered by SQLite in much the same way a view can be
    powered by SwiftData's `@Query` property wrapper.
  
  * [WasmDemo][wasm-dir]:
    A [SwiftWasm][swiftwasm] application that uses this library to share state with your web
    browser's local storage.

  * [SyncUps][syncups]: We also rebuilt Apple's [Scrumdinger][scrumdinger] demo application using 
    modern, best practices for SwiftUI development, including using this library to share state and 
    persist it to the file system.

[swiftwasm]: https://swiftwasm.org
[case-studies-dir]: https://github.com/pointfreeco/swift-sharing/tree/main/Examples/Examples
[grdb-dir]: https://github.com/pointfreeco/swift-sharing/tree/main/Examples/GRDBDemo
[firebase-dir]: https://github.com/pointfreeco/swift-sharing/tree/main/Examples/FirebaseDemo
[wasm-dir]: https://github.com/pointfreeco/swift-sharing/tree/main/Examples/WasmDemo
[examples-dir]: https://github.com/pointfreeco/swift-sharing/tree/main/Examples
[firebase]: https://firebase.google.com
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
[syncups]: https://github.com/pointfreeco/syncups

## Motivation

The primary motivation for our new Sharing library comes from Swift's magical and powerful 
`@AppStorage` tool. With very little work one can persist small bits of data to user defaults:

```swift
struct CounterView: View {
  @AppStorage("count") var count = 0
  var body: some View {
    Form {
      Text("\(count)")
      Button("Increment") { count += 1 }
    }
  }
}
```

Each change of `count` is automatically persisted to user defaults, and further if one mutates
user defaults directly:

```swift
Button("Reset") {
  UserDefaults.standard.set(0, forKey: "count")
}
```

…then the `count` variable will update automatically and the view will refresh.

The `@AppStorage` tool is incredibly powerful and amazingly simple to use, but it only works when
installed directly in a SwiftUI view. If you try using it in an `@Observable` model:

```swift
@Observable
class CounterModel {
  @ObservationIgnored 
  @AppStorage("count") var count = 0
}
```

…then the view will not update when the `count` changes. Things work a little better if using
the legacy `ObservableObject` style of models:

```swift
class CounterModel: ObservableObject {
  @AppStorage("count") var count = 0
}
```

But the `count` will not update if someone writes directly to `UserDefaults`, and it is also
unfortunate to have to use an older API just to use `@AppStorage` out of the view.

Further, `@AppStorage` only works with storing data in user defaults. If one wants to store more
complex data types then one has to embrace Swift Data, which is a large leap in complexity. And
if you want to interface with other storage systems, such as JSON files or remote servers, you will
need to write everything from scratch yourself. 

These problems are what inspired the development of this library. It features:

* A single primary tool, the `@Shared` property wrapper, that aids in sharing state with multiple 
parts of your app and external storage systems. 
* A variety of persistence strategies (user defaults, file system and in-memory), as well as the 
ability for 3rd parties to create their own persistence strategies. 
* It works in essentially any context, including SwiftUI views, `@Observable` models, UIKit view 
controllers, and even on non-Apple platforms.
* It is built with testing in mind so that you can write unit tests for your features using 
`@Shared` even though it is interacting with outside systems.

And this is only scratching the surface of what `@Shared` is capable of.

## Get started today

The [Sharing][sharing-gh] library is already battled tested because it has been used by thousands
of developers for the past 6 months. Join them today by adding [Sharing][sharing-gh] to your project
today, or checking out the [docs][sharing-docs].

[sharing-docs]: https://swiftpackageindex.com/pointfreeco/swift-sharing/main/documentation/sharing
[sharing-gh]: https://github.com/pointfreeco/swift-sharing
