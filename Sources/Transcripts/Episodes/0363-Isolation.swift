import Foundation

extension Episode {
  public static let ep363_isolation = Episode(
    blurb: """
      TODO
      """,
    codeSampleDirectory: "0363-beyond-basics-isolation-pt7",
    exercises: _exercises,
    id: 363,
    length: 25 * 60 + 11,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-04-20")!,
    references: [
      Episode.Reference(
        blurb: "Common protocol to which all actors conform.",
        link: "https://developer.apple.com/documentation/swift/actor",
        title: "Actor"
      ),
      .se0306_actors,
    ],
    sequence: 363,
    subtitle: "Synchronous Actors",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 35_500_000,
      downloadUrls: .s3(
        hd1080: "0363-trailer-1080p-67a29ddde82243b3b3be2cb849a21e67",
        hd720: "0363-trailer-1080p-67a29ddde82243b3b3be2cb849a21e67",
        sd540: "0363-trailer-1080p-67a29ddde82243b3b3be2cb849a21e67"
      ),
      id: "aa2fbbea13ca8965b1fbd3bee76c72e9"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
