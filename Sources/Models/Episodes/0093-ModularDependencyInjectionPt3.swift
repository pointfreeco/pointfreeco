import Foundation

extension Episode {
  static let ep93_modularDependencyInjection_pt3 = Episode(
    blurb: """
      It's time to prove that baking an "environment" of dependencies directly into the Composable Architecture solves three crucial problems that the global environment pattern could not.
      """,
    codeSampleDirectory: "0093-modular-dependency-injection-pt3",
    exercises: _exercises,
    id: 93,
    image: "https://i.vimeocdn.com/video/860844665.jpg",
    length: 44 * 60 + 54,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_583_128_800),
    references: [
      reference(
        forEpisode: .ep16_dependencyInjectionMadeEasy,
        additionalBlurb:
          #"This is the episode that first introduced our `Current` environment approach to dependency injection."#,
        episodeUrl: "https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy"
      ),
      reference(
        forEpisode: .ep18_dependencyInjectionMadeComfortable,
        additionalBlurb: #""#,
        episodeUrl: "https://www.pointfree.co/episodes/ep18-dependency-injection-made-comfortable"
      ),
      .howToControlTheWorld,
      reference(
        forEpisode: .ep76_effectfulStateManagement_synchronousEffects,
        additionalBlurb:
          #"This is the start of our series of episodes on "effectful" state management, in which we explore how to capture the idea of side effects directly in our composable architecture."#,
        episodeUrl:
          "https://www.pointfree.co/episodes/ep76-effectful-state-management-synchronous-effects"
      ),
      reference(
        forEpisode: .ep82_testableStateManagement_reducers,
        additionalBlurb:
          #"This is the start of our series of episodes on "testable" state management, in which we explore just how testable the Composable Architecture is, effects and all!"#,
        episodeUrl: "https://www.pointfree.co/episodes/ep82-testable-state-management-reducers"
      ),
    ],
    sequence: 93,
    title: "Modular Dependency Injection: The Point",
    trailerVideo: .init(
      bytesLength: 875210,
      downloadUrl:
        "https://player.vimeo.com/external/394821197.hd.mp4?s=9bdad93f5261ced6f8aa4c7d0b71f911fd56f28b&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/394821197"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
      It is very common for APIs that work with `Equatable` types to be defined alongside similar APIs that work with any type given a predicate function `(A, A) -> Bool`. For instance, in `Combine` there is a `removeDuplicates()` method on publishers of equatable values, while there is a similar, `removeDuplicates(by:)` method on publishers of any value.

      In our architecture, the `assert` helper is currently constrained over equatable values and actions:

      ```swift
      public func assert<Value: Equatable, Action: Equatable, Environment>(
        initialValue: Value,
        reducer: Reducer<Value, Action, Environment>,
        environment: Environment,
        steps: Step<Value, Action>...,
        file: StaticString = #file,
        line: UInt = #line
      )
      ```

      Using `removeDuplicates(by:)` as a template, define a version of `assert` that works on non-equatable values and actions:
      """#,
    solution: #"""
      You can update the function signature to take `valueIsEqual` and `actionIsEqual` functions:

      ```swift
      public func assert<Value, Action, Environment>(
        valueIsEqual: (Value, Value) -> Bool,
        actionIsEqual: (Action, Action) -> Bool,
        initialValue: Value,
        reducer: Reducer<Value, Action, Environment>,
        environment: Environment,
        steps: Step<Value, Action>...,
        file: StaticString = #file,
        line: UInt = #line
      )
      ```

      And then, rather than call to `XCTAssertEqual`, we can call `XCTAssert` with the result of `actionIsEqual` and `valueIsEqual`:

      ```swift
      XCTAssert(actionIsEqual(action, step.action), file: step.file, line: step.line)
      …
      XCTAssert(valueIsEqual(state, expected), file: step.file, line: step.line)
      ```
      """#
  ),
  Episode.Exercise(
    problem: #"""
      In this episode we see a problem with the `offlineNthPrime` dependency where inefficient computations entirely hang the interface. Update this dependency to run on a non-UI thread to fix this bug.
      """#,
    solution: #"""
      By using `subscribe(on:)` and `receive(on:)`, you can ensure that the work is done on a global background queue and received on the main UI queue:

      ```swift
      public func offlineNthPrime(_ n: Int) -> Effect<Int?> {
        Deferred {
          Future { callback in
            …
            callback(.success(nthPrime))
          }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToEffect()
      }
      ```
      """#),
  Episode.Exercise(
    problem: #"""
      Update the higher-order `activityFeed` reducer to provide the current date from the reducer's environment.
      """#,
    solution: #"""
      You can describe the dependency of plucking a date out of the reducer's environment like so:

      ```swift
      func activityFeed(
        _ reducer: @escaping Reducer<AppState, AppAction, AppEnvironment>,
        date: @escaping (AppEnvironment) -> Date
      ) -> Reducer<AppState, AppAction, AppEnvironment>
      ```

      Which gets the date controlled and even lets you simply swap out `Date()` for `date(environment)`.

      ```swift
      state.activityFeed.append(.init(timestamp: date(environment), type: .removedFavoritePrime(state.count)))
      …
      state.activityFeed.append(.init(timestamp: date(environment), type: .addedFavoritePrime(state.count)))
      …
      state.activityFeed.append(.init(timestamp: date(environment), type: .removedFavoritePrime(state.favoritePrimes[index])))
      ```

      While it may seem scary to invoke this side effect without the cycle of running an `Effect` and feeding an action back into the system, it is perfectly safe and reasonable to do!

      Explore the alternative: what it would it look like to introduce the effect–action cycle in this higher-order reducer? What are the trade-offs of both approaches?
      """#),
]
