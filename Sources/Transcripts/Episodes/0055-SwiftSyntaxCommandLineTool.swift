import Foundation

extension Episode {
  static let ep55_swiftSyntaxCommandLineTool = Episode(
    blurb: """
      Today we finally extract our enum property code generator to a Swift Package Manager library and CLI tool. We'll also do some next-level snapshot testing: not only will we snapshot-test our generated code, but we'll leverage the Swift compiler to verify that our snapshot builds.
      """,
    codeSampleDirectory: "0055-swift-syntax-command-line-tool",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 456_133_747,
      downloadUrls: .s3(
        hd1080: "0055-1080p-eb83145fe79b4252858bb7a3ffa9bca7",
        hd720: "0055-720p-e4926b1e3a0e449ab081865a10cb2525",
        sd540: "0055-540p-1665a04143f4476e90f7e80098846203"
      ),
      vimeoId: 349_952_509
    ),
    id: 55,
    length: 35 * 60 + 16,
    permission: .free,
    publishedAt: .init(timeIntervalSince1970: 1_555_912_800),
    references: [],
    sequence: 55,
    title: "Swift Syntax Command Line Tool",
    trailerVideo: .init(
      bytesLength: 35_807_367,
      downloadUrls: .s3(
        hd1080: "0055-trailer-1080p-f52f86f4469948b3abf3f9a387ffa8ae",
        hd720: "0055-trailer-720p-e6cb236900ed423682c168cacf3be80d",
        sd540: "0055-trailer-540p-c350721e67a342088fc72cc305411442"
      ),
      vimeoId: 349_952_508
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 55)
  )
}

private let _exercises: [Episode.Exercise] = []
