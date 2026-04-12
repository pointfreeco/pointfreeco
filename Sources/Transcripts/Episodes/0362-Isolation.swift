import Foundation

extension Episode {
  public static let ep362_isolation = Episode(
    blurb: """
      Using an actor seems to have forced us from a synchronous context to an asynchronous one, \
      but it doesn't have to be this way. We will show how with the proper tools we can squash \
      many `await`s down to a single one, and we will use "serial executors" to better understand \
      how an actor enqueues work behind the scenes.
      """,
    codeSampleDirectory: "0362-beyond-basics-isolation-pt8",
    exercises: _exercises,
    id: 362,
    length: 30 * 60 + 19,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-04-13")!,
    references: [
      Episode.Reference(
        blurb: "Common protocol to which all actors conform.",
        link: "https://developer.apple.com/documentation/swift/actor",
        title: "Actor"
      ),
      .se0306_actors,
    ],
    sequence: 362,
    subtitle: "Actor Enqueuing",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 35_500_000,
      downloadUrls: .s3(
        hd1080: "0362-trailer-1080p-a61af30a1ddf467c9185d9025344a318",
        hd720: "0362-trailer-1080p-a61af30a1ddf467c9185d9025344a318",
        sd540: "0362-trailer-1080p-a61af30a1ddf467c9185d9025344a318"
      ),
      id: "ad98d0b465be8fbeb44ea27b64cac9a5"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
