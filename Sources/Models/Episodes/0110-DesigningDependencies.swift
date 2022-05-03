import Foundation

extension Episode {
  public static let ep110_designingDependencies_pt1 = Episode(
    blurb: """
      Let's take a moment to properly define what a dependency is and understand why they add so much complexity to our code. We will begin building a moderately complex application with three dependencies, and see how it complicates development, and what we can do about it.
      """,
    codeSampleDirectory: "0110-designing-dependencies-pt1",
    exercises: _exercises,
    id: 110,
    length: 34 * 60 + 41,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_595_826_000),
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
      bytesLength: 147_643_514,
      downloadUrls: .s3(
        hd1080: "0110-trailer-1080p-f398798ffea149fca9c2d2e22be46d42",
        hd720: "0110-trailer-720p-c520580aa7ac4baaafda850b9ed2f166",
        sd540: "0110-trailer-540p-6da29f83ac1f480e94c4c44581ab8770"
      ),
      vimeoId: 441_577_251
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
