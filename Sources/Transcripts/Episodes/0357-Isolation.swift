import Foundation

extension Episode {
  public static let ep357_isolation = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0357-beyond-basics-isolation-pt3",
    exercises: _exercises,
    id: 357,
    length: 17 * 60 + 57,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-03-09")!,
    references: [
      // TODO
    ],
    sequence: 357,
    subtitle: "What Is It?",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 86_900_000,
      downloadUrls: .s3(
        hd1080: "0357-trailer-1080p-ab683f897a8749fc8683bd8433b457b2",
        hd720: "0357-trailer-1080p-ab683f897a8749fc8683bd8433b457b2",
        sd540: "0357-trailer-1080p-ab683f897a8749fc8683bd8433b457b2"
      ),
      id: "aa3957bb7f713db21d1ccaa1ff80516f"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
