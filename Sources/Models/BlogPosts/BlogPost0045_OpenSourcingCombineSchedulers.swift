import Foundation

public let post0045_OpenSourcingCombinePublishers = BlogPost(
  author: .pointfree,
  blurb: """
Today we are open-sourcing CombineSchedulers, a library that introduces a few schedulers that makes working with Combine more testable and more versatile.
""",
  contentBlocks: [

    .init(
      content: """
We are excited to announce the 0.1.0 release of [CombineSchedulers](https://github.com/pointfreeco/combine-schedulers), a library that introduces a few schedulers that makes working with Combine more testable and more versatile.

## Motivation

The Combine framework provides the `Scheduler` protocol, which is a powerful abstraction for describing how and when units of work are executed. It unifies many disparate ways of executing work, such as `DispatchQueue`, `RunLoop` and `OperationQueue`.

However, the Combine framework is still quite new and missing some fundamental pieces needed to make asynchronous Combine code more testable. This library intends to fill those gaps with some handy schedulers and publishers, including `AnyScheduler`, `TestScheduler`, `UIScheduler`, `ImmediateScheduler`, and `Publishers.Timer`.

### `AnyScheduler`

The `AnyScheduler` provides a type-erasing wrapper for the `Scheduler` protocol, which can be useful for being generic over many types of schedulers without needing to actually introduce a generic to your code. The Combine framework ships with many type-erasing wrappers, such as `AnySubscriber`, `AnyPublisher` and `AnyCancellable`, yet for some reason does not ship with `AnyScheduler`.

This type is useful for times that you want to be able to customize the scheduler used in some code from the outside, but you don't want to introduce a generic to make it customizable. For example, suppose you have an `ObservableObject` view model that performs an API request when a method is called:

```swift
class EpisodeViewModel: ObservableObject {
  @Published var episode: Episode?
  private var cancellables: Set<AnyCancellable> = []

  let apiClient: ApiClient

  init(apiClient: ApiClient) {
    self.apiClient = apiClient
  }

  func reloadButtonTapped() {
    self.apiClient.fetchEpisode()
      .receive(on: DispatchQueue.main)
      .sink { self.episode = $0 }
      .store(in: &self.cancellables)
  }
}
```

Notice that we are using `DispatchQueue.main` in the `reloadButtonTapped` method because the `fetchEpisode` endpoint most likely delivers its output on a background thread (as is the case with `URLSession`).

This code seems innocent enough, but the presence of `.receive(on: DispatchQueue.main)` makes this code harder to test since you have to use `XCTest` expectations to explicitly wait a small amount of time for the queue to execute. This can lead to flakiness in tests and make test suites take longer to execute than necessary.

One way to fix this testing problem is to use an ["immediate" scheduler](#immediatescheduler) instead of `DispatchQueue.main`, which will cause `fetchEpisode` to deliver its output as soon as possible with no thread hops. In order to allow for this we would need to inject a scheduler into our view model so that we can control it from the outside:

```swift
class EpisodeViewModel<S: Scheduler>: ObservableObject {
  @Published var episode: Episode?
  private var cancellables: Set<AnyCancellable> = []

  let apiClient: ApiClient
  let scheduler: S

  init(apiClient: ApiClient, scheduler: S) {
    self.apiClient = apiClient
    self.scheduler = scheduler
  }

  func reloadButtonTapped() {
    self.apiClient.fetchEpisode()
      .receive(on: self.scheduler)
      .sink { self.episode = $0 }
      .store(in: &self.cancellables)
  }
}
```

Now we can initialize this view model in production by using `DispatchQueue.main` and we can initialize it in tests using `DispatchQueue.immediateScheduler`. Sounds like a win!

However, introducing this generic to our view model is quite heavyweight as it is loudly announcing to the outside world that this type uses a scheduler, and worse it will end up infecting any code that touches this view model that also wants to be testable. For example, any view that uses this view model will need to introduce a generic if it wants to also be able to control the scheduler, which would be useful if we wanted to write [snapshot tests](https://github.com/pointfreeco/swift-snapshot-testing).

Instead of introducing a generic to allow for substituting in different schedulers we can use `AnyScheduler`. It allows us to be somewhat generic in the scheduler, but without actually introducing a generic.

Instead of holding a generic scheduler in our view model we can say that we only want a scheduler whose associated types match that of `DispatchQueue`:

```swift
class EpisodeViewModel: ObservableObject {
  @Published var episode: Episode?
  private var cancellables: Set<AnyCancellable> = []

  let apiClient: ApiClient
  let scheduler: AnySchedulerOf<DispatchQueue>

  init(apiClient: ApiClient, scheduler: AnySchedulerOf<DispatchQueue>) {
    self.apiClient = apiClient
    self.scheduler = scheduler
  }

  func reloadButtonTapped() {
    self.apiClient.fetchEpisode()
      .receive(on: self.scheduler)
      .sink { self.episode = $0 }
      .store(in: &self.cancellables)
  }
}
```

Then, in production we can create a view model that uses a live `DispatchQueue`, but we just have to first erase its type:

```swift
let viewModel = EpisodeViewModel(
  apiClient: ...,
  scheduler: DispatchQueue.main.eraseToAnyScheduler()
)
```

And similarly in tests we can use an immediate scheduler as long as we erase its type:

```swift
let viewModel = EpisodeViewModel(
  apiClient: ...,
  scheduler: DispatchQueue.immediateScheduler.eraseToAnyScheduler()
)
```

So, in general, `AnyScheduler` is great for allowing one to control what scheduler is used in classes, functions, etc. without needing to introduce a generic, which can help simplify the code and reduce implementation details from leaking out.

### `TestScheduler`

A scheduler whose current time and execution can be controlled in a deterministic manner. This scheduler is useful for testing how the flow of time effects publishers that use asynchronous operators, such as `debounce`, `throttle`, `delay`, `timeout`, `receive(on:)`, `subscribe(on:)` and more.

For example, consider the following `race` operator that runs two futures in parallel, but only emits the first one that completes:

```swift
func race<Output, Failure: Error>(
  _ first: Future<Output, Failure>,
  _ second: Future<Output, Failure>
) -> AnyPublisher<Output, Failure> {
  first
    .merge(with: second)
    .prefix(1)
    .eraseToAnyPublisher()
}
```

Although this publisher is quite simple we may still want to write some tests for it.

To do this we can create a test scheduler and create two futures, one that emits after a second and one that emits after two seconds:

```swift
let scheduler = DispatchQueue.testScheduler

let first = Future<Int, Never> { callback in
  scheduler.schedule(after: scheduler.now.advanced(by: 1)) { callback(.success(1)) }
}
let second = Future<Int, Never> { callback in
  scheduler.schedule(after: scheduler.now.advanced(by: 2)) { callback(.success(2)) }
}
```

And then we can race these futures and collect their emissions into an array:

```swift
var output: [Int] = []
let cancellable = race(first, second).sink { output.append($0) }
```

And then we can deterministically move time forward in the scheduler to see how the publisher emits. We can start by moving time forward by one second:

```swift
scheduler.advance(by: 1)
XCTAssertEqual(output, [1])
```

This proves that we get the first emission from the publisher since one second of time has passed. If we further advance by one more second we can prove that we do not get anymore emissions:

```swift
scheduler.advance(by: 1)
XCTAssertEqual(output, [1])
```

This is a very simple example of how to control the flow of time with the test scheduler, but this technique can be used to test any publisher that involves Combine's asynchronous operations.

### `UIScheduler`

A scheduler that executes its work on the main queue as soon as possible.

If `UIScheduler.shared.schedule` is invoked from the main thread then the unit of work will be performed immediately. This is in contrast to `DispatchQueue.main.schedule`, which will incur a thread hop before executing since it uses `DispatchQueue.main.async` under the hood.

This scheduler can be useful for situations where you need work executed as quickly as possible on the main thread, and for which a thread hop would be problematic, such as when performing animations.

### `ImmediateScheduler`

The Combine framework comes with an `ImmediateScheduler` type of its own, but it defines all new types for the associated types of `SchedulerTimeType` and `SchedulerOptions`. This means you cannot easily swap between a live `DispatchQueue` and an "immediate" `DispatchQueue` that executes work synchronously. The only way to do that would be to introduce generics to any code making use of that scheduler, which can become unwieldy.

So, instead, this library's `ImmediateScheduler` uses the same associated types as an existing scheduler, which means you can use `DispatchQueue.immediateScheduler` to have a scheduler that looks like a dispatch queue but executes its work immediately. Similarly you can construct `RunLoop.immediateScheduler` and `OperationQueue.immediateScheduler`.

This scheduler is useful for writing tests against publishers that use asynchrony operators, such as `receive(on:)`, `subscribe(on:)` and others, because it forces the publisher to emit immediately rather than needing to wait for thread hops or delays using `XCTestExpectation`.

This scheduler is different from `TestScheduler` in that you cannot explicitly control how time flows through your publisher, but rather you are instantly collapsing time into a single point.

As a basic example, suppose you have a view model that loads some data after waiting for 10 seconds from when a button is tapped:

```swift
class HomeViewModel: ObservableObject {
  @Published var episodes: [Episode]?
  var cancellables: Set<AnyCancellable> = []

  let apiClient: ApiClient

  init(apiClient: ApiClient) {
    self.apiClient = apiClient
  }

  func reloadButtonTapped() {
    Just(())
      .delay(for: .seconds(10), scheduler: DispachQueue.main)
      .flatMap { apiClient.fetchEpisodes() }
      .sink { self.episodes = $0 }
      .store(in: &self.cancellables)
  }
}
```

In order to test this code you would literally need to wait 10 seconds for the publisher to emit:

```swift
func testViewModel() {
  let viewModel(apiClient: .mock)

  var output: [Episode] = []
  viewModel.$episodes
    .sink { output.append($0) }
    .store(in: &self.cancellables)

  viewModel.reloadButtonTapped()

  _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 10)

  XCTAssert(output, [Episode(id: 42)])
}
```

Alternatively, we can explicitly pass a scheduler into the view model initializer so that it can be controller from the outside:

```swift
class HomeViewModel: ObservableObject {
  @Published var episodes: [Episode]?
  var cancellables: Set<AnyCancellable> = []

  let apiClient: ApiClient
  let scheduler: AnySchedulerOf<DispatchQueue>

  init(apiClient: ApiClient, scheduler: AnySchedulerOf<DispatchQueue>) {
    self.apiClient = apiClient
    self.scheduler = scheduler
  }

  func reloadButtonTapped() {
    Just(())
      .delay(for: .seconds(10), scheduler: self.scheduler)
      .flatMap { self.apiClient.fetchEpisodes() }
      .sink { self.episodes = $0 }
      .store(in: &self.cancellables)
  }
}
```

And then in tests use an immediate scheduler:

```swift
func testViewModel() {
  let viewModel(
    apiClient: .mock,
    scheduler: DispatchQueue.immediateScheduler.eraseToAnyScheduler()
  )

  var output: [Episode] = []
  viewModel.$episodes
    .sink { output.append($0) }
    .store(in: &self.cancellables)

  viewModel.reloadButtonTapped()

  // No more waiting...

  XCTAssert(output, [Episode(id: 42)])
}
```

### `Publishers.Timer`

A publisher that emits a scheduler's current time on a repeating interval.

This publisher is an alternative to Foundation's `Timer.publisher`, with its primary difference being that it allows you to use any scheduler for the timer, not just `RunLoop`. This is useful because the `RunLoop` scheduler is not testable in the sense that if you want to write tests against a publisher that makes use of `Timer.publisher` you must explicitly wait for time to pass in order to get emissions. This is likely to lead to fragile tests and greatly bloat the time your tests take to execute.

It can be used much like Foundation's timer, except you specify a scheduler rather than a run loop:

```swift
Publishers.Timer(every: .seconds(1), scheduler: DispatchQueue.main)
  .autoconnect()
  .sink { print("Timer", $0) }
```

Alternatively you can call the `timerPublisher` method on a scheduler in order to derive a repeating timer on that scheduler:

```swift
DispatchQueue.main.timerPublisher(every: .seconds(1))
  .autoconnect()
  .sink { print("Timer", $0) }
```

But the best part of this timer is that you can use it with `TestScheduler` so that any Combine code you write involving timers becomes more testable. This shows how we can easily simulate the idea of moving time forward 1,000 seconds in a timer:

```swift
let scheduler = DispatchQueue.testScheduler
var output: [Int] = []

Publishers.Timer(every: 1, scheduler: scheduler)
  .autoconnect()
  .sink { _ in output.append(output.count) }
  .store(in: &self.cancellables)

XCTAssertEqual(output, [])

scheduler.advance(by: 1)
XCTAssertEqual(output, [0])

scheduler.advance(by: 1)
XCTAssertEqual(output, [0, 1])

scheduler.advance(by: 1_000)
XCTAssertEqual(output, Array(0...1_001))
```

## Learn More

The design of this library was explored in the following [Point-Free](https://www.pointfree.co) episodes:

  - [Episode 104](https://www.pointfree.co/episodes/ep104-combine-schedulers-testing-time): Testing Time
  - [Episode 105](https://www.pointfree.co/episodes/ep105-combine-schedulers-controlling-time): Controlling Time
  - [Episode 106](https://www.pointfree.co/episodes/ep106-combine-schedulers-erasing-time): Erasing Time

## Try It Out Today!

The official 0.1.0 release of [CombineSchedulers](http://github.com/pointfreeco/combine-schedulers) is on GitHub now, and we have more improvements and refinements coming soon. We hope that CombineSchedulers will help you test your application's Combine code.
""",
      timestamp: nil,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 45,
  publishedAt: Date(timeIntervalSince1970: 1592193600),
  title: "Open Sourcing CombineSchedulers"
)
