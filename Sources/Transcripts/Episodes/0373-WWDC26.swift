import Foundation

extension Episode {
  public static let ep373_wwdc26 = Episode(
    blurb: """
      We compare all the new things SwiftData has to offer to SQLiteData, starting with a domain \
      modeling exercise. We will rewrite the Trips `@Model` classes into simple `@Table` structs, \
      and we will explore how the `Draft` type can power a single form for both creating and \
      updating trips.
      """,
    codeSampleDirectory: "0373-wwdc26-pt4",
    exercises: _exercises,
    id: 373,
    length: 42 * 60 + 45,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-07-20")!,
    references: [
      .sqliteData,
    ],
    sequence: 373,
    socialImage: nil,
    subtitle: "SQLiteData Domain Modeling",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 49_900_000,
      downloadUrls: .s3(
        hd1080: "0373-trailer-1080p-5ddac57f71314b9787f8e8df6cfc976f",
        hd720: "0373-trailer-1080p-5ddac57f71314b9787f8e8df6cfc976f",
        sd540: "0373-trailer-1080p-5ddac57f71314b9787f8e8df6cfc976f"
      ),
      id: "a35bffe690629579fb936e0ed9406ca8"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
