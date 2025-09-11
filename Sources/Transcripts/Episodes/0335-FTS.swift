import Foundation

extension Episode {
  public static let ep335_fts = Episode(
    blurb: """
      We now have a very basic search feature in place, but it can be improved. We will add some \
      bells and whistles and other performance improvements, including debouncing database \
      queries, adding a count query to display the number of completed reminders, and grouping \
      the queries into a single transaction.
      """,
    codeSampleDirectory: "0335-fts-pt2",
    exercises: _exercises,
    id: 335,
    length: 28 * 60 + 15,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2025-08-18")!,
    references: [
      Reference(
        blurb: "A fast, lightweight replacement for SwiftData, powered by SQL.",
        link: "https://github.com/pointfreeco/sqlite-data",
        title: "SQLiteData"
      ),
      Reference(
        blurb: "A library for building SQL in a safe, expressive, and composable manner.",
        link: "https://github.com/pointfreeco/swift-structured-queries",
        title: "StructuredQueries"
      ),
    ],
    sequence: 335,
    subtitle: "Finesse",
    title: "Modern Search",
    trailerVideo: Video(
      bytesLength: 20_800_000,
      downloadUrls: .s3(
        hd1080: "0335-trailer-1080p-f4775b1956764c339405edb86986bbe1",
        hd720: "0335-trailer-1080p-f4775b1956764c339405edb86986bbe1",
        sd540: "0335-trailer-1080p-f4775b1956764c339405edb86986bbe1"
      ),
      id: "f5273f5385ea742f0d93391ad3dd43aa"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
