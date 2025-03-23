import Foundation

extension Episode {
  public static let ep318_sqlBuilding = Episode(
    blurb: """
      We add sorting to our SQL builder, which will give us a powerful, succinct \
      syntax for controlling the order of results. We will start small but build up to \
      parameter packs and even a custom result builder to get the most flexibility out \
      of our API.
      """,
    codeSampleDirectory: "0318-sql-building-pt5",
    exercises: _exercises,
    id: 318,
    length: 28 * 60 + 44,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-03-24")!,
    references: [
      .init(
        blurb: "The SQLite home page",
        link: "https://www.sqlite.org",
        title: "SQLite"
      )
    ],
    sequence: 318,
    subtitle: "Order",
    title: "SQL Builders",
    trailerVideo: .init(
      bytesLength: 64_400_000,
      downloadUrls: .s3(
        hd1080: "0318-trailer-1080p-b67c62d0bace433e884d70a5b088e8ce",
        hd720: "0318-trailer-720p-e4b5a4942ac648029093f4bf4249480c",
        sd540: "0318-trailer-540p-630402991007444593ddd223c767a707"
      ),
      vimeoId: 1_065_709_374
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
