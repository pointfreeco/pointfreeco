import Foundation

extension Episode {
  static let ep77_effectfulStateManagement_unidirectionalEffects = Episode(
    blurb: """
      We've modeled side effects in our architecture, but it's not quite right yet: a reducer can write to the outside world, but it can't read data back in! This week our architecture's dedication to unidirectional data flow will lead us there.
      """,
    codeSampleDirectory: "0077-effectful-state-management-unidirectional-effects",
    exercises: _exercises,
    id: 77,
    length: 25 * 60 + 24,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_571_637_600),
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
      downloadUrls: .s3(
        hd1080: "0077-trailer-1080p-b5440974154a4de9bbc0d758dbb903d2",
        hd720: "0077-trailer-720p-0e6a33607ba8419990e57844154c0427",
        sd540: "0077-trailer-540p-e9dd6cf739ff479c8bf7f817002ee003"
      ),
      vimeoId: 367_748_928
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      Add support for tracking the "last saved at" date on the favorite primes screen.
      """#),
  Episode.Exercise(
    problem: #"""
      Introduce UI that displays this "last saved at" date on the favorite primes screen.
      """#),
  // TODO: Error handling exercise for "save"? The failures are pretty extreme (file system is not writable or disk is full)...
  Episode.Exercise(
    problem: #"""
      Add error handling to the load favorite primes effect. A failure to load some favorite primes is currently ignored. This means that if a user has never saved any favorite primes, an attempt to load some favorite primes will fail silently. Instead, it would be nice to present a friendly alert to the end user on failure.

      Update the favorite primes action, state, reducer, and view accordingly to support this feature.
      """#),
  Episode.Exercise(
    problem: #"""
      Incorporate the side effect of asking Wolfram Alpha for the "nth" prime into the counter reducer.

      In order to do so _without_ further changing the shape of `Effect`, you may need to introduce some logic to make the asynchronous nature of this effect synchronous, which is something we've previously covered in our episode on [Async Functional Refactoring](/episodes/ep40-async-functional-refactoring#t731).

      What kinds of problems does this solution introduce to the application?
      """#),
  Episode.Exercise(
    problem: #"""
      In the past on Point-Free, we have modeled asynchrony with the `Parallel` type, which is defined as follows:

      ```swift
      struct Parallel<A> {
        let run: (@escaping (A) -> Void) -> Void
      }
      ```

      Update `Effect` to have the same shape and explore how it affects the architecture and the "nth prime" effect.
      """#),
]
