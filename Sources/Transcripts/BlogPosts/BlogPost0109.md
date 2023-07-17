Today we are excited to announce a brand new open source library: [Concurrency
Extras][concurrency-extras-gh]. It includes tools to help make your concurrent Swift code more
versatile and more testable. Join us for a quick overview of some of the tools provided:

* [Serial execution](#SerialExecution)
* [`ActorIsolated` and `LockIsolated`](#ActorIsolatedAndLockIsolated)
* [Streams](#Streams)
* [Tasks](#Tasks)
* [`UncheckedSendable`](#UncheckedSendable)

<div id="SerialExecution"></div>

## Serial execution

By far the most powerful tool provided by this library is
[`withMainSerialExecutor`][withMainSerialExecutor-docs]. This function allows you to execute a block
of code in such a way that all async tasks spawned within it will be run serially on the main
thread.

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

This is quite a simple feature, but in the future it could start doing more complicated things, such
as performing a network request when it detects a screenshot being taken. So, it would be great if 
we could get some test coverage on this feature. To do this we can create a model, and spin up a 
new task to invoke the `onAppear` method so that it runs in parallel to the rest of the test:

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

This seems like a perfectly reasonable test, and it does pass…sometimes. If you run it enough times
you will eventually get a failure (about 6% of the time as of Xcode 14.3). This is happening because 
sometimes the single `Task.yield()` is not enough for the subscription to the notifications to 
actually start. In that case we will post the notification before we have actually subscribed, 
causing a test failure.

If we wrap the entire test in `withMainSerialExecutor`, then it will pass deterministically, 100% of
the time:

```swift
func testBasics() async {
  await withMainSerialExecutor {
    …
  }
}
```

This is because now all tasks are enqueued serially by the main executor, and so when we
`Task.yield` we can be sure that the `onAppear` method will execute until it reaches a suspension
point. This guarantees that the subscription to the stream of notifications will start when we
expect it to.

You can also use `withMainSerialExecutor` to wrap an entire test case by overriding the `invokeTest`
method:

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

Note that by using `withMainSerialExecutor` you are technically making your tests behave in a manner
that is different from how they would run in production. However, many tests written on a day-to-day
basis do not invoke the full-blown vagaries of concurrency. Instead, tests often want to assert that
when some user action happens, an async unit of work is executed, and that causes some state to
change. Such tests should be written in a way that is 100% deterministic. 

And even Apple agrees. They use a similar technique in their Async Algorithms package, and
in the [documentation of one of their test helpers][async-validation-md] they justify
why they think their manner of testing async sequences truly does test reality even though they are
altering the runtime that schedules async work (emphasis ours):

> Testing is a critical area of focus for any package to make it robust, catch bugs, and explain the 
expected behaviors in a documented manner. Testing things that are asynchronous can be difficult, 
testing things that are asynchronous multiple times can be even more difficult.
> 
> Types that implement AsyncSequence **can often be described in deterministic actions given 
particular inputs**. For the inputs, the events can be described as a discrete set: values, errors 
being thrown, the terminal state of returning a nil value from the iterator, or advancing in time 
and not doing anything. Likewise, the expected output has a discrete set of events: values, errors 
being caught, the terminal state of receiving a nil value from the iterator, or advancing in time 
and not doing anything.

Just as async sequences can often be described with a determinstic sequences of inputs that lead to
a deterministic sequence of outputs, the same is true of user actions in an application. And so we
too feel that many of the tests we write on a daily basis can be run inside `withMainSerialExecutor`
and that we are not weakening the strength of those tests in the least.

However, if your code has truly complex asynchronous and concurrent operations, then it may be handy 
to write two sets of tests: one set that targets the main executor (using `withMainSerialExecutor`) 
so that you can deterministically assert how the core system behaves, and then another set that 
targets the default, global executor. The latter tests will probably need to make weaker assertions 
due to non-determinism, but can still assert on some things.

<div id="ActorIsolatedAndLockIsolated"></div>

## ActorIsolated and LockIsolated

The `ActorIsolated` and `LockIsolated` types help wrap other values in an isolated context.
`ActorIsolated` wraps the value in an actor so that the only way to access and mutate the value is
through an async/await interface. `LockIsolated` wraps the value in a class with a lock, which
allows you to read and write the value with a synchronous interface. You should prefer to use
[`ActorIsolated`][actor-isolated-docs] when you have access to an asynchronous context.

For example, suppose you have a feature such that when a button is tapped you track some analytics:

```swift
struct AnalyticsClient {
  var track: (String) async -> Void
}

class FeatureModel: ObservableObject {
  let analytics: AnalyticsClient
  …
  func buttonTapped() {
    …
    await self.analytics.track("Button tapped")
  }
}
```

Then, in tests we can construct an analytics client that appends events to a mutable array rather
than actually sending events to an analytics server. However, in order to do this a concurrency-safe
way we should use an actor, and `ActorIsolated` makes this easy:

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
    
    Note that care must be taken when "erasing" async sequences to streams. The `AsyncStream` and 
    `AsyncThrowingStream` types do not support multiple subscribe/Users/brandon/projects/pointfreeco/Sources/Transcripts/BlogPosts/BlogPost0110_WritingReliableAsyncTests.swift
/Users/brandon/projects/pointfreeco/Sources/Transcripts/BlogPosts/BlogPost0110.mdrs, and so you may need to create 
    multiple streams from a single sequence to support that behavior. This is unfortunately the best
    we can do until Swift gets the features necessary to support something like 
    `any AsyncSequence<Element>`.

  * There is an API for simultaneously constructing a stream and its backing continuation. This can
    be handy in tests when overriding a dependency endpoint that returns a stream:

    ```swift
    let screenshots = AsyncStream.makeStream(of: Void.self)
    let model = FeatureModel(screenshots: screenshots.stream)

    XCTAssertEqual(model.screenshotCount, 0)
    screenshots.continuation.yield()  // Simulate a screenshot being taken.
    XCTAssertEqual(model.screenshotCount, 1)
    ```

    Note that this method will be superseded by the official method coming to Swift 5.9 thanks to
    this [accepted proposal][stream-proposal].

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
checks for everything in the library. Whereas `UncheckedSendable` allows you to turn off concurrency
warnings for just one single usage of a particular type.

While [SE-0302][se-0302] mentions future work of ["Adaptor Types for Legacy
Codebases"][se-0302-unsafetransfer], including an `UnsafeTransfer` type that serves the same
purpose, it has not landed in Swift.

## Get started today

If any of this sounds useful to you, be sure to check the [Concurrency 
Extras][concurrency-extras-gh] library today, and start writing tests for your async code today.

[async-validation-md]: https://github.com/apple/swift-async-algorithms/blob/07a0c1ee08e90dd15b05d45a3ead10929c0b7ec5/Sources/AsyncSequenceValidation/AsyncSequenceValidation.docc/AsyncSequenceValidation.md
[concurrency-extras-gh]: https://github.com/pointfreeco/swift-concurrency-extras
[withMainSerialExecutor-docs]: https://pointfreeco.github.io/swift-concurrency-extras/main/documentation/concurrencyextras/withmainserialexecutor(operation:)-7fqt1
[reliably-testing-swift-concurrency]: https://forums.swift.org/t/reliably-testing-code-that-adopts-swift-concurrency/57304
[lock-isolated-docs]: https://pointfreeco.github.io/swift-concurrency-extras/main/documentation/concurrencyextras/lockisolated
[actor-isolated-docs]: https://pointfreeco.github.io/swift-concurrency-extras/main/documentation/concurrencyextras/actorisolated
[erase-to-stream-source]: https://github.com/pointfreeco/swift-concurrency-extras/blob/ecb065a41bbdd7f64ab2695ffc755ed37c9ff4dc/Sources/ConcurrencyExtras/AsyncStream.swift#L137
[erase-to-throwing-stream-source]: https://github.com/pointfreeco/swift-concurrency-extras/blob/ecb065a41bbdd7f64ab2695ffc755ed37c9ff4dc/Sources/ConcurrencyExtras/AsyncThrowingStream.swift#L94
[stream-proposal]: https://github.com/apple/swift-evolution/blob/ee39d319cf9bcdc8447c44b3fcc0afde809246d3/proposals/0388-async-stream-factory.md
[stream-never-source]: https://github.com/pointfreeco/swift-concurrency-extras/blob/ecb065a41bbdd7f64ab2695ffc755ed37c9ff4dc/Sources/ConcurrencyExtras/AsyncStream.swift#L124-L126
[throwing-stream-never-source]: https://github.com/pointfreeco/swift-concurrency-extras/blob/ecb065a41bbdd7f64ab2695ffc755ed37c9ff4dc/Sources/ConcurrencyExtras/AsyncThrowingStream.swift#L79-L81
[stream-finished-source]: https://github.com/pointfreeco/swift-concurrency-extras/blob/ecb065a41bbdd7f64ab2695ffc755ed37c9ff4dc/Sources/ConcurrencyExtras/AsyncStream.swift#L129-L131
[throwing-stream-finished-source]: https://github.com/pointfreeco/swift-concurrency-extras/blob/ecb065a41bbdd7f64ab2695ffc755ed37c9ff4dc/Sources/ConcurrencyExtras/AsyncThrowingStream.swift#L86-L88
[task-never-source]: https://github.com/pointfreeco/swift-concurrency-extras/blob/ecb065a41bbdd7f64ab2695ffc755ed37c9ff4dc/Sources/ConcurrencyExtras/Task.swift#L40-L45
[se-0302]: https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md
[se-0302-unsafetransfer]: https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md#adaptor-types-for-legacy-codebases
