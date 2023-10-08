import Foundation

extension Episode {
  public static let ep253_observation = Episode(
    blurb: """
      The `@Observable` macro is here and we will see how it improves on nearly every aspect of the tools that originally shipped with SwiftUI. We will also take a peek behind the curtain to not only get comfortable with the code the macro expands to, but the actual open source code that powers the framework.
      """,
    codeSampleDirectory: "0253-observation-pt2",
    exercises: _exercises,
    id: 253,
    length: 52 * 60 + 37,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-10-16")!,
    references: [
      // TODO
    ],
    sequence: 253,
    subtitle: "The Present",
    title: "Observation",
    trailerVideo: .init(
      bytesLength: 86_300_000,
      downloadUrls: .s3(
        hd1080: "0253-trailer-1080p-80b92a7e95a947209088423b8bb8e8c7",
        hd720: "0253-trailer-720p-bda0d3649cd54bf69551c999465ab1a4",
        sd540: "0253-trailer-540p-566636a3e0bd4d26aedd7b185bc14003"
      ),
      vimeoId: 872_120_730
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
