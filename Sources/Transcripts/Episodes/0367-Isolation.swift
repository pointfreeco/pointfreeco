import Foundation

extension Episode {
  public static let ep367_isolation = Episode(
    blurb: """
      The `sending` parameter is a powerful concurrency tool new to Swift 6 that allows you to
      precisely specify how non-sendable values can cross isolation boundaries. We will explore how
      it works in terms of "region-based isolation," and how we can send values into and out of
      functions as "disconnected" objects that are free to travel across isolation boundaries.
      """,
    codeSampleDirectory: "0367-beyond-basics-isolation-pt13",
    exercises: _exercises,
    id: 367,
    length: 24 * 60 + 6,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-05-25")!,
    references: [
      .se0430_sending,
    ],
    sequence: 367,
    socialImage: nil,
    subtitle: "Sending Values",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 43_300_000,
      downloadUrls: .s3(
        hd1080: "0367-trailer-1080p-714d2227e79241e08933b1ff79500540",
        hd720: "0367-trailer-1080p-714d2227e79241e08933b1ff79500540",
        sd540: "0367-trailer-1080p-714d2227e79241e08933b1ff79500540"
      ),
      id: "ed963a342289be29f5ecbb58b77b03b1"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
