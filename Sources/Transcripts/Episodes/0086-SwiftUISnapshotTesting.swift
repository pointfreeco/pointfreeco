import Foundation

extension Episode {
  static let ep86_swiftUiSnapshotTesting = Episode(
    blurb: """
      In this week's free holiday episode we show what it looks like to snapshot test a SwiftUI application in our architecture and compare this style of integration testing against XCTest's UI testing tools.
      """,
    codeSampleDirectory: "0086-swiftui-snapshot-testing",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 367_021_495,
      downloadUrls: .s3(
        hd1080: "0086-1080p-b54dfa8910ae4e8c9c442e98f5b60a04",
        hd720: "0086-720p-a468c30cc8864285b508e66903b315fa",
        sd540: "0086-540p-804a6f42bd3347d692700e284e4bfff3"
      ),
      vimeoId: 379_179_506
    ),
    id: 86,
    length: 34 * 60 + 13,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_577_080_800),
    references: [
      .testingAndDeclarativeUIs,
      .swiftSnapshotTesting,
      .snapshotTestingBlogPost,
      .elmHomepage,
      .reduxHomepage,
      .composableReducers,
    ],
    sequence: 86,
    title: "SwiftUI Snapshot Testing",
    trailerVideo: .init(
      bytesLength: 14_178_936,
      downloadUrls: .s3(
        hd1080: "0086-trailer-1080p-a1ec08a4c8f44960a10864893fb7f2fe",
        hd720: "0086-trailer-720p-bb7d2c7ceada4783bb54ea4b7bb2676b",
        sd540: "0086-trailer-540p-07bdbf00a23c4dcda120b009f05cf737"
      ),
      vimeoId: 379_179_491
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 86)
  )
}

private let _exercises: [Episode.Exercise] = []
