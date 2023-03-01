import Foundation

extension Episode {
  public static let ep143_tourOfIsowords = Episode(
    blurb: """
      Let's dive deeper into the [isowords](https://www.isowords.xyz) code base. We'll explore how the Composable Architecture and modularization unlocked many things, including the ability to add an onboarding experience without any changes to feature code, an App Clip, and even App Store assets.
      """,
    codeSampleDirectory: "0143-tour-of-isowords-pt2",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 669_144_331,
      downloadUrls: .s3(
        hd1080: "0143-1080p-7a9c136fc3414f62a08a3188ba698c9e",
        hd720: "0143-720p-65fd415292954c0bbd695c97afe539dd",
        sd540: "0143-540p-8cd7e65c26bd4ad0b56de7de3cd5e8db"
      ),
      vimeoId: 538_473_576
    ),
    id: 143,
    length: 57 * 60 + 1,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_619_413_200),
    references: [
      .isowords,
      .isowordsGitHub,
      .theComposableArchitecture,
      reference(
        forCollection: .composableArchitecture,
        additionalBlurb: "",
        collectionUrl: "https://www.pointfree.co/collections/composable-architecture"
      ),
    ],
    sequence: 143,
    subtitle: "Part 2",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 75_022_146,
      downloadUrls: .s3(
        hd1080: "0143-trailer-1080p-6291679ac8c3483fb0c4721bee70a305",
        hd720: "0143-trailer-720p-ec8c4971b8474292bd3e4ed6e193f360",
        sd540: "0143-trailer-540p-db30504eeba148a5b78d757504b89be5"
      ),
      vimeoId: 538_473_438
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 143)
  )
}

private let _exercises: [Episode.Exercise] = []
