import Foundation

extension Episode {
  static let ep47_predictableRandomness_pt1 = Episode(
    blurb: """
Let's set out to make the untestable testable. This week we make composable randomness compatible with Swift's new APIs and explore various ways of controlling those APIs, both locally and globally.
""",
    codeSampleDirectory: "0047-predictable-randomness-pt1",
    id: 47,
    image: "https://i.vimeocdn.com/video/801299773.jpg",
    length: 32*60 + 05,
    permission: .subscriberOnly,
    previousEpisodeInCollection: 32,
    publishedAt: .init(timeIntervalSince1970: 1550473200),
    references: [
      .randomUnification,
      reference(
        forEpisode: .ep30_composableRandomness,
        additionalBlurb: """
The `Gen` type made its first appearance in this episode bridging function composition with randomness.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep30-composable-randomness"
      ),
      reference(
        forEpisode: .ep16_dependencyInjectionMadeEasy,
        additionalBlurb: """
We first introduced the `Environment` concept for controlling dependencies in this episode.
""",
        episodeUrl: "https://www.pointfree.co/episodes/ep16-dependency-injection-made-easy"
      ),
      .allowErrorToConformToItself,
      .aLittleRespectForAnySequence,
      .typeErasureInSwift
    ],
    sequence: 47,
    title: "Predictable Randomness: Part 1",
    trailerVideo: .init(
      bytesLength: 46323465,
      downloadUrl: "https://player.vimeo.com/external/349952487.hd.mp4?s=64c5c41c6d641feb92e4656302439248a9d1df58&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/349952487"
    )
  )
}
