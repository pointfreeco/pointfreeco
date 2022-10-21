import Foundation

public let post0082_AnnouncingClocks = BlogPost(
  author: .pointfree,
  blurb: """
    Today we are open sourcing swift-clocks, a collection of tools that make working with Swift concurrency more testable and more versatile.
    """,
  contentBlocks: [
    .init(
      content: #"""
        Over the past [couple weeks](/collections/concurrency/clocks) we explored Swift 5.7's new `Clock` protocol, compared it to [Combine's `Scheduler` protocol](/collections/combine/schedulers), and defined a whole bunch of useful conformances.

        We believe these tools are highly applicable to everyone working with time-based asynchrony in Swift, and so today we are excited to release them in [a new open source library](https://swiftpackageindex.com/pointfreeco/swift-clocks).

        ## Motivation

        The `Clock` protocol in provides a powerful abstraction for time-based asynchrony in Swift's
        structured concurrency. With just a single `sleep` method you can express many powerful async
        operators, such as timers, `debounce`, `throttle`, `timeout` and more (see
        [swift-async-algorithms][swift-async-algorithms]).

        However, the moment you use a concrete clock in your asynchronous code, or use `Task.sleep`
        directly, you instantly lose the  ability to easily test and preview your features, forcing you to
        wait for real world time to pass to see how your feature works.

        ## Tools

        This library provides new `Clock` conformances that allow you to turn any time-based asynchronous
        code into something that is easier to test and debug.

        ### `TestClock`

        A clock whose time can be controlled in a deterministic manner.

        This clock is useful for testing how the flow of time affects asynchronous and concurrent code.
        This includes any code that makes use of `sleep` or any time-based async operators, such as
        `debounce`, `throttle`, `timeout`, and more.

        For example, suppose you have a model that encapsulates the behavior of a timer that be started and
        stopped, and with each tick of the timer a count value was incremented:

        ```swift
        @MainActor
        class FeatureModel: ObservableObject {
          @Published var count = 0
          let clock: any Clock<Duration>
          var timerTask: Task<Void, Error>?

          init(clock: any Clock<Duration>) {
            self.clock = clock
          }
          func startTimerButtonTapped() {
            self.timerTask = Task {
              while true {
                try await self.clock.sleep(for: .seconds(1))
                self.count += 1
              }
            }
          }
          func stopTimerButtonTapped() {
            self.timerTask?.cancel()
            self.timerTask = nil
          }
        }
        ```

        Note that we have explicitly forced a clock to be provided in order to construct the `FeatureModel`.
        This makes it possible to use a real life clock, such as `ContinuousClock`, when running on a device
        or simulator, and use a more controllable clock in tests, such as the `TestClock`.

        To write a test for this feature we can construct a `FeatureModel` with a `TestClock`, then advance
        the clock forward and assert on how the model changes:

        ```swift
        func testTimer() async {
          let clock = TestClock()
          let model = FeatureModel(clock: clock)

          XCTAssertEqual(model.count, 0)
          model.startTimerButtonTapped()

          await clock.advance(by: .seconds(1))
          XCTAssertEqual(model.count, 1)

          await clock.advance(by: .seconds(4))
          XCTAssertEqual(model.count, 5)

          model.stopTimerButtonTapped()
          await clock.run()
          XCTAssertEqual(model.count, 5)
        }
        ```

        This test is easy to write, passes deterministically, and takes a fraction of a second to run. If
        you were to use a concrete clock in your feature, such as test would be difficult to write. You
        would have to wait for real time to pass, slowing down your test suite, and you would have to take
        extra care to allow for the inherent imprecision in time-based asynchrony so that you do not have
        flakey tests.

        ### `ImmediateClock`

        A clock that does not suspend when sleeping.

        This clock is useful for squashing all of time down to a single instant, forcing any `sleep`s to
        execute immediately. For example, suppose you have a feature that needs to wait 5 seconds before
        performing some action, like showing a welcome message:

        ```swift
        struct Feature: View {
          @State var message: String?

          var body: some View {
            VStack {
              if let message = self.message {
                Text(self.message)
              }
            }
            .task {
              do {
                try await Task.sleep(for: .seconds(5))
                self.message = "Welcome!"
              } catch {}
            }
          }
        }
        ```

        This is currently using a real life clock by calling out to `Task.sleep`, which means every change
        you make to the styling and behavior of this feature you must wait for 5 real life seconds to pass
        before you see the affect. This will severely hurt you ability to quickly iterate on the feature in
        an Xcode preview.

        The fix is to have your view hold onto a clock so that it can be controlled from the outside:

        ```swift
        struct Feature: View {
          @State var message: String?
          let clock: any Clock<Duration>

          var body: some View {
            VStack {
              if let message = self.message {
                Text(self.message)
              }
            }
            .task {
              do {
                try await self.clock.sleep(for: .seconds(5))
                self.message = "Welcome!"
              } catch {}
            }
          }
        }
        ```

        Then you can construct this view with a `ContinuousClock` when running on a device or simulator,
        and use an ``ImmediateClock`` when running in an Xcode preview:

        ```swift
        struct Feature_Previews: PreviewProvider {
          static var previews: some View {
            Feature(clock: .immediate)
          }
        }
        ```

        Now the welcome message will be displayed immediately with every change made to the view. No
        need to wait for 5 real world seconds to pass.

        You can also propagate a clock to a SwiftUI view via the `continuousClock` and `suspendingClock`
        environment values that ship with the library:

        ```swift
        struct Feature: View {
          @State var message: String?
          @Environment(\.continuousClock) var clock

          var body: some View {
            VStack {
              if let message = self.message {
                Text(self.message)
              }
            }
            .task {
              do {
                try await self.clock.sleep(for: .seconds(5))
                self.message = "Welcome!"
              } catch {}
            }
          }
        }

        struct Feature_Previews: PreviewProvider {
          static var previews: some View {
            Feature()
              .environment(\.continuousClock, .immediate)
          }
        }
        ```

        ### `UnimplementedClock`

        A clock that causes an XCTest failure when any of its endpoints are invoked.

        This test is useful when a clock dependency must be provided to test a feature, but you don't
        actually expect the clock to be used in the particular execution flow you are exercising.

        For example, consider the following model that encapsulates the behavior of being able to increment
        and decrement a count, as well as starting and stopping a timer that increments the counter every
        second:

        ```swift
        @MainActor
        class FeatureModel: ObservableObject {
          @Published var count = 0
          let clock: any Clock<Duration>
          var timerTask: Task<Void, Error>?

          init(clock: any Clock<Duration>) {
            self.clock = clock
          }
          func incrementButtonTapped() {
            self.count += 1
          }
          func decrementButtonTapped() {
            self.count -= 1
          }
          func startTimerButtonTapped() {
            self.timerTask = Task {
              for await _ in self.clock.timer(interval: .seconds(1)) {
                self.count += 1
              }
            }
          }
          func stopTimerButtonTapped() {
            self.timerTask?.cancel()
            self.timerTask = nil
          }
        }
        ```

        If we test the flow of the user incrementing and decrementing the count, there is no need for the
        clock. We don't expect any time-based asynchrony to occur. To make this clear, we can use an
        `UnimplementedClock`:

        ```swift
        func testIncrementDecrement() {
          let model = FeatureModel(clock: UnimplementedClock())

          XCTAssertEqual(model.count, 0)
          self.model.incrementButtonTapped()
          XCTAssertEqual(model.count, 1)
          self.model.decrementButtonTapped()
          XCTAssertEqual(model.count, 0)
        }
        ```

        If this test passes it definitively proves that the clock is not used at all in the user flow being
        tested, making this test stronger. If in the future the increment and decrement endpoints start
        making use of time-based asynchrony using the clock, we will be instantly notified by test failures.
        This will help us find the tests that should be updated to assert on the new behavior in the
        feature.

        ### Timers

        All clocks now come with a method that allows you to create an `AsyncSequence`-based timer on an
        interval specified by a duration. This allows you to handle timers with simple `for await` syntax,
        such as this observable object that exposes the ability to start and stop a timer for incrementing a
        value every second:

        ```swift
        @MainActor
        class FeatureModel: ObservableObject {
          @Published var count = 0
          let clock: any Clock<Duration>
          var timerTask: Task<Void, Error>?

          init(clock: any Clock<Duration>) {
            self.clock = clock
          }
          func startTimerButtonTapped() {
            self.timerTask = Task {
              for await _ in self.clock.timer(interval: .seconds(1)) {
                self.count += 1
              }
            }
          }
          func stopTimerButtonTapped() {
            self.timerTask?.cancel()
            self.timerTask = nil
          }
        }
        ```

        This feature can also be easily tested by making use of the `TestClock` discussed above:

        ```swift
        func testTimer() async {
          let clock = TestClock()
          let model = FeatureModel(clock: clock)

          XCTAssertEqual(model.count, 0)
          model.startTimerButtonTapped()

          await clock.advance(by: .seconds(1))
          XCTAssertEqual(model.count, 1)

          await clock.advance(by: .seconds(4))
          XCTAssertEqual(model.count, 5)

          model.stopTimerButtonTapped()
          await clock.run()
        }
        ```

        ## Try it today

        [swift-clocks 0.1.0](https://github.com/pointfreeco/swift-clocks/releases/tag/0.1.0) is available today! Give it a spin to introduce controllable, time-based asynchrony to your Swift applications. And if you're a user of [the Composable Architecture](/collections/composable-architecture), try out [the latest release](https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.44.0) to bring these tools to your reducers!

        [swift-async-algorithms]: http://github.com/apple/swift-async-algorithms
        """#,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 82,
  publishedAt: Date(timeIntervalSince1970: 1_666_587_600),
  title: "Open Sourcing swift-clocks"
)
