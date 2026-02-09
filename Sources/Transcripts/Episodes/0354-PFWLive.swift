import Foundation

extension Episode {
  public static let ep354_pfwLive = Episode(
    blurb: """
      We celebrate 8 years of Point-Free with a live stream! We take our brand new
      "[Point-Free Way](/the-way)" skill documents for a spin by building a Flashcards app powered \
      by [SQLiteData](http://github.com/pointfreeco/sqlite-data), and we give a sneak peek at \
      "Composable Architecture 2.0," a reimagining of our popular library.
      """,
    codeSampleDirectory: "0354-pfw-live",
    exercises: _exercises,
    id: 354,
    length: 1 * 60 * 60 + 51 * 60 + 11,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-02-09")!,
    references: [
      .thePointFreeWay,
      .sqliteData,
      .theComposableArchitecture
    ],
    sequence: 354,
    subtitle: "Live",
    title: "The Point-Free Way",
    trailerVideo: Video(
      bytesLength: 18_900_000,
      downloadUrls: .s3(
        hd1080: "0354-trailer-1080p-69276092ef3744499c593af43d69419b",
        hd720: "0354-trailer-1080p-69276092ef3744499c593af43d69419b",
        sd540: "0354-trailer-1080p-69276092ef3744499c593af43d69419b"
      ),
      id: "b348ef00df4d93a5f7575f63ba906a45"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
