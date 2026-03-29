import Foundation

extension Episode {
  public static let ep360_isolation = Episode(
    blurb: """
      We explore the most modern locking primitive in Swift: `Mutex`. It has some serious smarts \
      when it comes to protecting nonsendable state across threads in a synchronous manner, but it \
      also has a serious bug that you should be aware of.
      """,
    codeSampleDirectory: "0360-beyond-basics-isolation-pt6",
    exercises: _exercises,
    id: 360,
    length: 24 * 60 + 16,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-03-30")!,
    references: [
      Episode.Reference(
        blurb: "A synchronization primitive that protects shared mutable state via mutual exclusion.",
        link: "https://developer.apple.com/documentation/synchronization/mutex",
        title: "Mutex"
      ),
      .se0306_actors,
    ],
    sequence: 360,
    subtitle: "Mutex",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 35_500_000,
      downloadUrls: .s3(
        hd1080: "0360-trailer-1080p-2a927185c3fe4d9f9bcab86704a7ac45",
        hd720: "0360-trailer-1080p-2a927185c3fe4d9f9bcab86704a7ac45",
        sd540: "0360-trailer-1080p-2a927185c3fe4d9f9bcab86704a7ac45"
      ),
      id: "3ce990e6836594e38efc8d24eda9f322"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
