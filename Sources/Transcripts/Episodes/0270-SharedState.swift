import Foundation

extension Episode {
  public static let ep270_sharedState = Episode(
    blurb: """
      We finish building a complex, flow-based case study that leverages the new `@Shared` property
      wrapper. Along the way we will flex recently added superpowers of the library, and we will
      experience firsthand how simple this new model of shared state can be.
      """,
    codeSampleDirectory: "0270-shared-state-pt3",
    exercises: _exercises,
    id: 270,
    length: 41 * 60 + 50,
    permission: .subscriberOnly,
    publishedAt: yearMonthDayFormatter.date(from: "2024-03-11")!,
    references: [
      // TODO
    ],
    sequence: 270,
    subtitle: "The Solution, Part 2",
    title: "Shared State",
    trailerVideo: .init(
      bytesLength: 23_700_000,
      downloadUrls: .s3(
        hd1080: "0270-trailer-1080p-b783c88692814dfc8b6b351edb3fbdcd",
        hd720: "0270-trailer-720p-33d6df792c4d4762b45577ff8e8fcd4d",
        sd540: "0270-trailer-540p-a8b073775d71461db8fa97f0540894f2"
      ),
      vimeoId: 918940939
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]
