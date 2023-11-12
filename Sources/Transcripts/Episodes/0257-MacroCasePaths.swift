import Foundation

extension Episode {
  public static let ep257_macroCasePaths = Episode(
    blurb: """
      “Case paths” grant key path-like functionality to enum cases. They solve many problems in
      navigation, parsing, and architecture, but fall short of native key paths…till now. Let’s
      close this gap using macros that generate actual key paths to enum cases.
      """,
    codeSampleDirectory: "0257-macro-case-paths-pt1",
    exercises: _exercises,
    id: 257,
    length: 59 * 60 + 1,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-11-13")!,
    references: [
      // TODO
    ],
    sequence: 257,
    subtitle: "Part 1",
    title: "Macro Case Paths",
    trailerVideo: .init(
      bytesLength: 111_100_000,
      downloadUrls: .s3(
        hd1080: "0257-trailer-1080p-c561afc25ea445a5802d9ad407e15891",
        hd720: "0257-trailer-720p-242bae1d902e47a89172bdf54a091c11",
        sd540: "0257-trailer-540p-45131bb0515f4635ae9fc47802f8a867"
      ),
      vimeoId: 877_277_849
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
