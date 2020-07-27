import Foundation

extension Episode {
  public static let ep110_designingDependencies_pt1 = Episode(
    blurb: """
Let's take a moment to properly define what a dependency is and understand why they add so much complexity to our code. We will begin building a moderately complex application with three dependencies, and see how it complicates development, and what we can do about it.
""",
    codeSampleDirectory: "0110-designing-dependencies-pt1",
    exercises: _exercises,
    id: 110,
    image: "https://i.vimeocdn.com/video/930420428.jpg",
    length: 34*60 + 41,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1595826000),
    references: [
      reference(
        forEpisode: .ep16_dependencyInjectionMadeEasy,
        additionalBlurb: #"""
Our first episode on dependencies, where we show that they can be wrangled quite quickly and effectively by introducing a global, mutable instance of a struct.
"""#,
        episodeUrl: "https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy"
      ),
      reference(
        forEpisode: .ep18_dependencyInjectionMadeComfortable,
        additionalBlurb: #"""

"""#,
        episodeUrl: "https://www.pointfree.co/episodes/ep18-dependency-injection-made-comfortable"
      ),
      .composableArchitectureDependencyManagement,
      .howToControlTheWorld,
      reference(
        forEpisode: .ep2_sideEffects,
        additionalBlurb: #"""
In our first episode on side effects we first show that side effects that depend on the outside world can be controlled by passing the dependency as input.
"""#,
        episodeUrl: "https://www.pointfree.co/episodes/ep2-side-effects"
      ),
      .protocolOrientedProgrammingWwdc,
      .protocolOrientedProgrammingIsNotASilverBullet,
    ],
    sequence: 110,
    subtitle: "The Problem",
    title: "Designing Dependencies",
    trailerVideo: .init(
      bytesLength: 147643514,
      vimeoId: 441577251,
      vimeoSecret: "6c11a1a4ea0a97093458010944d54c0d49550b66"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
Our application currently has no error handling around API requests. Update the view model and view to show an alert when a weather request fails. Use the failed weather mock to verify that things look as they should.
"""#
  ),
  .init(
    problem: #"""
When we added a delay to the happy path weather mock we found the user experience to be lacking. Update the view model and view to render a loading indicator when the weather request is in flight. Use the delayed happy path weather mock to verify that things look as they should.
"""#
  ),
]
