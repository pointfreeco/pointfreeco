import Foundation

extension Episode {
  public static let ep250_macroTesting = Episode(
    blurb: """
      Macros are here! To celebrate, we are releasing a brand new tool to aid in writing tests for them. First, let's explore testing macros using the tools that Apple provides, evaluate their shortcomings, and see how we can address them.
      """,
    codeSampleDirectory: "0250-macro-testing-pt1",
    exercises: _exercises,
    id: 250,
    length: .init(.timestamp(minutes: 46, seconds: 5)),
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2023-09-18")!,
    references: [
      .macroAdoptionConcerns
    ],
    sequence: 250,
    subtitle: "Part 1",
    title: "Testing & Debugging Macros",
    trailerVideo: .init(
      bytesLength: 76_100_000,
      downloadUrls: .s3(
        hd1080: "0250-trailer-1080p-d298971121764a799e07adace7d496b5",
        hd720: "0250-trailer-720p-38899ea271d9451586f0209e1a59cf21",
        sd540: "0250-trailer-540p-27f25a32c5f04dd6bb962e02a3d9a7d0"
      ),
      vimeoId: 861_810_262
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
