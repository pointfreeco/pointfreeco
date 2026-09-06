import Foundation

extension Episode {
  public static let ep372_wwdc26 = Episode(
    blurb: """
      We examine what's new in SwiftData through Apple's Trips sample code: this includes \
      sectioning, added `Codable` support, observing changes outside the view, and we also explore \
      a new feature from last year: inheritance. We dive deep into each topic to figure out what \
      exactly _is_ new, what are the gotchas, and prepare for another lesson on concisely modeled \
      domains.
      """,
    codeSampleDirectory: "0372-wwdc26-pt3",
    exercises: _exercises,
    id: 372,
    length: 54 * 60 + 23,
    permission: .free,
    publishedAt: yearMonthDayFormatter.date(from: "2026-07-13")!,
    references: [
      .wwdc26WhatsNewInSwiftData,
    ],
    sequence: 372,
    socialImage: nil,
    subtitle: "SwiftData",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 49_900_000,
      downloadUrls: .s3(
        hd1080: "0372-trailer-1080p-77f2b3768bff41f88b9f1470634da3e6",
        hd720: "0372-trailer-1080p-77f2b3768bff41f88b9f1470634da3e6",
        sd540: "0372-trailer-1080p-77f2b3768bff41f88b9f1470634da3e6"
      ),
      id: "d2618d2b8f8757101304bb2ea021d2fc"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
