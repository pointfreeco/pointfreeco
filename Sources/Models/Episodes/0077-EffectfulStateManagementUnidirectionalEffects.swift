import Foundation

extension Episode {
  static let ep77_effectfulStateManagement_unidirectionalEffects = Episode(
    blurb: """
We've modeled side effects in our architecture, but it's not quite right yet: a reducer can write to the outside world, but it can't read data back in! This week our architecture's dedication to unidirectional data flow will lead us there.
""",
    codeSampleDirectory: "0077-effectful-state-management-unidirectional-effects",
    exercises: _exercises,
    id: 77,
    image: "https://i.vimeocdn.com/video/824231505.jpg",
    length: 25*60 + 24,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1571637600),
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
    sequence: 77,
    subtitle: "Unidirectional Effects",
    title: "Effectful State Management",
    trailerVideo: .init(
      bytesLength: 43_134_899,
      downloadUrl: "https://player.vimeo.com/external/367748928.hd.mp4?s=ec488585bf79c278cafb9f79ff18615415a5bf3d&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/367748928"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(problem: #"""
Add support for tracking the "last saved at" date on the favorite primes screen.
"""#),
  Episode.Exercise(problem: #"""
Introduce UI that displays this "last saved at" date on the favorite primes screen.
"""#),
  // TODO: Error handling exercise for "save"? The failures are pretty extreme (file system is not writable or disk is full)...
  Episode.Exercise(problem: #"""
Add error handling to the load favorite primes effect. A failure to load some favorite primes is currently ignored. This means that if a user has never saved any favorite primes, an attempt to load some favorite primes will fail silently. Instead, it would be nice to present a friendly alert to the end user on failure.

Update the favorite primes action, state, reducer, and view accordingly to support this feature.
"""#),
  Episode.Exercise(problem: #"""
Incorporate the side effect of asking Wolfram Alpha for the "nth" prime into the counter reducer.

In order to do so _without_ further changing the shape of `Effect`, you may need to introduce some logic to make the asynchronous nature of this effect synchronous, which is something we've previously covered in our episode on [Async Functional Refactoring](/episodes/ep40-async-functional-refactoring#t731).

What kinds of problems does this solution introduce to the application?
"""#),
  Episode.Exercise(problem: #"""
In the past on Point-Free, we have modeled asynchrony with the `Parallel` type, which is defined as follows:

```swift
struct Parallel<A> {
  let run: (@escaping (A) -> Void) -> Void
}
```

Update `Effect` to have the same shape and explore how it affects the architecture and the "nth prime" effect.
"""#),
]
