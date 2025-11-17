Point-Free offers the most advanced and original Swift content out there, and we maintain open 
source libraries used by tens of thousands of developers. We even maintain a SwiftData 
[alternative][sqlite-data-blog] powered by SQLite and supporting seamless iCloud synchronization 
and data sharing. 

[sqlite-data-blog]: /blog/posts/184-sqlitedata-1-0-an-alternative-to-swiftdata-with-cloudkit-sync-and-sharing

We have an incredible amount of topics to cover next year, and to get a jump start on perfecting 
your expertise in Swift we are offering a [Black Friday **30% discount**][black-friday-sale] for the 
first year of your subscription.

[black-friday-sale]: /discounts/black-friday-2025

@Button(/discounts/black-friday-2025) {
  Subscribe today for 30% off!
}

Once subscribed you'll get instant access to all [345 episodes][pf] of original Point-Free content.
This includes our popular ["Modern Persistence"][modern-persistence] series started just this year,
where we show what it takes to build an app on a modern foundation using SQLite for persistence,
including iCloud synchronization and data sharing. 

[modern-persistence]: /collections/modern-persistence

And we have an incredible amount of advanced content lined up for 2026, including:

[pf]: /
[black-friday-sale]: /discounts/black-friday-2025
[collections]: /collections

# The Composable Architecture, 2.0

That's right. We have been hard at work on [Composable Architecture][tca] 2.0 for many, _many_ months 
now, and we are nearly ready to start sharing some details. We have assessed every bit of feedback
from our users over the past 5+ years and improved nearly every facet of the library:

[tca]: http://github.com/pointfreeco/swift-composable-architecture
 
### Feature mounting

Features built in the library now have a natural notion of "mounting", which corresponds to its 
state being initialized. Previously one would have to send an explicit `.onAppear` actions from the 
view to emulate this concept, but now you can simply use the `.onMount` method:

```swift:2
Reduce { … }
  .onMount { state in
    guard state.isTimerRunning
    else { return .none }

    return .run { store in
      for await _ in clock.timer(interval: .seconds(1)) {
        store.send(.timerTick)
      } 
    } 
  }
```

The trailing closure of `onMount` is handed the state of the feature as it was initialized, it's
`inout` so that you can make further mutations, and you can return effects to execute once mounted,
and those effects will automatically be torn down when the feature is deinitialized. And this
closure is truly invoked only a single time for the lifetime of the effect, as opposed to SwiftUI's
`onAppear`.

There is even an `onMount(id:)` method that is invoked when a feature is first initialized, as well
as when a piece of state changes in your feature. This can be a great tool for debouncing search
requests that depend on a piece of state: 

```swift:2
Reduce { … }
  .onMount(id: \.searchText) { searchText in
    .run { store in
      try await clock.sleep(for: .seconds(0.3))
      try await store.send(.searchResults(apiClient.search(searchText))) 
    } 
  }
```

There is also an `onDismount` method that is invoked the moment the feature is deinitialized: 

```swift:2
Reduce { … }
  .onDismount { state in
    await analyticsClient.track("Feature dismounted") 
  }
```

This trailing closure is handed the state of the feature _just_ before deinitialization, and
it is provided an async context for you to perform any additional work necessary. This fixes a long
standing problem in the library where a feature cannot be sent `onDisappear` actions because by
that point the feature's state has already been deinitialized.

> Note: A different, but closely related, tool has also be massively improved: `onChange(of:)`. 
> this method now detects all changes to state, not just changes made by the reducer it is 
> attached to.

### Improved bindings

2.0 of the library completely disbands with `BindingReducer()` and `BindingAction` and makes 
bindings to stores immediately available without any additional work:

```swift
TextField("Name", text: $store.name)
```

And to observe changes to the `name` field in your feature you simply use the `onChange(of:)` 
method:

```swift
.onChange(of: \.name) { _, state in
  … 
}
```

### More powerful effects

Effects in the library have been given new super powers. It is now possible to read the current 
state from an effect without sending an action:

```swift:3
.run { store in
  for await _ in clock.timer(interval: .seconds(1)) {
    guard store.alert == nil
    else { continue }
    
    store.send(.timerTick)
  }
}
```

