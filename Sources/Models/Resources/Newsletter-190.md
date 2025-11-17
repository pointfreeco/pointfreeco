Point-Free offers the most advanced and original Swift content out there, and we maintain open 
source libraries used by tens of thousands of developers. We even maintain a SwiftData 
[alternative][sqlite-data-blog] powered by SQLite that supports seamless iCloud synchronization 
and data sharing. 

[sqlite-data-blog]: /blog/posts/184-sqlitedata-1-0-an-alternative-to-swiftdata-with-cloudkit-sync-and-sharing

We have an incredible amount of topics to cover next year, and to get a jump start on perfecting 
your expertise in Swift we are offering a [Black Friday **30% discount**][black-friday-sale] for the 
first year of your subscription.

[black-friday-sale]: /discounts/black-friday-2025

@Button(/discounts/black-friday-2025) {
  Subscribe today for 30% off!
}

Once subscribed you'll get instant access to all [346 episodes][pf] of original Point-Free content.
This includes our popular ["Modern Persistence"][modern-persistence] series started just this year,
where we show what it takes to build an app on a modern foundation using SQLite for persistence,
including iCloud synchronization and data sharing. 

[modern-persistence]: /collections/modern-persistence

And we have an incredible amount of advanced content lined up for 2026, including:

[pf]: /
[black-friday-sale]: /discounts/black-friday-2025
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
Reduce { … }
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
Reduce { … }
  .onMount(id: \.searchText) { store in
    try await clock.sleep(for: .seconds(0.3))
    try store.send(.searchResults(apiClient.search(store.searchText)))
  }
```

There is even an `onDismount` method that is invoked the moment the feature is deinitialized:

```swift:2
Reduce { … }
  .onDismount { state in
    await analyticsClient.track("Feature dismounted")
  }
```

The trailing closure is handed the final state of the feature _just_ before deinitialization, and it
is provided an async context for you to perform any additional work. This addresses a long-standing
problem in the library in which a feature cannot be sent `onDisappear` actions from the view because
by that point the feature's state has already been deinitialized.

> Note: A different, but closely related, tool has also be massively improved: `onChange(of:)`.
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

## Basic to basics: Concurrency

We've had two very popular series of episodes under the ["Back to basics"][b2b] umbrella, and next
year we are starting some new ones. Through our work on the 
[Composable Architecture 2.0](#the-composable-architecture-2-0) we have gained valuable experience
and insight into almost ever facet of Swift's latest concurrency tools. We are ready to start 
exploring these tools in episodes that truly get at the heart of what problem Swift concurrency is
trying to solve, and how it does a pretty amazing job at solving it.

The most important concept to be explored is that of "isolation". When approached naively you are
led to an unfortunate situation of everything becoming async since you need to `await` in order
to guarantee isolation. Well, by employing some advanced techniques we can write code that embraces
synchronicity _and_ isolation at the same time. It's how we were able to allow effects in the
Composable Architecture 2.0 synchronously interact with the store, and it's how we were able to fix
many notorious non-determinism problems in the library's testing tools.

Along the way in this series we are going to explore some of the newer concepts that Swift has
introduced to make Swift more "beginner" friendly ("approachable" concurrency, default main actor
isolation, _etc._), and we will slowly work our way up to very advanced topics, such as actors with
custom executors, embracing the power of *non*-sendable tables (you read that right), and a lot
more.

[b2b]: /collections/back-to-basics
[eq-hash]: /collections/back-to-basics/equatable-and-hashable
[sqlite]: /collections/back-to-basics/introduction-to-sqlite

## Modern dependencies

It's been a long time since we dedicated episodes to [dependencies][dep-col] on Point-Free, and a
lot has changed in Swift since then. We feel that robust modern features of Swift allow us to take a
fresh look at dependencies, allowing us to achieve the goals and ergonomics we laid out in the
original series with a lot less code and all new powers that were difficult to imagine previously.

[dep-col]: https://www.pointfree.co/collections/dependencies

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
[subscribe today][black-friday-sale] to get access to all of this and more. The offer is valid for
only a few days, so you'd better hurry!

[black-friday-sale]: /discounts/black-friday-2025

@Button(/discounts/black-friday-2025) {
  Subscribe today for 30% off!
}
