import Foundation

extension Episode {
  public static let ep177_parserErrors = Episode(
    blurb: """
      Let's make errors a pleasure to encounter! We will make them easy to read, add more context to make them easy to debug, and even see how error messages can influence existing APIs.
      """,
    codeSampleDirectory: "0177-parser-errors-pt2",
    exercises: _exercises,
    id: 177,
    length: 43 * 60 + 47,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_644_213_600),
    references: [
      // TODO
    ],
    sequence: 177,
    subtitle: "Context and Ergonomics",
    title: "Parser Errors",
    trailerVideo: .init(
      bytesLength: 10_492_149,
      downloadUrls: .s3(
        hd1080: "0177-trailer-1080p-7ebecc2a993840d1857d6810b196d04e",
        hd720: "0177-trailer-720p-ce12d613e6cf47fe9d36f4ef56d9d791",
        sd540: "0177-trailer-540p-b166e6b30e38482e9d6d338de67bba74"
      ),
      vimeoId: 671_512_858
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
