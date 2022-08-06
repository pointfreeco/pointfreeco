import Foundation

public let post0079_ConcurrencyRelease = BlogPost(
  author: .pointfree,
  blurb: """
    Today we are releasing the biggest update to the Composable Architecture since it's first
    release over 2 years ago. The library has all new concurrency tools allowing you to construct
    complex effects using structured concurrency, tie effect lifetimes to view lifetimes, and
    we accomplish all of this while keeping your code 100% testable. We think it might even be the
    best way to test concurrent code in SwiftUI applications. 😇
    """,
  contentBlocks: [
    .init(
      content: ###"""
        Today is a very special day. It both marks the 200th episode of [Point-Free](/) _and_
        the biggest release of our popular library, [the Composable Architecture][tca-github],
        since its first release over 2 years ago. In those two years we've had 51 releases, 76
        contributors, 6,600 stars, and now receive over 10,000 clones a week and 20,000 visits a
        week to its GitHub page.

        This update brings all-new concurrency tools to the library, allowing you to construct
        complex effects using structured concurrency, tie effect lifetimes to view lifetimes, and
        we accomplish all of this while keeping your code 100% testable. We think it might even be
        the best way to test concurrent code in SwiftUI applications. 😇

        ## Structured effects

        The library's dependence on Combine for effects is now considered "soft-deprecated." Rather
        than using Combine publishers and magical incantations of publisher operators to express
        your effects, you can now write complex effects from top-to-bottom using Swift's structured
        concurrency tools.

        As an example, in the [speech recognition demo][speech-recognition-demo] from the repo we
        construct an effect that:

        1. Ask the user for speech authorization and, if granted,
        1. Start a voice recognition task to get a stream of transcription results.

        Previously this was quite complex with Combine, requiring expert use of `flatMap`, `filter`
        and `map` operators, but can now be a simple combination of `await`, `guard` and
        `for await`:

        ```swift
        case .recordButtonTapped:
          return Effect.run { send in
            // 1️⃣ Ask user for speech recording permission.
            let status = await speechClient.requestAuthorization()
            await send(.speechRecognizerAuthorizationStatusResponse(status))

            // 2️⃣ If not authorized, then there's nothing more to do.
            guard status == .authorized
            else { return }

            // 3️⃣ If authorized, then start recording audio and live transcribing.
            let request = SFSpeechAudioBufferRecognitionRequest()
            for try await result in await speechClient.startTask(request) {
              await send(
                .speech(result.bestTranscription.formattedString),
                animation: .linear
              )
            }
          }
        ```

        This will greatly simplify how you construct complex effects. You can make use of all the
        tools Swift gives us for concurrency, such as `await` for concatenating asynchronous work,
        `for await` for subscribing to async sequences, as well as `async let` and task groups
        for running multiple units of work in parallel.

        For a deep-dive into Swift's structured concurrency tools be sure to check our
        [concurrency collection][concurrency-collection] of episodes.

        ## Effect lifetimes

        SwiftUI has a useful view modifier called [`task`][task-view-modifier] that allows you to
        start an asynchronous task when a view appears, and the task will be automatically
        cancelled when the view disappears. This is great for tying the lifetime of some work you
        want to perform to the lifetime of the view.

        By more deeply integrating concurrency into the Composable Architecture we make it possible
        to tie the lifetime of effects to the lifetime of views. For example, in the view we can
        send an action to the view store representing the view appeared, and we can await its
        completion:

        ```swift
        struct ContentView: View {
          let store: Store<State, Action>

          var body: some View {
            WithViewStore(self.store) { viewStore in
              <#View omitted#>
                .task { await viewStore.send(.task).finish() }
            }
          }
        }
        ```

        Then, in the reducer, we can return a long-living effect, such as subscribing to an async
        sequence of notifications:

        ```swift
        case .task:
          <#Reducer logic omitted#>
          return .run { send in
            for await value in environment.notifications() {
              send(.result(value))
            }
          }
        ```

        With this setup, if the view disappears it will automatically cancel the effect and tear
        down the async sequence. There's no need to send additional actions from the view in order
        to manually cancel the effect.

        ## Testable concurrency

        Not only does the library now have tools for fully leveraging everything that Swift's
        structured concurrency gives us, but it's all still 100% testable. In fact, we think that
        the Composable Architecture offers one of the most cohesive testing solutions for
        integrated asynchronous code in the entire Swift ecosystem.

        The [`TestStore`][test-store-docs] that ships with the library to aid in testing is now
        async-aware. When in an async context you can now await sending and receiving actions to
        the test store in order to allow asynchronous effects to execute and feed their data
        back into the system:

        ```swift
        @MainActor
        class FeatureTest: XCTestCase {
          func testBasics() async {
            let store = TestStore(…)

            await store.send(.factButtonTapped) {
              $0.isLoading = true
            }
            await store.receive(.factResponse(.success("42 is a good number!"))) {
              $0.isLoading = false
              $0.fact = "42 is a good number!"
            }
          }
        }
        ```

        We are also shipping an update to our [Combine Schedulers][combine-schedulers-github]
        library that gives the `Scheduler` protocol an interface similar to Swift 5.7's new
        [`Clock`][clock-evo] protocol. Rather than telling a scheduler to perform some work at a
        later time you can now tell a scheduler to suspend for a duration of time:

        ```swift
        try await mainQueue.sleep(for: .seconds(1))
        ```

        This allows you to perform time-based asynchrony, and because schedulers are testable,
        thanks to [`TestScheduler`][test-scheduler-docs] and
        [`ImmediateScheduler`][immediate-scheduler-docs], we can fully test all features that make
        use of time-based asynchrony.

        For example, in the [animations case study][animations-case-study-source] we demonstrate
        how to cycle through a bunch of colors with a 1 second pause between each color:

        ```swift
        return .run { send in
          for color in [Color.red, .blue, .green, .orange, .pink, .purple, .yellow, .black] {
            await send(.setColor(color), animation: .linear)
            try await environment.mainQueue.sleep(for: 1)
          }
        }
        ```

        This effect can be [tested][animations-test-source] using a test scheduler, which allows you
        to explicitly advance time forward in order to understand how the time-based effect
        executes. In particular, if we advance 7 seconds we will receive 7 actions for each color
        after the first one:

        ```swift
        func testRainbow() async {
          await store.send(.rainbowButtonTapped)
          await store.receive(.setColor(.red)) {
            $0.circleColor = .red
          }

          await mainQueue.advance(by: .seconds(7))
          await store.receive(.setColor(.blue)) {
            $0.circleColor = .blue
          }
          await store.receive(.setColor(.green)) {
            $0.circleColor = .green
          }
          await store.receive(.setColor(.orange)) {
            $0.circleColor = .orange
          }
          await store.receive(.setColor(.pink)) {
            $0.circleColor = .pink
          }
          await store.receive(.setColor(.purple)) {
            $0.circleColor = .purple
          }
          await store.receive(.setColor(.yellow)) {
            $0.circleColor = .yellow
          }
          await store.receive(.setColor(.black)) {
            $0.circleColor = .black
          }
        }
        ```

        This makes it possible to test very complex and nuanced effects in a deterministic manner.
        We think these are some of the most ergonomic testing tools available to the greater Swift
        ecosystem.

        ## Upgrade to 0.39.0 today!

        Starting today you can update your applications to use
        [the Composable Architecture 0.39.0][tca-0-39-0] to get access to all of these tools and
        more. You can also update any usages of Combine Schedulers to
        [0.7.0][combine-schedulers-0-7-0] in order to start writing time-based asynchronous feature
        code without sacrificing testability, even if you are not using the Composable Architecture.

        If you are interested in the decisions and thinking that went into these releases be sure
        to watch our [Async Composable Architecture][async-tca-collection] series of episodes
        to see how these tools were built from first principles.

        [tca-github]: http://github.com/pointfreeco/swift-composable-architecture
        [speech-recognition-demo]: https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/SpeechRecognition
        [concurrency-collection]: /collections/concurrency
        [async-tca-collection]: /collections/composable-architecture/async-composable-architecture
        [task-view-modifier]: https://developer.apple.com/documentation/swiftui/view/task(priority:_:)
        [test-store-docs]: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/teststore
        [combine-schedulers-github]: http://github.com/pointfreeco/combine-schedulers
        [test-scheduler-docs]: https://pointfreeco.github.io/combine-schedulers/TestScheduler/
        [immediate-scheduler-docs]: https://pointfreeco.github.io/combine-schedulers/ImmediateScheduler/
        [animations-case-study-source]: https://github.com/pointfreeco/swift-composable-architecture/blob/main/Examples/CaseStudies/SwiftUICaseStudies/01-GettingStarted-Animations.swift
        [animations-test-source]: https://github.com/pointfreeco/swift-composable-architecture/blob/main/Examples/CaseStudies/SwiftUICaseStudiesTests/01-GettingStarted-AnimationsTests.swift#L8-L61
        [tca-0-39-0]: https://github.com/pointfreeco/swift-composable-architecture/releases/tag/0.39.0
        [combine-schedulers-0-7-0]: https://github.com/pointfreeco/combine-schedulers/releases/tag/0.7.0
        [clock-evo]: https://github.com/apple/swift-evolution/blob/main/proposals/0329-clock-instant-duration.md
        """###,
      type: .paragraph
    )
  ],
  coverImage: nil,
  id: 79,  
  publishedAt: Date(timeIntervalSince1970: 1659934800),
  title: "Async Composable Architecture"
)
