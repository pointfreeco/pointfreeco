import Foundation

extension Episode {
  public static let ep144_tourOfIsowords = Episode(
    blurb: """
      It's time to take a look at the other half of the [isowords](https://www.isowords.xyz) code base: the server! We'll get you running the server locally, and then explore some benefits of developing client and server in Swift, such as simultaneously debugging both applications together, and sharing code.
      """,
    codeSampleDirectory: "0144-tour-of-isowords-pt3",
    exercises: _exercises,
    id: 144,
    length: 32 * 60 + 25,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_620_018_000),
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
    sequence: 144,
    subtitle: "Part 3",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 75_040_556,
      downloadUrls: .s3(
        hd1080: "0144-trailer-1080p-ae83079618d84e4baf5cbbeb0a2df306",
        hd720: "0144-trailer-720p-e9241f26e1734e96ac64e68406449a8a",
        sd540: "0144-trailer-540p-1f06a22a4a814b3b9ad5bae55f3f069d"
      ),
      vimeoId: 542_626_322
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 144)
  )
}

private let _exercises: [Episode.Exercise] = []

extension Episode.Video {
  public static let ep144_tourOfIsowords = Self(
    bytesLength: 363_938_131,
    downloadUrls: .s3(
      hd1080: "0144-1080p-234ed3c75ea24eb6bc9bf3e41cd8d21d",
      hd720: "0144-720p-f1f94c5ec60b43f8a6543f8d5b79f06e",
      sd540: "0144-540p-696e70ad0ba149db8d1b34bf8db6b90b"
    ),
    vimeoId: 542_626_967
  )
}
