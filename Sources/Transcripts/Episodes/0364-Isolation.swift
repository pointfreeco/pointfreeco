import Foundation

extension Episode {
  public static let ep364_isolation = Episode(
    blurb: """
      We embark on a side quest to explore some of the community misinformation around actors and \
      performance. A common complaint is that actors are slower than locks, and thus another \
      reason to avoid them. Let's explore why these comparisons aren't quite what they seem, and \
      how actors can in fact be _more_ performant than mutexes and locks.
      """,
    codeSampleDirectory: "0364-beyond-basics-isolation-pt10",
    exercises: _exercises,
    id: 364,
    length: 33 * 60 + 14,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-04-27")!,
    references: [
      Episode.Reference(
        blurb: "Common protocol to which all actors conform.",
        link: "https://developer.apple.com/documentation/swift/actor",
        title: "Actor"
      ),
      .se0306_actors,
    ],
    sequence: 364,
    subtitle: "Performance",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 35_500_000,
      downloadUrls: .s3(
        hd1080: "0364-trailer-1080p-7202b604616849e0be4f9c4a6165f9ad",
        hd720: "0364-trailer-1080p-7202b604616849e0be4f9c4a6165f9ad",
        sd540: "0364-trailer-1080p-7202b604616849e0be4f9c4a6165f9ad"
      ),
      id: "5e713dececebbf14913b8a2fbbf7c718"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
