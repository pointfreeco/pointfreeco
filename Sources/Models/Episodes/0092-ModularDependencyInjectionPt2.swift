import Foundation

extension Episode {
  static let ep92_modularDependencyInjection_pt2 = Episode(
    blurb: """
Now that we've baked the "environment" of dependencies directly into the Composable Architecture, we're ready to refactor our app's frameworks and tests to work with them in a modular and more lightweight way.
""",
    codeSampleDirectory: "0092-modular-dependency-injection-pt2",
    exercises: _exercises,
    id: 92,
    image: "https://i.vimeocdn.com/video/858808009-76c226f83c6644f0ef081f31b1703d8d5bd875d3ba2a1d85b0a7fe0a8afe3c90-d",
    length: 34*60 + 23,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1582524000),
    references: [
      reference(
        forEpisode: .ep16_dependencyInjectionMadeEasy,
        additionalBlurb: #"This is the episode that first introduced our `Current` environment approach to dependency injection."#,
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
        additionalBlurb: #"This is the start of our series of episodes on "effectful" state management, in which we explore how to capture the idea of side effects directly in our composable architecture."#,
        episodeUrl: "https://www.pointfree.co/episodes/ep76-effectful-state-management-synchronous-effects"
      ),
      reference(
        forEpisode: .ep82_testableStateManagement_reducers,
        additionalBlurb: #"This is the start of our series of episodes on "testable" state management, in which we explore just how testable the Composable Architecture is, effects and all!"#,
        episodeUrl: "https://www.pointfree.co/episodes/ep82-testable-state-management-reducers"
      ),
    ],
    sequence: 92,
    title: "Dependency Injection Made Modular",
    trailerVideo: .init(
      bytesLength: 20_716_503,
      vimeoId: 393344940,
      vimeoSecret: "d2527e30f8a8d2e49c3186afbda972a7a075c86b"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: #"""
Introduce an "offline counter view," which reuses the `CounterView` with an offline version of the `nthPrimeModal`. Show that both views can exist in harmony in the environmental architecture.
"""#,
    solution: #"""
Stay tuned for a solution in next week’s episode!
"""#
  ),
  Episode.Exercise(
    problem: #"""
Update the favorite primes module to hit Wolfram Alpha and show an alert, just as the counter module does when the "What is the nth prime?" button is tapped.

Ensure that the root reducer shares the same dependency with each module.
"""#,
    solution: #"""
Stay tuned for a solution in next week’s episode!
"""#
  ),
]
