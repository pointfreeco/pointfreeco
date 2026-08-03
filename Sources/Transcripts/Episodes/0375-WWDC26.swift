import Foundation

extension Episode {
  public static let ep375_wwdc26 = Episode(
    blurb: """
      We explore how encoding data to JSON does not hinder our ability to query it from SQLite's \
      powerful tools. We can filter, sort, and even _section_ results by location data stored as \
      JSON in a table column, and all with type safe and schema safe guarantees at compile time.
      """,
    codeSampleDirectory: "0375-wwdc26-pt6",
    exercises: _exercises,
    id: 375,
    length: 41 * 60 + 22,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-08-03")!,
    references: [
      .sqliteData,
    ],
    sequence: 375,
    socialImage: nil,
    subtitle: "SQLiteData Codability",
    title: "WWDC26",
    trailerVideo: Video(
      bytesLength: 57_900_000,
      downloadUrls: .s3(
        hd1080: "0375-trailer-1080p-bb1280adc7b245ef81d9f257365484a1",
        hd720: "0375-trailer-1080p-bb1280adc7b245ef81d9f257365484a1",
        sd540: "0375-trailer-1080p-bb1280adc7b245ef81d9f257365484a1"
      ),
      id: "ea79b55b4f2116315ea6db146bd57442"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
