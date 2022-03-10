import Foundation

extension Episode {
  static let ep78_effectfulStateManagement_asynchronousEffects = Episode(
    blurb: """
It's time to finish our architecture's story for side effects. We've described synchronous effects and unidirectional effects, but we still haven't captured the complexity of async effects. Let's fix that with a final, functional refactor.
""",
    codeSampleDirectory: "0078-effectful-state-management-async-effects",
    exercises: _exercises,
    id: 78,
    length: 35 * 60 + 48,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1572242400),
    references: [
      .elmCommandsAndSubscriptions,
      .reduxDataFlow,
      .reduxMiddleware,
      .reduxThunk,
      .reSwift,
      .swiftUIFlux,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 78,
    subtitle: "Asynchronous Effects",
    title: "Effectful State Management",
    trailerVideo: .init(
      bytesLength: 43_957_479,
      downloadUrls: .s3(
        hd1080: "0078-trailer-1080p-4a750a521cc848dbb672404843da044f",
        hd720: "0078-trailer-720p-f2e9e14a61f742388d07f924951c6570",
        sd540: "0078-trailer-540p-2700cb3501794fb19f3f767dfc59f0e7"
      ),
      vimeoId: 369002675
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: #"""
Our `Effect` is currently just a type alias:

```swift
typealias Effect<Action> = (@escaping (Action) -> Void) -> Void
```

Upgrade it to be a struct wrapper around a function, like the parallel type:

```swift
struct Parallel<A> {
  let run: (@escaping (A) -> Void) -> Void
}
```

Make the necessary changes to get the application building again.
"""#),
  Episode.Exercise(problem: #"""
Define `map` as a method on `Effect`.

```swift
struct Effect<A> {
  …
  func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
    fatalError("TODO")
  }
```
"""#),
  Episode.Exercise(problem: #"""
Use Effect's `map` method to decouple the work of a side effect from the work that wraps its result in a reducer action. For example: rather than explicitly wrap the nth prime in an `nthPrimeResponse` in the main effect, chain that work into a `map` on an `Effect<Int?>`.
"""#),
  Episode.Exercise(problem: #"""
Extend `Effect` with a `receive(on queue: DispatchQueue)` method to decouple the async-on-main work we did when handling the nth prime response. Update the nth prime effect to use this method.
"""#),
  Episode.Exercise(problem: #"""
Define `zip` on `Effect`.

```swift
func zip<A, B>(_ a: Effect<A>, _ b: Effect<B>) -> Effect<(A, B)> {
  fatalError("TODO")
}
```

What might this function be useful for? If you are new to the `zip` function, we devoted an entire series to the concept, starting [here](/episodes/ep23-the-many-faces-of-zip-part-1).
"""#),
  Episode.Exercise(problem: #"""
Define `flatMap` on `Effect`.

```swift
struct Effect<A> {
  …
  func flatMap<B>(_ f: @escaping (A) -> Effect<B>) -> Effect<B> {
    fatalError("TODO")
  }
```

What might this function be useful for? If you are new to the `flatMap` function, we devoted an entire series to the concept, starting [here](/episodes/ep42-the-many-faces-of-flat-map-part-1).
"""#),
  Episode.Exercise(problem: #"""
When we incorporated alert presentation into our architecture, we needed to explicitly introduce a dismissal event to `nil` out alert state. While we did so with an alert button action, an alternative would have been to let SwiftUI feed a dismiss action to the store via the binding.

Rewrite the alert dismissal to use a non-constant `Binding` with a setter that sends a dismiss action to the store.
"""#),
  Episode.Exercise(problem: #"""
Write a helper method on `Store` that simplifies the presentation of optional sub-state by returning a binding of an optional sub-store.

```swift
func presentation<PresentedValue>(
  _ value: KeyPath<Value, PresentedValue?>,
  dismissAction: Action
) -> Binding<Store<PresentedValue, Action>?>
```

Use this method to present the nth prime alert.
"""#),
]
