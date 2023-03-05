import Foundation

extension Episode {
  static let ep41_aTourOfSnapshotTesting = Episode(
    blurb: """
      Our snapshot testing library is now officially open source! In order to show just how easy it is to integrate the library into any existing code base, we add some snapshot tests to a popular open source library for attributed strings. This gives us the chance to see how easy it is to write all new, domain-specific snapshot strategies from scratch.
      """,
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 450_728_966,
      downloadUrls: .s3(
        hd1080: "0041-1080p-fce154934e1a4a52abed19c697cd138a",
        hd720: "0041-720p-6dbcd6ae60bc44f99ac58abdea52a1c7",
        sd540: "0041-540p-6d5fb715c217488790614f791120336d"
      ),
      vimeoId: 349_952_472
    ),
    id: 41,
    length: 29 * 60 + 16,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_545_116_400),
    references: [
      .swiftSnapshotTesting,
      .bonMot,
      .protocolOrientedProgrammingWwdc,
      .iosSnapshotTestCaseGithub,
      .snapshotTestingBlogPost,
    ],
    sequence: 41,
    title: "A Tour of Snapshot Testing",
    trailerVideo: .init(
      bytesLength: 103_111_511,
      downloadUrls: .s3(
        hd1080: "0041-trailer-1080p-f729eb5cbf2f4ea08dbd794cf8c6475a",
        hd720: "0041-trailer-720p-ad7376d627f74d169cfc92c1c3bb6b54",
        sd540: "0041-trailer-540p-b32da555109f4eaba21e2a26c99f8cd5"
      ),
      vimeoId: 349_952_474
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 41)
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: """
      Write an `.html` strategy for snapshotting `NSAttributedString`. You will want to use the
      `data(from:documentAttributes:)` method on `NSAttributedString` with the
      `NSAttributedString.DocumentType.html` attribute to convert any attribtued string into an HTML document.
      """),
  .init(
    problem: """
      Integrate the [snapshot testing library](http://github.com/pointfreeco/swift-snapshot-testing) into one
      of your projects, and write a snapshot test.
      """),
  .init(
    problem: """
      Create a custom, domain-specific snapshot strategy for one of your types.
      """),
  .init(
    problem: """
      Send us a [pull request](http://github.com/pointfreeco/swift-snapshot-testing/pulls) to add a snapshot strategy for a Swift standard library or cocoa data type that
      we haven't yet implemented.
      """),
]
