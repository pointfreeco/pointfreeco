We are excited to announce a brand new open-source library: [Sharing][sharing-gh]. Instantly share 
state among your app's features and external persistence layers, including user defaults, the file 
system, and more.

## Introducing @Shared

The library comes with one primary tool, the `@Shared` property wrapper, which aids in sharing
state with multiple parts of your application and persisting data to external storage systems, such
as user defaults, the file system, and more. The tool works in a variety of contexts, such as 
SwiftUI views, `@Observable` models, and UIKit view controllers, and it is completely unit testable.

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
[`appStorage`][app-storage-key-docs]), 
[`fileStorage`][file-storage-key-docs]), and
[`inMemory`][in-memory-key-docs]). 

[shared-article]: TODO
[app-storage-key-docs]: TODO
[file-storage-key-docs]: TODO
[in-memory-key-docs]: TODO

The [`appStorage`][app-storage-key-docs]) strategy is useful for store small
pieces of simple data in user defaults, such as settings:

```swift
@Shared(.appStorage("soundsOn")) var soundsOn = true
@Shared(.appStorage("hapticsOn")) var hapticsOn = true
@Shared(.appStorage("userOrder")) var userOrder = UserOrder.name
```

The [`fileStorage`][file-storage-key-docs]) strategy is useful
for persisting more complex data types to the file system by serializing the data to bytes:

```swift
@Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
```

And the [`inMemory`][in-memory-key-docs]) strategy is useful for sharing any kind
of data globably with the entire app, but it will be reset the next time the app is relaunched:

```swift
@Shared(.inMemory("events")) var events: [String] = []
```

See ["Persistence strategies"][persistence-docs] for more information on leveraging the persistence 
strategies that come with the library, as well as creating your own strategies.

[persistence-docs]: TODO

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
final class DebugMeetingsViewController: UIViewController {
  @Shared(.fileStorage(.meetingsURL)) var meetings: [Meeting] = []
  // ...
}
```

And to observe changes to `meetings` so that you can update the UI you can either use the 
``Shared/publisher`` property or the `observe` tool from our Swift Navigation library. See 
["Observing changes"][observation-docs] for more information.

[observation-docs]: TODO

### Testing shared state

Features using the `@Shared` property wrapper remain testable even though they interact with outside
storage systems, such as user defaults and the file system. This is possible because each test
gets a fresh storage system that is quarantined to only that test, and so any changes made to it
will only be seen by that test.

See ["Testing"][testing-docs] for more information on how to test your features when using `@Shared`.

[testing-docs]: TODO

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

## Get started today

todo

[sharing-gh]: https://github.com/pointfreeco/swift-sharing
