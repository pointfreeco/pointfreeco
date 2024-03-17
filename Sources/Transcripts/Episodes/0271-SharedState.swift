import Foundation

extension Episode {
  public static let ep271_sharedState = Episode(
    blurb: """
      The `@Shared` property wrapper can effortlessly share state among features to build complex
      flows quickly, but because it is powered by a reference type, it is not compatible with the
      Composable Architecture's value-oriented testing tools. Let's address these shortcomings and
      recover all of the library's testing niceties.
      """,
    codeSampleDirectory: "0271-shared-state-pt4",
    exercises: _exercises,
    id: 271,
    length: 31 * 60 + 38,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-03-18")!,
    references: [
      // TODO
    ],
    sequence: 271,
    subtitle: "Testing, Part 1",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 43_900_000,
      downloadUrls: .s3(
        hd1080: "0271-trailer-1080p-7afe5bffb53c4f58ad5ecd9451512730",
        hd720: "0271-trailer-720p-696932f9b83f4f74a152151336379823",
        sd540: "0271-trailer-540p-722ab665089046a39b4c8e2a6d10a527"
      ),
      vimeoId: 922_689_985
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
