import Foundation

extension Episode {
  public static let ep365_isolation = Episode(
    blurb: """
      Swift 6.2 introduced a brand new vision for "approachable concurrency." This includes two \
      new features that make working with async code much easier: nonisolated-nonsending, and \
      actor-isolated conformances. Let's thoroughly explore both topics and see how they improve \
      things.
      """,
    codeSampleDirectory: "0365-beyond-basics-isolation-pt11",
    exercises: _exercises,
    id: 365,
    length: 43 * 60 + 17,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-05-11")!,
    references: [
      Episode.Reference(
        blurb: """
          > The Swift 6 language mode provides a baseline of correctness that meets the first \
          goal, but sometimes it comes at the cost of the second, and it can be frustrating to \
          adopt. Now that we have a lot more user experience under our belt as a community, it’s \
          reasonable to ask what we can do in the language to address that problem. This document \
          lays out several potential paths for improving the usability of Swift 6
          """,
        link: "https://github.com/swiftlang/swift-evolution/blob/main/visions/approachable-concurrency.md",
        title: "Improving the approachability of data-race safety"
      ),
      .se0306_actors,
    ],
    sequence: 365,
    subtitle: "Approachability",
    title: "Isolation",
    trailerVideo: Video(
      bytesLength: 35_500_000,
      downloadUrls: .s3(
        hd1080: "0365-trailer-1080p-86c263dd53d34f1cb4b4643a4ce0153b",
        hd720: "0365-trailer-1080p-86c263dd53d34f1cb4b4643a4ce0153b",
        sd540: "0365-trailer-1080p-86c263dd53d34f1cb4b4643a4ce0153b"
      ),
      id: "1a19cbc36edcb918ebfc5eee4e914ab9"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
