import Foundation

extension Episode {
  public static let ep145_tourOfIsowords = Episode(
    blurb: """
      We wrap up our tour of [isowords](https://www.isowords.xyz) by showing off two powerful ways the iOS client and Swift server share code. Not only does the same code that routes server requests simultaneously power the API client, but we can write integration tests that exercise the full client–server lifecycle.
      """,
    codeSampleDirectory: "0145-tour-of-isowords-pt4",
    exercises: _exercises,
    id: 145,
    length: 53 * 60 + 54,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_620_622_800),
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
    sequence: 145,
    subtitle: "Part 4",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 40_625_547,
      downloadUrls: .s3(
        hd1080: "0145-trailer-1080p-cf004995a5b04563a0ccbae0713a472f",
        hd720: "0145-trailer-720p-da31af47334a4a1595c62e5d541cbc8e",
        sd540: "0145-trailer-540p-02a3f8d270584369884da76d13804009"
      ),
      vimeoId: 542_946_808
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 145)
  )
}

private let _exercises: [Episode.Exercise] = []

extension Episode.Video {
  public static let ep145_tourOfIsowords = Self(
    bytesLength: 518_632_255,
    downloadUrls: .s3(
      hd1080: "0145-1080p-ba2a4d4954eb46deacba5d3a8a028a20",
      hd720: "0145-720p-4e479ad219ec4590ae6412d6d4b2c416",
      sd540: "0145-540p-d87d7c86be1042e4a021045d96aa961f"
    ),
    vimeoId: 543_413_218
  )
}
