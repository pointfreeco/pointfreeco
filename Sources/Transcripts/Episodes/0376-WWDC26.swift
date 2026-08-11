import Foundation

extension Episode {
  public static let ep376_wwdc26 = Episode(
    blurb: """
      We add a geofence to the `Trip` model and explore advanced features of SQLite, including \
      JSONB and `json_each`, which allow us to efficiently store and query this data. And we will \
      show that not all bundles of data need to be JSON: we are free to group our database columns \
      among as many data types as we like.
      """,
    codeSampleDirectory: "0376-wwdc26-pt7",
    exercises: _exercises,
    id: 376,
    length: 28 * 60 + 16,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-10")!,
    references: [
      .sqliteData,
    ],
    sequence: 376,
    socialImage: nil,
    subtitle: "SQLiteData Advanced Domain Modeling",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 45_100_000,
      downloadUrls: .s3(
        hd1080: "0376-trailer-1080p-1b4b3c50255a4c47b6aa0bd439af60e4",
        hd720: "0376-trailer-1080p-1b4b3c50255a4c47b6aa0bd439af60e4",
        sd540: "0376-trailer-1080p-1b4b3c50255a4c47b6aa0bd439af60e4"
      ),
      id: "2393d53ad443b994c4d24d9a63998d85"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
