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

### Serial execution

By far the most powerful tool provided by this library is
[`withMainSerialExecutor`][withMainSerialExecutor-docs]. It allows you to execute a block of code
such that all async tasks spawned within it will be run serially on the main thread.

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
the single `Task.yield()` is not enough for the subscription to the stream of notifications to
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

Note that by using `withMainSerialExecutor` you are technically making your tests behave in a manner
that is different from how they would run in production. However, many tests written on a day-to-day
basis due not invole the full-blown vagaries of concurrency. Instead the tests want to assert that
some user action happens, an async unit of work is executed, and that causes some state to change.
Such tests should be written in a way that is 100% deterministic.

If your code has truly complex asynchronous and concurrent operations, then it may be handy to write
two sets of tests: one set that targets the main executor (using `withMainSerialExecutor`) so that
you can deterministically assert how the core system behaves, and then another set that targets the
default, global executor that will probably need to make weaker assertions due to non-determinism,
but can still assert on some things.



## ActorIsolated and LockIsolated

## Streams

## Tasks

## UncheckedSendable

[concurrency-extras-gh]: https://github.com/pointfreeco/swift-concurrency-extras
[withMainSerialExecutor-docs]: todo
[reliably-testing-swift-concurrency]: https://forums.swift.org/t/reliably-testing-code-that-adopts-swift-concurrency/57304
"""###,
      type: .paragraph
    )
  ],
  coverImage: nil,  // TODO
  id: 106,  // TODO
  publishedAt: yearMonthDayFormatter.date(from: "2023-04-26")!,
  title: "Announcing Concurrency Extras: Useful, testable Swift concurrency."
)
