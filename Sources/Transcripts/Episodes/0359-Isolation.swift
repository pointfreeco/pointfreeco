import Foundation

extension Episode {
  public static let ep359_isolation = Episode(
    blurb: """
      It turns out that isolating state with an `NSLock` is not as straightforward as it seems, \
      and we _still_ have a subtle data race. But Apple actually provides a more modern tool that \
      _does_ help prevent this data race at compile time. Let's take it for a spin and get an \
      understanding of how it works.
      """,
    codeSampleDirectory: "0359-beyond-basics-isolation-pt5",
    exercises: _exercises,
    id: 359,
    length: 24 * 60 + 16,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-03-23")!,
    references: [
      Episode.Reference(
        blurb: "A structure that creates an unfair lock.",
        link: "https://developer.apple.com/documentation/os/osallocatedunfairlock",
        title: "OSAllocatedUnfairLock"
      ),
      .se0306_actors,
    ],
    sequence: 359,
    subtitle: "OSAllocatedUnfairLock",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 28_400_000,
      downloadUrls: .s3(
        hd1080: "0359-trailer-1080p-1d8acfc6033c4c0da560442ed41b67d5",
        hd720: "0359-trailer-1080p-1d8acfc6033c4c0da560442ed41b67d5",
        sd540: "0359-trailer-1080p-1d8acfc6033c4c0da560442ed41b67d5"
      ),
      id: "8bf219b2c5a562fcfe0f52a7ae19b1b5"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
