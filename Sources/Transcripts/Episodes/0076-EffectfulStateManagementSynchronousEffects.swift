import Foundation

extension Episode {
  static let ep76_effectfulStateManagement_synchronousEffects = Episode(
    blurb: """
      Side effects are one of the biggest sources of complexity in any application. It's time to figure out how to model effects in our architecture. We begin by adding a few new side effects, and then showing how synchronous effects can be handled by altering the signature of our reducers.
      """,
    codeSampleDirectory: "0076-effectful-state-management-synchronous-effects",
    exercises: _exercises,
    id: 76,
    length: 25 * 60 + 24,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_571_032_800),
    references: [
      reference(
        forEpisode: .ep2_sideEffects,
        additionalBlurb: """
          We first discussed side effects on the second episode of Point-Free. In that episode we showed how side effects are nothing but hidden inputs or outputs lurking in the signature of our functions. We also showed that making that implicit behavior into something explicit makes our code most understandable and testable.
          """,
        episodeUrl: "https://www.pointfree.co/episodes/ep2-side-effects"
      ),
      reference(
        forEpisode: .ep16_dependencyInjectionMadeEasy,
        additionalBlurb: """
          One of the easiest ways to control side effects is through the use of "dependency injection." In an early episode of Point-Free we showed a lightweight way to manage dependencies that gets rid of a lot of the boilerplate that is common in the Swift community.
          """,
        episodeUrl: "https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy"
      ),
      .reduxMiddleware,
      .reduxThunk,
      .reSwift,
      .swiftUIFlux,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 76,
    subtitle: "Synchronous Effects",
    title: "Effectful State Management",
    trailerVideo: .init(
      bytesLength: 35_772_530,
      downloadUrls: .s3(
        hd1080: "0076-trailer-1080p-7d6546836cf042888966d6686fa3dfc8",
        hd720: "0076-trailer-720p-ef690e7bee91460d9d7ffcd77669eb20",
        sd540: "0076-trailer-540p-ec5ae322309843908881c3fd859ed53a"
      ),
      id: "7828bfc803905db62e13a4efa76bd943"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      Currently effects have no way of making changes to the app state, which is what is needed to implement the effect for loading favorite primes. One way to allow for this is to change the definition of `Effect` so that a mutable state value is passed to the effect:

      ```diff
      -typealias Effect<State> = () -> Void
      +typealias Effect<State> = (inout State) -> Void
      ```

      Fix the app to build with the above change. Implement the effect to load the favorite primes using this type of effect.

      Does this style of effect align with one of the central tenets of our architecture, which is that we should have a single, consistent way to mutate state? Why or why not?
      """#),
  Episode.Exercise(
    problem: #"""
      If instead of allowing effects to mutate state directly, what if we wanted to allow effects to send actions to the store? How could the definition of `Effect` be changed to allow this?
      """#),
  Episode.Exercise(
    problem: #"""
      Not every reducer needs to perform side effects. Write a function that can lift any side-effectless reducer into a signature that supports side effects. Such a function would have the following signature:

      ```swift
      typealias Effect = () -> Void
      typealias Reducer<State, Action> = (inout State, Action) -> Effect

      func pure<State, Action>(
        _ reducer: (inout State, Action) -> Void
      ) -> Reducer<State, Action> {
        fatalError("Unimplemented")
      }
      ```
      """#),
]
