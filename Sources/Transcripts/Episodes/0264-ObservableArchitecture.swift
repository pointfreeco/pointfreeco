import Foundation

extension Episode {
  public static let ep264_observableArchitecture = Episode(
    blurb: """
      Observation has allowed us to get rid of a number of view wrappers the Composable Architecture
      used to require in favor of vanilla SwiftUI views, instead, but we still depend on a zoo of
      view modifiers to drive navigation. Let's rethink all of these helpers and see if we can trade
      them out for simpler, vanilla SwiftUI view modifiers, instead.
      """,
    codeSampleDirectory: "0264-observable-architecture-pt6",
    exercises: _exercises,
    id: 264,
    length: 22 * 60 + 8,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-01-15")!,
    references: [
      // TODO
    ],
    sequence: 264,
    subtitle: "Observing Navigation",
    title: "Observable Architecture",
    trailerVideo: .init(
      bytesLength: 47_800_000,
      downloadUrls: .s3(
        hd1080: "0264-trailer-1080p-9ef13ffd688948079af8cc4f5a288a5d",
        hd720: "0264-trailer-720p-55cd188721da4fad8d88733def9a718b",
        sd540: "0264-trailer-540p-ea4fe3cdd4bc4cc5a2b60eba7aa961b8"
      ),
      vimeoId: 894_663_121
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
