import Foundation

extension Episode {
  public static let ep381_isolationDesign = Episode(
    blurb: """
      We have a type that we want to be non-`Sendable`, but in order for it to participate in \
      async code, it seems like we do need _something_ `Sendable`. Let's explore how we achieve \
      this sendability in ComposableArchitecture 1.0, why it's not ideal, and how a few new Swift \
      concurrency tools allow us to get closer to our goal in a better way.
      """,
    codeSampleDirectory: "0381-isolation-design-pt2",
    exercises: _exercises,
    id: 381,
    length: 16 * 60 + 48,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2026-09-28")!,
    references: [
      .functionalCoreImperativeShell,
    ],
    sequence: 381,
    socialImage: nil,
    subtitle: "Naively",
    title: "Designing for Isolation",
    trailerVideo: Video(
      bytesLength: 18_400_000,
      downloadUrls: .s3(
        hd1080: "0381-trailer-1080p-d9f9047ecd02451d8c7d6815af9ec35d",
        hd720: "0381-trailer-1080p-d9f9047ecd02451d8c7d6815af9ec35d",
        sd540: "0381-trailer-1080p-d9f9047ecd02451d8c7d6815af9ec35d"
      ),
      id: "ff5a9b10b835111b4feaaa4d6c4ae71c"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
