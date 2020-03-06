import Foundation

extension Episode {
  public static let ep79_effectfulStateManagement_thePoint = Episode(
    blurb: """
We've got the basic story of side effects in our architecture, but the story is far from over. Turns out that even side effects themselves are composable. Base effect functionality can be extracted and shared, and complex effects can be broken down into simpler pieces.
""",
    codeSampleDirectory: "0079-effectful-state-management-wtp",
    exercises: _exercises,
    id: 79,
    image: "https://i.vimeocdn.com/video/827840387.jpg",
    length: 28*60 + 36,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 78,
    publishedAt: Date(timeIntervalSince1970: 1572847200),
    references: [
      .elmCommandsAndSubscriptions,
      .reduxDataFlow,
      .reduxMiddleware,
      .reduxThunk,
      .reSwift,
      .swiftUIFlux,
      .elmHomepage,
      .reduxHomepage,
      .whyFunctionalProgrammingMatters,
      .composableReducers,
    ],
    sequence: 79,
    title: "Effectful State Management: The Point",
    trailerVideo: .init(
      bytesLength: 29754584,
      downloadUrl: "https://player.vimeo.com/external/369058178.hd.mp4?s=c5ac19402690f4129805871b9b4b9823b5621b18&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/369058178"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(problem: """
Right now the `isPrime` function is defined as a little helper in `IsPrimeModal.swift`. It's a very straightforward way of checking primes, but it can be slow for _very_ large primes. For example, using the `Counter` playground, start the application's state with the following very large prime number:

```
21,111,111,111,113
```

That's a two followed by _12_ ones and a three! If you ask if that number is prime, the UI will hang for about 5 seconds before showing the modal. Clearly not a great user experience.

To fix this, upgrade the `isPrime` helper to an `isPrime: Effect<Bool>` so that it can be run on a background queue. Make sure to also use `receive(on: .main)` so that the result of the effect is delivered back on the main queue.
"""),
  .init(problem: """
In the previous exercise you probably used a `DispatchQueue` directly in the definition of the `isPrime` effect. Rather than hard coding a queue in the effect, implement the following function that allows you to determine the queue an effect will be run from:

```swift
extension Effect {
  func run(on queue: DispatchQueue) -> Effect {
    fatalError("Unimplemented")
  }
}
```
"""),
  .init(problem: """
A "higher-order effect" is a function that takes an effect as input and returns an effect as output. This allows you to enrich an existing effect with additional behavior. We've already seen a few examples of this, such as `map` and `receive(on:)`. The next few exercises will walk you through writing a cancellation higher-order effect.

Start by implementing an effect transformation of the form:

```swift
extension Effect {
  func cancellable(id: String) -> Effect {
    fatalError("Unimplemented")
  }
}
```

This enriches an existing `Effect` with the behavior that allows it to be canceled at a later time. To achieve this, record whether or not a particular effect has been canceled by maintaining a private `[String: Bool]` dictionary at the file scope, and use the boolean to determine if future effect values should be delievered.
"""),
  .init(problem: """
Continuing the previous exercise, implement an effect that can cancel an in-flight effect with a particular `id`:

```swift
extension Effect {
  static func cancel(id: String) -> Effect {
    fatalError("Unimplemented")
  }
}
```
"""),
  .init(problem: """
Continuing the previous exercise, in the `counterReducer`, cancel an in-flight `nthPrime` effect whenever either the increment or decrement buttons are tapped.
"""),
  .init(problem: """
Continuing the previous exercise, improve the implementations of `cancellable` and `cancel` by:

* Allow for any `Hashable` id, not just a `String`.
* Use a `DispatchWorkItem` to represent the cancellable unit of work instead of a `Bool`.
* Use a `os_unfair_lock` to properly protect access to the private dictionary that holds the `DispatchWorkItem`'s.
"""),
  .init(problem: """
Using the previous exercise on cancellation as inspiration, create a similar higher-order effect for debouncing an existing effect:

```swift
extension Effect {
  public func debounce<Id: Hashable>(
    for duration: TimeInterval,
    id: Id
  ) -> Effect {
    fatalError("Unimplemented)"
  }
}
```

This should cancel any existing in-flight effect with the same `id` while delay the current effect by the `duration` passed.
"""),
  .init(problem: """
Use the `debounce` higher-order effect to implement automatic saving of favorite primes by debouncing _any_ `AppAction` by 10 seconds and then performing the save effect.
"""),
  .init(problem: """
Consider an effect of the form `Effect<Never>`. What can be said about how such an effect behaves without knowing anything about how it works internally?
"""),
  .init(problem: """
Implement the following function for transforming an `Effect<Never>` into an `Effect<B>`:

```swift
extension Effect where A == Never {
  func fireAndForget<B>() -> Effect<B> {
    fatalError("Unimplemented")
  }
}
```
"""),
  .init(problem: """
Consider an analytics client that can track events by using an `Effect`:

```swift
struct AnalyticsClient {
  let track: (String) -> Effect<???>
}
```

What type of generic should be used for the `Effect`?
"""),
  .init(problem: """
Construct a live implementation of the above analytics client:

```swift
extension AnalyticsClient {
  static let live: AnalyticsClient = ???
}
```

For now you can just perform `print` statements, but in a real production application you could make an API request to your analytics provider.

Use the above live analytics client to instrument the reducers in the PrimeTime application. You may find the `fireAndForget` function to be helpful for using the analytics effects in our reducers.
""")
]
