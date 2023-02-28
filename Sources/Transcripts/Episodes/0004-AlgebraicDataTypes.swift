import Foundation

extension Episode {
  static let ep4_algebraicDataTypes = Episode(
    blurb: """
      What does the Swift type system have to do with algebra? A lot! We’ll begin to explore this correspondence \
      and see how it can help us create type-safe data structures that can catch runtime errors at compile time.
      """,
    codeSampleDirectory: "0004-algebraic-data-types",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 194_777_227,
      downloadUrls: .s3(
        hd1080: "0004-1080p-9dab8002b3c54758b4856a521086e114",
        hd720: "0004-720p-062b964b22b44488bbbd4683988548c3",
        sd540: "0004-540p-0122829a2ac048b3a71b41b91fcdf439"
      ),
      vimeoId: 355_115_428
    ),
    id: 4,
    length: 2_172,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_519_045_951),
    references: [
      .makingIllegalStatesUnrepresentable
    ],
    sequence: 4,
    title: "Algebraic Data Types",
    trailerVideo: .init(
      bytesLength: 37_267_895,
      downloadUrls: .s3(
        hd1080: "0004-trailer-1080p-2a68a514275a4cfc85d5246c397fadca",
        hd720: "0004-trailer-720p-71e8e6fc666d45c4b00951550819244a",
        sd540: "0004-trailer-540p-d07c80f547fe401e96a1dd0282e1feb5"
      ),
      vimeoId: 354_215_001
    ),
    transcriptBlocks: loadTranscriptBlocks(forSequence: 4)
  )
}
