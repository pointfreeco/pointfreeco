extension Episode.Collection {
  public static let dependencies = Self(
    blurb: #"""
Dependencies can wreak havoc on a codebase. They increase compile times, are difficult to test, and put strain on build tools. Did you know that Core Location, Core Motion, Store Kit, and many other frameworks do not work in Xcode previews? Any feature touching these frameworks will not benefit from the awesome feedback cycle that previews afford us. This collection clearly defines dependencies and shows how to take back control in order to unleash some amazing benefits.
"""#,
    sections: [
      .init(
        blurb: #"""
We build a moderately complex application that has three external dependencies: network requests, network availability and location services. This gives us the perfect opportunity to concisely describe what a dependency is, how it makes our code more complex, and what we can do about it.
"""#,
        coreLessons: [
          .init(episode: .ep110_designingDependencies_pt1),
          .init(episode: .ep111_designingDependencies_pt2),
          .init(episode: .ep112_designingDependencies_pt3),
          .init(episode: .ep113_designingDependencies_pt4),
          .init(episode: .ep114_designingDependencies_pt5),
        ],
        related: [
          .init(
            blurb: #"""
The technique of replacing protocols with simple data types goes far deeper than what we discuss above. Almost any protocol can be rewritten as a simple data type, and when you do so you can uncover a lot of interesting forms of composition that were previously hidden from us in the protocol world. To learn more watch our series of episodes on the "protocol witness" technique.
"""#,
            content: .collection(.protocolWitnesses)
          ),

          .init(
            blurb: #"""
Well-designed dependencies and the [Composable Architecture](/collections/composable-architecture) go hand-in-hand. If your dependencies are properly designed, then you will instantly unlock deep testing abilities of your application, including the ability to exhaustively assert the lifecycle of effects. To learn more watch our series of episodes on dependency management in the Composable Architecture.
"""#,
            content: .section(.composableArchitecture, index: 5)
          ),

          .init(
            blurb: #"""
We first talked about dependencies long, long ago in one of our first episodes. In these episodes we introduced the concept of modeling dependencies with simple data types instead of using protocols.
"""#,
            content: .episodes(
              [
                .ep16_dependencyInjectionMadeEasy,
                .ep18_dependencyInjectionMadeComfortable
              ]
            )
          )
        ],
        title: "Designing Dependencies",
        whereToGoFromHere: #"""
There are tricks we can employ to better design our test dependencies so that we can exhaustively describe what dependencies a feature needs to do its job. This comes with tons of benefits for tests, but also strengthens our SwiftUI previews and can even be handy for production code.
"""#
      ),

      .init(
        blurb: #"""
Test dependencies are used in place of live dependencies so that we can control how the dependency behaves. This allows our tests to be fast and deterministic since they do not need to interact with the outside world. But, designing test dependencies can go well beyond these benefits. They can even allow us to exhaustively describe what dependencies a feature needs to do its job, and even improve our SwiftUI previews and production code.
"""#,
        coreLessons: [
          .init(episode: .ep138_betterTestDependencies),
          .init(episode: .ep139_betterTestDependencies),
          .init(episode: .ep140_betterTestDependencies),
          .init(episode: .ep141_betterTestDependencies),
        ],
        related: [
          .init(
            blurb: #"""
Well-designed dependencies and the [Composable Architecture](/collections/composable-architecture) go hand-in-hand. If your dependencies are properly designed, then you will instantly unlock deep testing abilities of your application, including the ability to exhaustively assert the lifecycle of effects. To learn more watch our series of episodes on dependency management in the Composable Architecture.
"""#,
            content: .section(.composableArchitecture, index: 5)
          ),

          .init(
            blurb: #"""
The technique of replacing protocols with simple data types goes far deeper than what we discuss above. Almost any protocol can be rewritten as a simple data type, and when you do so you can uncover a lot of interesting forms of composition that were previously hidden from us in the protocol world. To learn more watch our series of episodes on the "protocol witness" technique.
"""#,
            content: .collection(.protocolWitnesses)
          ),
        ],
        title: "Better Test Dependencies",
        whereToGoFromHere: nil
      )
    ],
    title: "Dependencies"
  )
}
