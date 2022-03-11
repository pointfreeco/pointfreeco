import Foundation

extension Episode {
  static let ep47_predictableRandomness_pt1 = Episode(
    blurb: """
Let's set out to make the untestable testable. This week we make composable randomness compatible with Swift's new APIs and explore various ways of controlling those APIs, both locally and globally.
""",
    codeSampleDirectory: "0047-predictable-randomness-pt1",
    id: 47,
    length: 32*60 + 05,
    permission: .subscriberOnly,
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
      downloadUrls: .s3(
        hd1080: "0047-trailer-1080p-a72a05447a24416487e93b2dbdd75392",
        hd720: "0047-trailer-720p-ef1f5e8e1456421da8cdd75586172aa2",
        sd540: "0047-trailer-540p-2c1ec8bb0f9d4f20a2c3cec40d128888"
      ),
      vimeoId: 349952487
    )
  )
}