This effect pauses the timer in the feature if an alert is currently being presented to the user.
This allows us to localize more logic to where it belongs, rather than spreading it across many
different actions. Also note that one can access the store's state _and_ send effects without
any suspension points. The isolation of the effect now matches the isolation of the store
running the feature, and so one can interact with the store in a synchronous fashion. See 
[Advanced concurrency](#advanced-concurrency) for more info.

Another super power of effects is that they can now make mutations to the feature state directly,
without sending an action:

```swift
.run { store in
  for await _ in clock.timer(interval: .seconds(1)) {
    guard store.isTimerRunning
    else { break }
    
    store.modify { $0.secondsElapsed += 1 }
  }
}
```

This may seem counterintuitive if you are familiar with the library's core tenets, but we feel
this is still inline with the philosophy of the library. All mutations to a feature's state
still happen within the body of the feature, and this is still 100% testable using the `TestStore`,
but we feel it will greatly reduce the amount of action ping-ponging one has to do to implement
their feature's logic. 

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

# Basic to basics: Concurrency

We've had two very popular series of episodes under the ["Back to basics"][b2b] umbrella, and
next year we are starting a new one. Through our work on the 
[Composable Architecture 2.0](#the-composable-architecture-2-0) we have gained valuable experience
and insight into almost ever facet of Swift's concurrency tools. We are now ready to start 
exploring these tools in episodes that truly get at the heart of what problem Swift concurrency
is trying to solve, and how it does a pretty amazing job at solving it.

The most important concept to be explored is that of "isolation". When approached naviely you are
led to an unfortunate situation of everything becoming async since you need to `await` in order
to guarantee isolation. Well, by employing some advanced techniques we can write code that 
embraces synchronicity _and_ isolation at the same time. It's how we were able to allow effects
in the Composable Architecture 2.0 synchonrously interact with the store, and it's how we were
able to fix many notorious non-determinism problems in the library's testing tools.

Along the way in this series we are going to explore some of the new concepts that Swift introduced
to make Swift more "beginner" friendly ("approachable" concurrency, default main actor isolation, 
…), and we will slowly work our way up to very advanced topics, such as actors with custom
executors, embracing the power of *non*-sendable tables (you read that right), and a lot more.

[b2b]: /collections/back-to-basics
[eq-hash]: /collections/back-to-basics/equatable-and-hashable
[sqlite]: /collections/back-to-basics/introduction-to-sqlite

# Modern dependencies

It's been a long time since we have discussed [dependencies][dep-col] directly on Point-Free, and
a lot has changed in Swift since then. We feel that robust modern features of Swift allow us to
take a fresh look at dependencies, allowing us to achieve the goals and ergonomics we laid out
in the original series with a lot less code and all new powers that were difficult to imagine
previously.

[dep-col]: https://www.pointfree.co/collections/dependencies

# Back to basics: Generics

Another ["Back to basics"][b2b] series we plan on starting next year is an ambitious exploration
into Swift's generics system. We pushed parameter packs to their limits when building our 
[Structured Queries][sq] library, and we think there are many developers out there that could
better leverage their powers if they understood them better. Along the way we will show how 
parameter packs essentially give us anonymous enum types with great ergonomics! 

[sq]: https://github.com/pointfreeco/swift-structured-queries/ 
[b2b]: /collections/back-to-basics


# Cross-platform

And last, but not least, cross-platform Swift recently got a huge boost thanks to the official
[Android SDK][android-sdk]. And over one year ago we dedicated a 7-part series of episodes to
[cross-platform][cross-platform] techniques for sharing code across vastly different platforms, e.g. 
Apple and Wasm. 

In 2026 we would like to pick back up on cross-platform techniques by showing how to build apps
for Android in a way that shares the maximum amount of code. Doing so even strengthens your code
base for other platforms as it helps you more clearly define the essential features to implement
for your app. 

[android-sdk]: https://www.swift.org/blog/nightly-swift-sdk-for-android/ 
[cross-platform]: /collections/cross-platform-swift

# Subscribe today!

This only scratches the surface of what we plan on covering in 2026. Be sure to 
[subscribe today][black-friday-sale] to get access to all of this and more. The
offer is valid for only a few days, so you better hurry!

[black-friday-sale]: /discounts/black-friday-2025

@Button(/discounts/black-friday-2025) {
  Subscribe today for 30% off!
}
