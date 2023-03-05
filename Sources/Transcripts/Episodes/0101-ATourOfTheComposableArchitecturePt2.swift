import Foundation

extension Episode {
  public static let ep101_ATourOfTheComposableArchitecture_pt2 = Episode(
    blurb: """
      Continuing the tour of our recently open-sourced library, the Composable Architecture, we start to employ some of the more advanced tools that come with the library. Right now our business logic and view is riddled with needless array index juggling, and a special higher-order reducer can clean it all up for us.
      """,
    codeSampleDirectory: "0101-swift-composable-architecture-tour-pt2",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 280_081_521,
      downloadUrls: .s3(
        hd1080: "0101-1080p-6d2c16fe57ef4cc78dd92e45cae0b9d8",
        hd720: "0101-720p-f0d2e542c34640c1aab8c17c61da5194",
        sd540: "0101-540p-927f38898e1c4945ad38fc9c8665d816"
      ),
      vimeoId: 416_342_062
    ),
    id: 101,
    length: 28 * 60 + 21,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_589_173_200),
    references: [
      .theComposableArchitecture,
      .elmHomepage,
      .reduxHomepage,
    ],
    sequence: 101,
    subtitle: "Part 2",
    title: "A Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 30_074_314,
      downloadUrls: .s3(
        hd1080: "0101-trailer-1080p-d82f5133ade94edaa24988c20a7f11ef",
        hd720: "0101-trailer-720p-2b95d5b4ae9d44bbbf3a02d24a3a5bd9",
        sd540: "0101-trailer-540p-766632262ab642f1b75990af2d08c4bc"
      ),
      vimeoId: 416_533_021
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 101)
  )
}

private let _exercises: [Episode.Exercise] = []
