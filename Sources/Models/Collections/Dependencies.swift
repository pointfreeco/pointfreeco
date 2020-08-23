extension Episode.Collection {
  public static let dependencies = Self(
    section: Section.init(
      blurb: #"""
Dependencies can wreak havoc on a codebase. They increase compile times, they are difficult to test, and they put strain on build tools. Did you know that Core Location, Core Motion and Store Kit all do not work in Xcode previews? Any feature touching those frameworks will not benefit from the awesome feedback cycle that previews afford us. This collection properly defines dependencies and shows how to take back control to unleash some amazing benefits.
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
      title: "Dependencies",
      whereToGoFromHere: nil
    )
  )
}
