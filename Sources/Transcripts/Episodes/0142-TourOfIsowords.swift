import Foundation

extension Episode {
  public static let ep142_tourOfIsowords = Episode(
    blurb: """
      In past episodes we took a peek behind the curtains of our recently released iOS game, [isowords](https://www.isowords.xyz). Now it's time to dive deep into the code base to see how it's built. We'll start by showing our modern approach to project management using SPM and explore how the Composable Architecture powers the entire application.
      """,
    codeSampleDirectory: "0142-tour-of-isowords-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 347_814_830,
      downloadUrls: .s3(
        hd1080: "0142-1080p-463a0db5953a4a3ba0d40fac423ee7f6",
        hd720: "0142-720p-455fafa5ab7e43da9231735bb079b560",
        sd540: "0142-540p-7fa3f1d7303143b28dcba9e57be6a4de"
      ),
      vimeoId: 537_523_068
    ),
    id: 142,
    length: 37 * 60 + 18,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_618_808_400),
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
    sequence: 142,
    subtitle: "Part 1",
    title: "A Tour of isowords",
    trailerVideo: .init(
      bytesLength: 33_101_299,
      downloadUrls: .s3(
        hd1080: "0142-trailer-1080p-46448901609e41f6a12e3889cd6e73ed",
        hd720: "0142-trailer-720p-ee260c7810714d14bcda26483109b593",
        sd540: "0142-trailer-540p-578901e8d87241adb89c383a192a77ce"
      ),
      vimeoId: 537_523_006
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 142)
  )
}

private let _exercises: [Episode.Exercise] = []
