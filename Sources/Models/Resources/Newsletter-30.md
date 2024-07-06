This week we completed our 3-part introduction
([part 1](/episodes/ep65-swiftui-and-state-management-part-1),
[part 2](/episodes/ep66-swiftui-and-state-management-part-2),
[part 3](/episodes/ep67-swiftui-and-state-management-part-3)) to SwiftUI and the problems of state
management and application architecture. All 3 episodes are completely free for everyone to watch
and they aim to show what tools SwiftUI gives us for managing state in a moderately complex
application.

Unfortunately, SwiftUI is still very much in beta and it seems that every 2 weeks there are
substantial changes. These changes range from APIs being renamed to foundational changes to how
SwiftUI behaves. Due to some of these changes our last 3 episodes now contain some misinformation,
so we’d like to take an opportunity to correct these!

## `BindableObject` vs. `ObservableObject`

The main mechanism for turning your models into objects that can be bound in views was a protocol
named `BindableObject`. Conforming to this protocol required you to provide a `didChange` publisher
that you would ping just after you made any changes to your model. For example:

```swift
import SwiftUI

class AppState: BindableObject {
  let didChange = PassthroughSubject<Void, Never>()

  var count = 0 {
    didSet { didChange.send() }
  }

  var favoritePrimes: [Int] = [] {
    didSet { didChange.send() }
  }
}
```

However, as of Xcode 11 beta 5 this protocol has been renamed to `ObservableObject` (and moved from
the `SwiftUI` framework to the `Combine` framework), and you are now required to notify a publisher
when your model is about to change rather than after it is changed. This means the above code
snippet should now look like this:

```swift
import Combine

class AppState: ObservableObject {
  let objectWillChange = ObservableObjectPublisher()

  var count = 0 {
    willSet { objectWillChange.send() }
  }

  var favoritePrimes: [Int] = [] {
    willSet { objectWillChange.send() }
  }
}
```

This now satisfies the compiler and is the correct way to implement this protocol.

The name of the property wrapper that connects our model to a view was also renamed in beta 5, from
`ObjectBinding` to `ObservedObject`. To use it you can simply do:

```swift
struct ContentView: View {
  @ObservedObject var state: AppState

  var body: some View { … }
}
```

## `ObservableObject` boilerplate

There is also a change in Xcode 11 beta 5 that greatly simplifies how one creates observable
objects. The amount of boilerplate required to implement the `ObservableObject` protocol was pretty
significant. Just look at what happens to our `AppState` if we add two more properties:

```swift
import Combine

class AppState: ObservableObject {
  let objectWillChange = ObservableObjectPublisher()

  var count = 0 {
    willSet { objectWillChange.send() }
  }

  var favoritePrimes: [Int] = [] {
    willSet { objectWillChange.send() }
  }

  var activityFeed: [Activity] = [] {
    willSet { objectWillChange.send() }
  }

  var loggedInUser: User? = nil {
    willSet { objectWillChange.send() }
  }
}
```

This was one of the problems that we discussed in
[part 3](/episodes/ep67-swiftui-and-state-management-part-3#t314) of our series, and luckily Xcode
11 beta 5 provides a solution. It is now possible for SwiftUI to automatically synthesize the
`objectWillChange` for you, and by using the `@Published` property wrapper you can automatically
have the publisher pinged when any of your fields change:

```swift
import Combine

class AppState: ObservableObject {
  @Published var count = 0
  @Published var favoritePrimes: [Int] = []
  @Published var activityFeed: [Activity] = []
  @Published var loggedInUser: User? = nil
}
```

Much nicer!

## Derived bindings

Another problem we discussed in [part 3](/episodes/ep67-swiftui-and-state-management-part-3#t1177)
of our series is the idea that SwiftUI state didn’t appear to be “composable”. After much testing
and playing around with SwiftUI we weren’t able to figure out how to easily derive bindings of
sub-state from our main `AppState`.

For example, say we had an `ActivityView` screen that only needs access to the `activityFeed` field
of `AppState`. We would love if there was a way to project out that single field into a binding, and
hand it over to the activity view. We approached this by creating a view that had a binding to the
activity feed:

```swift
struct ActivityView: View {
  @Binding var activityFeed: [Activity]

  var body: some View { … }
}
```

Then, to create a `Binding<Activity>` to pass along to this view we could derive a binding from the
`AppState` observable object:

```swift:10
struct ContentView {
  @ObservedObject var state: AppState

  var body: some View {
    NavigationView {
      List {
        …
        NavigationLink(
          destination: ActivityView(
            activityFeed: $state.activityFeed
          )
        ) {
          Text("Activity feed")
        }
        …
      }
    }
  }
}
```

The `$state.activityFeed` first accesses the state as the underlying `Binding<AppState>` that comes
from the property wrapper, and this is done via `$state`. Then we derive a
`Binding<[Activity]>` from the `Binding<AppState>` by using dot-syntax, which is possible thanks to
the
[Key Path Member Lookup](https://github.com/apple/swift-evolution/blob/master/proposals/0252-keypath-dynamic-member-lookup.md)
feature of Swift 5.1

This is how we hoped derived bindings would work in SwiftUI, but unfortunately up until Xcode 11
beta 5 this did not work. There was a bug that prevented the `ActivityView` from re-rendering when
the app state changed. This has now been fixed, and it’s a great way for creating views that operate
on only a small subset of data instead of passing around the full `AppState` to all views!

## Identifiable

And lastly, the `Identifiable` protocol has been moved out of the SwiftUI framework and into the
standard library. This means you no longer need to `import SwiftUI` in order to get access to this
protocol. However, in this change there appears to be a bug in which `Int` no longer conforms to
`Identifiable`. We're not sure if this was done on purpose, or if it's a temporary bug, but it means
that our code to show an alert from a binding no longer compiles:

```swift
struct CounterView: View {
  @State var alertNthPrime: Int?
  …

  var body: some View {
    …
    .alert(item: $alertNthPrime) { prime in
      …
    }
  }
}
```

Since `Int` is no longer `Identifiable`, we cannot use a `Binding<Int?>` value in the
`alert(item:content:)` method. The workaround is easy enough, just wrap the integer in a struct that
you can make identifiable:

```swift
struct PrimeAlert: Identifiable {
  let prime: Int
  var id: Int { prime }
}

struct CounterView: View {
  @State var alertNthPrime: PrimeAlert?
  …

  var body: some View {
    …
    .alert(item: $alertNthPrime) { prime in
      …
    }
  }
}
```

Now this works as it did before. Hopefully the conformance of integers to `Identifiable` is added
back before Xcode 11 ships!

## Move fast, correct things

The past few Xcode 11 betas have had some really nice improvements to SwiftUI, and we are really
happy to see the changes. Some of the fixes have directly addressed some of the concerns we brought
up in [this week’s episode](/episodes/ep67-swiftui-and-state-management-part-3), and make SwiftUI
much more appropriate for large, complex applications.

However, we still feel there is room for improvement in a number of key areas in application
development. Next week we begin developing an architecture to directly address these problems using
functional programming as our North Star.

Until next time!
