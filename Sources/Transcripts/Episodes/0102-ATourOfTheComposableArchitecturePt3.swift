import Foundation

extension Episode {
  public static let ep102_ATourOfTheComposableArchitecture_pt3 = Episode(
    blurb: """
      It's time to start proving that our business logic works the way we expect. We are going to show how easy it is to write tests with the Composable Architecture, which will give us the confidence to add more functionality and explore some advanced effect capabilities of the library.
      """,
    codeSampleDirectory: "0102-swift-composable-architecture-tour-pt3",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 372_928_086,
      downloadUrls: .s3(
        hd1080: "0102-1080p-c2566eaa388e4152a7aab5a954be95db",
        hd720: "0102-720p-f16efbe95c074f0cb84cf6565b502992",
        sd540: "0102-540p-6275e285990e4d8dbf82f2751064f5c2"
      ),
      vimeoId: 416_344_329

    ),
    id: 102,
    length: 32 * 60 + 28,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_589_778_001),
    references: [
      .theComposableArchitecture,
      .elmHomepage,
      .reduxHomepage,
    ],
    sequence: 102,
    subtitle: "Part 3",
    title: "A Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 61_680_473,
      downloadUrls: .s3(
        hd1080: "0102-trailer-1080p-266a1f3d7f0c4ca5be392ea2b6dc2028",
        hd720: "0102-trailer-720p-8b1abf902b5f42149fdbc4e20a171fc5",
        sd540: "0102-trailer-540p-fa2519b574be461088e7ccd2c8a492df"
      ),
      vimeoId: 416_533_116
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 102)
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
