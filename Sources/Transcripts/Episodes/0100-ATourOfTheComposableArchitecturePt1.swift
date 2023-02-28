import Foundation

extension Episode {
  public static let ep100_ATourOfTheComposableArchitecture_pt1 = Episode(
    blurb: """
      It's our 100th episode 🎉! To celebrate, we are finally releasing the Composable Architecture as an open source library, which means you can start using it in your applications today! Let's take a tour of the library, see how it's changed from what we built in earlier episodes, and build a brand new app with it.
      """,
    codeSampleDirectory: "0100-swift-composable-architecture-tour-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 402_161_784,
      downloadUrls: .s3(
        hd1080: "0100-1080p-9f9760f74ed241c5bed4d2c7a98aa659",
        hd720: "0100-720p-7a16243734704834a71b3eb4ed6e8a5c",
        sd540: "0100-540p-5892dbe7aac34472bd5a836d140be4f2"
      ),
      vimeoId: 414_016_119
    ),
    id: 100,
    length: 32 * 60 + 56,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_588_568_400),
    references: [
      .theComposableArchitecture,
      .elmHomepage,
      .reduxHomepage,
    ],
    sequence: 100,
    subtitle: "Part 1",
    title: "A Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 402_161_784,
      downloadUrls: .s3(
        hd1080: "0100-trailer-1080p-8fc9079664e4421984ff5cb70a45bc53",
        hd720: "0100-trailer-720p-862114bb4a56443cab85ff3eb1e038f7",
        sd540: "0100-trailer-540p-2eae6f8c217f4b2f876b0b02e8ee4dcb"
      ),
      vimeoId: 414_015_638
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 100)
  )
}

private let _exercises: [Episode.Exercise] = []
