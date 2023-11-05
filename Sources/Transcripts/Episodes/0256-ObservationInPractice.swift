import Foundation

extension Episode {
  public static let ep256_observationInPractice = Episode(
    blurb: """
      We take all we've learned about the Observation framework and apply it to a larger, more real
      world application: our rewrite of Apple's Scrumdinger demo. We'll see what changes are easy to
      make, what changes are a bit trickier, and encounter a bug that you'll want to know about.
      """,
    codeSampleDirectory: "0256-observation-in-practice",
    exercises: _exercises,
    id: 256,
    length: 61 * 60 + 9,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2023-11-06")!,
    references: [
      .modernSwiftUI(
        additionalBlurb: """
          The original series in which we build the application refactored in this episode.
          """
      ),
    ],
    sequence: 256,
    subtitle: nil,
    title: "Observation in Practice",
    trailerVideo: .init(
      bytesLength: 51_400_000,
      downloadUrls: .s3(
        hd1080: "0256-trailer-1080p-843aaf9e008c481fae6b3f5eb5c5a254",
        hd720: "0256-trailer-720p-fcceef6642e7416085178b96befcc3f1",
        sd540: "0256-trailer-540p-b34525b141174904880bf9543cb3bef4"
      ),
      vimeoId: 877_140_106
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
