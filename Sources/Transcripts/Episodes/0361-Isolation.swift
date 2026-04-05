import Foundation

extension Episode {
  public static let ep361_isolation = Episode(
    blurb: """
      After fighting with legacy locking and mutexes let's explore a modern alternative: actors. \
      We will refactor our data race-sensitive class to an actor and see just how simple and \
      flexible its implementation can be, and we will grapple with something it introduces that \
      locking did not: suspension points.
      """,
    codeSampleDirectory: "0361-beyond-basics-isolation-pt7",
    exercises: _exercises,
    id: 361,
    length: 21 * 60 + 38,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-04-06")!,
    references: [
      Episode.Reference(
        blurb: "Common protocol to which all actors conform.",
        link: "https://developer.apple.com/documentation/swift/actor",
        title: "Actor"
      ),
      .se0306_actors,
    ],
    sequence: 361,
    subtitle: "Actors",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 35_500_000,
      downloadUrls: .s3(
        hd1080: "0361-trailer-1080p-27f16db37a3643cc9bab647b9d87186f",
        hd720: "0361-trailer-1080p-27f16db37a3643cc9bab647b9d87186f",
        sd540: "0361-trailer-1080p-27f16db37a3643cc9bab647b9d87186f"
      ),
      id: "c29a5b04ee18fd1c70d3e5d221310c38"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
