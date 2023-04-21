import Foundation

public let post0106_ConcurrencyExtras = BlogPost(
  author: .pointfree,
  blurb: """
    Today we are excited to announce a brand new open source library: Concurrency Extras. It
    includes tools to help make your concurrent Swift code more versatile and more testable.
    """,
  contentBlocks: [
    .init(
      content: ###"""
Today we are excited to announce a brand new open source library: [Concurrency
Extras][concurrency-extras-gh]. It includes tools to help make your concurrent Swift code
more versatile and more testable. Join us for a quick overview of some of the tools
provided:

* [Serial execution](#SerialExecution)
* [`ActorIsolated` and `LockIsolated`](#ActorIsolatedAndLockIsolated)
* [Streams](#Streams)
* [Tasks](#Tasks)
* [`UncheckedSendable`](#UncheckedSendable)

<div id="SerialExecution"></div>

## Serial execution

By far the most powerful tool provided by this library is
[`withMainSerialExecutor`][withMainSerialExecutor-docs]. It allows you to execute a block of code
in such a way that all async tasks spawned within it will be run serially on the main thread.

This can be incredibly useful in tests since testing async code is [notoriously
difficult][reliably-testing-swift-concurrency] due to how suspension points are processed
by the runtime. Using `withMainSerialExecutor` can help make your tests deterministic, less flakey,
and massively speed them up.

Note that running async tasks serially does not mean that multiple concurrent tasks are not able to
interleave. Suspension of async tasks still works just as you would expect, but all actual work run
is run on the unique, main thread.

For example, consider the following simple `ObservableObject` implementation for a feature that
wants to count the number of times a screenshot is taken of the screen:

```swift
class FeatureModel: ObservableObject {
  @Published var count = 0

  @MainActor
  func onAppear() async {
    let screenshots = NotificationCenter.default.notifications(
      named: UIApplication.userDidTakeScreenshotNotification
    )
    for await _ in screenshots {
      self.count += 1
    }
  }
}
```

This is quite a simple feature, but in the future it could start doing more complicated things,
such as performing a network request when it detects a screenshot being taken.

So, it would be great if we could get some test coverage on this feature. To do this we can create
a model, and spin up a new task to invoke the `onAppear` method:

```swift
func testBasics() async {
  let model = ViewModel()
  let task = Task { await model.onAppear() }
}
```

Then we can use `Task.yield()` to allow the subscription of the stream of notifications to start:

```swift
func testBasics() async {
  let model = ViewModel()
  let task = Task { await model.onAppear() }

  // Give the task an opportunity to start executing its work.
  await Task.yield()
}
```

Then we can simulate the user taking a screenshot by posting a notification:

```swift
func testBasics() async {
  let model = ViewModel()
  let task = Task { await model.onAppear() }

  // Give the task an opportunity to start executing its work.
  await Task.yield()

  // Simulate a screen shot being taken.
  NotificationCenter.default.post(
    name: UIApplication.userDidTakeScreenshotNotification, object: nil
  )
}
```

And then finally we can yield again to process the new notification and assert that the count
incremented by 1:

```swift
func testBasics() async {
  let model = ViewModel()
  let task = Task { await model.onAppear() }

  // Give the task an opportunity to start executing its work.
  await Task.yield()

  // Simulate a screen shot being taken.
  NotificationCenter.default.post(
    name: UIApplication.userDidTakeScreenshotNotification, object: nil
  )

  // Give the task an opportunity to update the view model.
  await Task.yield()

  XCTAssertEqual(model.count, 1)
}
```

This seems like a perfectly reasonable test, and it does pass… sometimes. If you run it enough
times you will eventually get a failure (about 6% of the time). This is happening because sometimes
the single `Task.yield()` is not enough for the subscription to the notifications to
actually start. In that case we will post the notification before we have actually subscribed,
causing a test failure.

If we wrap the entire test in ``withMainSerialExecutor``, then it will pass deterministically,
100% of the time:

```swift
func testBasics() async {
  await withMainSerialExecutor {
    …
  }
}
```

This is because now all tasks are enqueued serially on the main executor, and so when we
`Task.yield` we can be sure that the `onAppear` method will execute until it reaches a suspension
point. This guarantees that the subscription to the stream of notifications will start when we
expect it to.

You can also use ``withMainSerialExecutor`` to wrap an entire test case by overriding the
`invokeTest` method:

```swift
final class FeatureModelTests: XCTestCase {
  override func invokeTest() {
    withMainSerialExecutor {
      super.invokeTest()
    }
  }
  …
}
```

Now the entire `FeatureModelTests` test case will be run on the main, serial executor.

Note that by using ``withMainSerialExecutor`` you are technically making your
tests behave in a manner that is different from how they would run in production. However, many
tests written on a day-to-day basis do not invole the full-blown vagaries of concurrency. Instead,
tests often what to assertion that when some user action happens, an async unit of work is executed,
and that causes some state to change. Such tests should be written in a way that is 100%
deterministic.

If your code has truly complex asynchronous and concurrent operations, then it may be handy to write
two sets of tests: one set that targets the main executor (using
``withMainSerialExecutor``) so that you can deterministically assert how the core
system behaves, and then another set that targets the default, global executor. The latter tests
will probably need to make weaker assertions due to non-determinism, but can still assert on some
things.

<div id="ActorIsolatedAndLockIsolated"></div>

## ActorIsolated and LockIsolated

The ``ActorIsolated`` and ``LockIsolated`` types help wrap other values in an isolated context.
`ActorIsolated` wraps the value in an actor so that the only way to access and mutate the value is
through an async/await interface. ``LockIsolated`` wraps the value in a class with a lock, which
allows you to read and write the value with a synchronous interface. You should prefer to use
[`ActorIsolated`][actor-isolated-docs] when you have access to an asynchronous context.

For example, suppose you have a feature such that when a button is tapped you track some
analytics:

```swift
struct AnalyticsClient {
  var track: (String) async -> Void
}

class FeatureModel: ObservableObject {
  let analytics: AnalyticsClient
  // ...
  func buttonTapped() {
    // ...
    await self.analytics.track("Button tapped")
  }
}
```

Then, in tests we can construct an analytics client that appends events to a mutable array
rather than actually sending events to an analytics server. However, in order to do this a
concurrency-safe way we should use an actor, and `ActorIsolated` makes this easy:

```swift
func testAnalytics() async {
  let events = ActorIsolated<[String]>([])
  let analytics = AnalyticsClient(
    track: { event in await events.withValue { $0.append(event) } }
  )
  let model = FeatureModel(analytics: analytics)
  model.buttonTapped()
  await events.withValue {
    XCTAssertEqual($0, ["Button tapped"])
  }
}
```

We also offer a tool to synchronously isolate a value, called [`LockIsolated`][lock-isolated-docs].

<div id="Streams"></div>

## Streams

The library comes with numerous helper APIs spread across the two Swift stream types:

  * There are helpers that convert any `AsyncSequence` conformance to either concrete stream type.
    This allows you to treat the stream type as a kind of "type erased" `AsyncSequence`.

    For example, suppose you have a dependency client like this:

    ```swift
    struct ScreenshotsClient {
      var screenshots: () -> AsyncStream<Void>
    }
    ```

    Then you can construct a live implementation that "erases" the
    `NotificationCenter.Notifications` async sequence to a stream by using the
    [`eraseToStream`][erase-to-stream-source] method:

    ```swift
    extension ScreenshotsClient {
      static let live = Self(
        screenshots: {
          NotificationCenter.default
            .notifications(named: UIApplication.userDidTakeScreenshotNotification)
            .map { _ in }
            .eraseToStream()  // ⬅️
        }
      )
    }
    ```

    Use [`eraseToThrowingStream()`][erase-to-throwing-stream-source] to propagate failures from
    throwing async sequences.

  * There is an API for simultaneously constructing a stream and its backing continuation. This can
    be handy in tests when overriding a dependency endpoint that returns a stream:

    ```swift
    let screenshots = AsyncStream<Void>.streamWithContinuation()
    let model = FeatureModel(screenshots: screenshots.stream)

    XCTAssertEqual(model.screenshotCount, 0)
    screenshots.continuation.yield()  // Simulate a screenshot being taken.
    XCTAssertEqual(model.screenshotCount, 1)
    ```

    Note that this method will be superceded by the official method coming to Swift 5.9 thanks
    to this [accepted proposal][stream-proposal].

  * Static [`AsyncStream.never`][stream-never-source] and
    [`AsyncThrowingStream.never`][throwing-stream-never-source] helpers are provided that represent
    streams that live forever and never emit. They can be handy in tests that need to override a
    dependency endpoint with a stream that should suspend and never emit for the duration test.

  * Static [`AsyncStream.finished`][stream-finished-source] and
    [`AsyncThrowingStream.finished(throwing:)`][throwing-stream-finished-source] helpers are
    provided that represents streams that complete immediately without emitting. They can be handy
    in tests that need to override a dependency endpoint with a stream that completes/fails
    immediately.

<div id="Tasks"></div>

## Tasks

The library comes with a static function, [`Task.never()`][task-never-source], that can
asynchronously return a value of any type, but does so by suspending forever. This can be useful for
satisfying a dependency requirement in a way that does not require you to actually return data from
that endpoint.

<div id="UncheckedSendable"></div>

## UncheckedSendable

A wrapper type that can make any type `Sendable`, but in an unsafe and unchecked way. This type
should only be used as an alternative to `@preconcurrency import`, which turns off concurrency
checks for everything in the library. Whereas ``UncheckedSendable`` allows you to turn off
concurrency warnings for just one single usage of a particular type.

While [SE-0302][se-0302] mentions future work of ["Adaptor Types for Legacy
Codebases"][se-0302-unsafetransfer], including an `UnsafeTransfer` type that serves the same
purpose, it has not landed in Swift.

## Get started today



[concurrency-extras-gh]: https://github.com/pointfreeco/swift-concurrency-extras
[withMainSerialExecutor-docs]: todo
[reliably-testing-swift-concurrency]: https://forums.swift.org/t/reliably-testing-code-that-adopts-swift-concurrency/57304
[lock-isolated-docs]: todo
[actor-isolated-docs]: todo
[erase-to-stream-source]: todo
[erase-to-throwing-stream-source]: todo
[stream-proposal]: https://github.com/apple/swift-evolution/blob/ee39d319cf9bcdc8447c44b3fcc0afde809246d3/proposals/0388-async-stream-factory.md
[stream-never-source]: todo
[throwing-stream-never-source]: todo
[stream-finished-source]: todo
[throwing-stream-finished-source]: todo
[task-never-source]: todo
[se-0302]: https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md
[se-0302-unsafetransfer]: https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md#adaptor-types-for-legacy-codebases
"""###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 106,
  publishedAt: yearMonthDayFormatter.date(from: "2023-04-26")!,
  title: "Announcing Concurrency Extras: Useful, testable Swift concurrency."
)
