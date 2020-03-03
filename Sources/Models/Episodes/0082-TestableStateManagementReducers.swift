import Foundation

extension Episode {
  static let ep82_testableStateManagement_reducers = Episode(
    blurb: """
It's time to see how our architecture handles the fifth and final problem we identified as being important to solve when building a moderately complex application: testing! Let's get our feet wet and write some tests for all of the reducers powering our application.
""",
    codeSampleDirectory: "0082-testable-state-management-reducers",
    exercises: _exercises,
    id: 82,
    image: "https://i.vimeocdn.com/video/831975803.jpg",
    length: 35*60 + 56,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 79,
    publishedAt: Date(timeIntervalSince1970: 1574661600),
    references: [
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 82,
    title: "Testable State Management: Reducers",
    trailerVideo: .init(
      bytesLength: 55954991,
      downloadUrl: "https://player.vimeo.com/external/373001794.hd.mp4?s=d86bf515e2c83d4f62e6eabfae46909e1bec0431&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/373001794"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Control the save and load effects in the favorite primes module by introducing an "Environment" for dependency injection, as covered in [our episode on dependency injection](/episodes/ep16-dependency-injection-made-easy).
"""#
  ),
  Episode.Exercise(
    problem: #"""
Control the save effect inside `testSaveButtonTapped` to assert that when the reducer is called, it returns the expected effect.

Making such an assertion involves introducing local, mutable state to the test that is changed in a predictable way if the controlled effect runs. For example, you could introduce a boolean that flips from `false` to `true` when the effect runs. Then, after you run the effect returned from the reducer (you can use its `sink` method), you can assert that it changed as expected.
"""#
  ),
  Episode.Exercise(
    problem: #"""
Further assert that the save effect:

  - Completes. You can use the overload of `sink` that provides a `receivedCompletion` handler to hook into this event. Use the `expectation` and `wait` methods on the test case to handle this asynchrony.

  - Does not return an action to be fed back into the store. You can introduce an assertion to the `receivedValue` block that fails if it runs.
"""#
  ),
  Episode.Exercise(
    problem: #"""
Control the load effect inside `testLoadButtonTapped` to assert that when the reducer is called, it returns the expected effect.

Assert the load effect completes, as well.

Further, rather than manually feeding the expected `loadedFavoritePrimes` action back into the reducer, extract and feed the action returned by the load test effect instead. Again, use the `expectation` and `wait` methods to handle this asynchrony.
"""#
  ),
  Episode.Exercise(
    problem: #"""
Continuing the previous exercises, control the nth prime API effect in the counter module such that you can test:

  - That the effect completes
  - That the effect feeds the correct action back into the reducer
"""#
  ),
]
